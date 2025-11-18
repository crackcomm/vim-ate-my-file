package manager

import (
	"encoding/json"
	"fmt"
	"os"
)

// Config holds the configuration for all LSP servers.
type Config struct {
	Servers []ServerConfigEntry `json:"servers"`
}

// GetServer returns the configuration for a named server.
func (c *Config) GetServer(name string) *ServerConfigEntry {
	for i, s := range c.Servers {
		if s.Name == name {
			return &c.Servers[i]
		}
	}
	return nil
}

// ServerConfigEntry represents a single LSP server's configuration.
type ServerConfigEntry struct {
	Name                  string   `json:"name"`
	Command               string   `json:"command"`
	LanguageID            string   `json:"languageId"`
	Trace                 bool     `json:"trace"`
	TraceArgs             []string `json:"traceArgs"`
	InitializationOptions any      `json:"initializationOptions"`
	Settings              any      `json:"settings,omitempty"`
}

// LoadConfig reads and parses the configuration file from the given path.
func LoadConfig(path string) (*Config, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("could not read config file: %w", err)
	}

	var config Config
	if err := json.Unmarshal(data, &config); err != nil {
		return nil, fmt.Errorf("could not parse config file: %w", err)
	}

	return &config, nil
}
