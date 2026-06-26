# Bazel Download Proxy

A caching HTTP proxy for Bazel/Go downloads. Listens on `:7462`, caches
responses to a local filesystem.

## Routing

| Prefix  | Upstream                                    |
| ------- | ------------------------------------------- |
| `/-/`   | `https://<path>` (Bazel downloader)         |
| `/go/`  | `https://proxy.golang.org/<path>` (GOPROXY) |
| `/_/`   | Management endpoints                        |
| default | `https://<path>` (backwards compat)         |

## Configuration

### Bazel downloader

`bazel/downloader_config.txt`:

```
rewrite (.*) http://localhost:7462/-/$1
```

`.bazelrc`:

```
common --downloader_config=bazel/downloader_config.txt
```

### Go module proxy

`.bazelrc`:

```
common --repo_env=GOPROXY=http://localhost:7462/go
```

## Cache

Cache files are stored flat in `-directory` (default
`/mnt/bazel-cache/proxy/bazel-cache/`), named by SHA-256 of the upstream
URL. Two append-only log files live alongside:

- **MANIFEST** — `<ts>\t<url>\t<hash>` logged on cache fill (creation time)
- **ACCESS** — `<ts>\t<hash>` logged on cache hit (last access)

## Management endpoints

Responses are plain text.

### `DELETE /_/gc?max_age=<dur>[&dry_run]`

Deletes entries not accessed in > `max_age` (uses ACCESS). Duration is Go
`time.ParseDuration` format (e.g. `720h` for 30 days).

```
DELETE /_/gc?max_age=720h
  /mnt/bazel-cache/proxy/bazel-cache/abc123
  /mnt/bazel-cache/proxy/bazel-cache/def456

  2 files deleted
```

### `DELETE /_/pattern?pattern=<glob>[&max_age=<dur>][&dry_run]`

Deletes entries whose URL matches the glob (uses MANIFEST creation time).
If `max_age` omitted, deletes all matching regardless of age.

Glob: `*` (non-/), `**` (any), `?` (single non-/).

```
DELETE /_/pattern?pattern=proxy.golang.org/*/@latest
  /mnt/bazel-cache/proxy/bazel-cache/abc123

  1 file deleted
```

## Building

```bash
nix build .#bazel_download_proxy       # from ~/x/dot-repo
nix run .#bazel_download_proxy          # run directly
CGO_ENABLED=0 go build -o bazel_download_proxy main.go
```

## Running (systemd)

```bash
systemctl --user start bazel_download_proxy
systemctl --user restart bazel_download_proxy
journalctl --user -u bazel_download_proxy -f
```
