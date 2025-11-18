package lsp

import (
	"fmt"
	"io"
	"log"
	"os/exec"
)

// ServerConfig defines the configuration for launching an LSP server.
type ServerConfig struct {
	Command   string
	Args      []string
	WorkDir   string
	Trace     bool     // If true, enables verbose RPC tracing.
	TraceArgs []string // The arguments to use when tracing is enabled.
}

// readWriteCloser combines an io.ReadCloser and an io.WriteCloser into a single io.ReadWriteCloser.
type readWriteCloser struct {
	io.ReadCloser
	io.WriteCloser
}

func (rwc *readWriteCloser) Close() error {
	if err := rwc.ReadCloser.Close(); err != nil {
		return err
	}
	if err := rwc.WriteCloser.Close(); err != nil {
		return err
	}
	return nil
}

// Start launches the LSP server process.
func (c *ServerConfig) Start() (io.ReadWriteCloser, error) {
	args := c.Args
	if c.Trace {
		args = append(args, c.TraceArgs...)
	}

	cmd := exec.Command(c.Command, args...)
	if c.WorkDir != "" {
		cmd.Dir = c.WorkDir
	}

	stdin, err := cmd.StdinPipe()
	if err != nil {
		return nil, fmt.Errorf("could not get stdin pipe: %w", err)
	}
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return nil, fmt.Errorf("could not get stdout pipe: %w", err)
	}

	// Redirect stderr for logging/debugging.
	stderr, err := cmd.StderrPipe()
	if err != nil {
		return nil, fmt.Errorf("could not get stderr pipe: %w", err)
	}
	go func() {
		buf := make([]byte, 4096)
		for {
			n, err := stderr.Read(buf)
			if n > 0 {
				log.Printf("LSP STDERR: %s", string(buf[:n]))
			}
			if err != nil {
				break
			}
		}
	}()

	if err := cmd.Start(); err != nil {
		// Check if the command is not found.
		if ee, ok := err.(*exec.Error); ok && ee.Err == exec.ErrNotFound {
			return nil, fmt.Errorf("LSP server command '%s' not found in PATH", c.Command)
		}
		return nil, fmt.Errorf("could not start LSP server: %w", err)
	}

	log.Printf("Started LSP server process with command: %s %v", c.Command, args)

	return &readWriteCloser{
		ReadCloser:  stdout,
		WriteCloser: stdin,
	}, nil
}
