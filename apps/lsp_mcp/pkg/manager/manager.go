package manager

import (
	"context"
	"fmt"
	"log"
	"os"
	"strings"
	"sync"

	"github.com/crackcomm/vim-ate-my-file/apps/lsp_mcp/pkg/lsp"
	"github.com/crackcomm/vim-ate-my-file/apps/lsp_mcp/pkg/tooling"
	lsptypes "github.com/sourcegraph/go-lsp"
)

// Manager holds and manages active LSP clients, keyed by server name and workspace root.
type Manager struct {
	mu      sync.Mutex
	clients map[string]map[string]*lsp.Client // [serverName][rootURI] -> client
	config  *Config
}

// NewManager creates a new Manager from a config file.
func NewManager(configFile string) (*Manager, error) {
	config, err := LoadConfig(configFile)
	if err != nil {
		return nil, fmt.Errorf("could not load config: %w", err)
	}
	return &Manager{
		clients: make(map[string]map[string]*lsp.Client),
		config:  config,
	}, nil
}

// GetResolver returns a language-specific resolver for a given server and workspace.
func (m *Manager) GetResolver(name, rootURI string) (tooling.Resolver, error) {
	if rootURI == "" {
		wd, err := os.Getwd()
		if err != nil {
			return nil, fmt.Errorf("could not get current working directory: %w", err)
		}
		rootURI = "file://" + wd
	}

	client, err := m.GetClient(name, rootURI)
	if err != nil {
		return nil, err
	}

	serverConfig := m.config.GetServer(name)
	if serverConfig == nil {
		return nil, fmt.Errorf("no configuration found for LSP server '%s'", name)
	}

	switch serverConfig.LanguageID {
	case "lua":
		return tooling.NewLuaResolver(client, rootURI), nil
	default:
		return tooling.NewGenericResolver(client, serverConfig.LanguageID, rootURI), nil
	}
}

// GetClient returns a client for a given server and workspace root, starting it if necessary.
func (m *Manager) GetClient(name, rootURI string) (*lsp.Client, error) {
	m.mu.Lock()
	defer m.mu.Unlock()

	if rootURI == "" {
		wd, err := os.Getwd()
		if err != nil {
			return nil, fmt.Errorf("could not get current working directory: %w", err)
		}
		rootURI = "file://" + wd
	}

	// Ensure the server-level map exists.
	if _, ok := m.clients[name]; !ok {
		m.clients[name] = make(map[string]*lsp.Client)
	}

	// If the client for this specific workspace already exists, return it.
	if client, ok := m.clients[name][rootURI]; ok {
		return client, nil
	}

	// Find the server configuration.
	serverConfig := m.config.GetServer(name)
	if serverConfig == nil {
		return nil, fmt.Errorf("no configuration found for LSP server '%s'", name)
	}

	// If the root URI is empty, default to the current working directory.
	if rootURI == "" {
		cwd, err := os.Getwd()
		if err != nil {
			return nil, fmt.Errorf("could not get current working directory: %w", err)
		}
		rootURI = "file://" + cwd
	}

	workDir := strings.TrimPrefix(rootURI, "file://")

	// Start the LSP server process.
	log.Printf("Starting LSP server '%s' for workspace '%s'...", name, rootURI)
	lspServerConfig := &lsp.ServerConfig{
		Command:   serverConfig.Command,
		Trace:     serverConfig.Trace,
		TraceArgs: serverConfig.TraceArgs,
		WorkDir:   workDir, // Set the server's working directory to the workspace root.
	}
	rwc, err := lspServerConfig.Start()
	if err != nil {
		return nil, fmt.Errorf("could not start LSP server: %w", err)
	}

	// Create a new client and perform the initialization handshake.
	handler := lsp.NewHandler(serverConfig.Settings)
	client := lsp.NewClient(context.Background(), rwc, handler)

	if _, err := client.Initialize(context.Background(), &lsptypes.InitializeParams{
		RootURI: lsptypes.DocumentURI(rootURI),
		Capabilities: lsptypes.ClientCapabilities{
			Window: lsptypes.WindowClientCapabilities{
				WorkDoneProgress: true,
			},
			Workspace: lsptypes.WorkspaceClientCapabilities{
				Configuration: true,
			},
		},
		InitializationOptions: serverConfig.InitializationOptions,
	}); err != nil {
		rwc.Close()
		return nil, fmt.Errorf("LSP initialization failed: %w", err)
	}

	m.clients[name][rootURI] = client
	log.Printf("LSP server '%s' for workspace '%s' initialized and ready.", name, rootURI)
	return client, nil
}
