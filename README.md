# upwatch

`upwatch` is a lightweight "network sentinel" dashboard for monitoring site availability and latency.

The project currently includes:
- A browser-based dashboard (`index.html`) with a cyberpunk UI, rolling latency history, status transitions (green/amber/red), and local config persistence.
- A Windows PowerShell desktop monitor (`upwatch.ps1`) for a native grid/log workflow.

## Build / Run

No compilation step is required.

### Web dashboard
1. Clone the repo.
2. Open `index.html` in a modern browser.
   - Optional: serve the folder with a simple static server for easier iteration.

### PowerShell app (Windows)
1. Open PowerShell.
2. Run:
   ```powershell
   .\upwatch.ps1
   ```

## Basic controls

### Web dashboard
- **Enter target domain**: Type a URL into `ENTER_TARGET_DOMAIN`.
- **Inject node**: Click `Inject_Node` to start monitoring (max 5 nodes).
- **Purge node**: Click `Purge_Node` on a row to remove a target.
- **Upload config**: Click `Upload_Config` to save monitored nodes to local storage.
- **Flush cache**: Click `Flush_Cache` to clear the event stream display.
- **Export logs**: Use `Logs_JSON` or `Logs_CSV` in the event stream header.
- **Export latency history**: Use `Latency_JSON` or `Latency_CSV` in telemetry.

### PowerShell app
- **INJECT_NODE** adds a URL to the monitoring buffer.
- **PURGE_NODE** removes the selected target.
- **UPLOAD_CONFIG** writes the current URL list to disk.

## Roadmap

- Add import support for previously exported logs/latency snapshots.
- Add configurable thresholds and monitor intervals from the UI.
- Add lightweight test coverage for core status transition logic.
- Add optional alert integrations (email/webhook/Slack).
