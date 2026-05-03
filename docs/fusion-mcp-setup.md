# Fusion MCP Setup Guide

The `modeler-fusion` agent drives Autodesk Fusion 360 via MCP from inside the devcontainer.

## Architecture

```
Devcontainer
  Claude Code
    └── spawns fusion-mcp-wrapper.sh (stdio MCP subprocess)
         ├── Python TCP relay  localhost:9876 ──────────────────────┐
         └── uvx fusion360-mcp-server  (connects to localhost:9876) ┘
                                                                     │ relayed to
                                                              host.docker.internal:9876
                                                                     │
Windows host (netsh portproxy)                                       │
  0.0.0.0:9876 ──forwards──► 127.0.0.1:9876 ◄─────────────────────┘
                                    │
                             Fusion MCP add-in
                             (TCP server in Fusion 360)
```

The Python MCP server always connects to `localhost:9876`. The wrapper script starts a TCP relay that intercepts that connection and forwards it to `host.docker.internal:9876`, which Windows portproxy sends on to the Fusion add-in.

## Prerequisites

- `uv` installed in the container — already present (`~/.local/bin/uv`)
- `host.docker.internal` resolving in the container — already confirmed (`192.168.65.254`)
- Fusion 360 installed on Windows host

## Step 1 — Install the Fusion 360 add-in (Windows)

Open PowerShell on Windows:

```powershell
# Clone the repo
git clone https://github.com/faust-machines/fusion360-mcp-server
cd fusion360-mcp-server

# Copy the add-in to Fusion's add-ins directory
Copy-Item -Recurse addon "$env:APPDATA\Autodesk\Autodesk Fusion 360\API\AddIns\Fusion360MCP"
```

Then in Fusion 360:
1. Press **Shift+S** to open the Scripts and Add-Ins dialog
2. Click the **Add-Ins** tab
3. Find **Fusion360MCP** → click **Run**
4. Open the **TEXT COMMANDS** panel (View menu or bottom toolbar)
5. Confirm you see: `[MCP] Server listening on localhost:9876`

## Step 2 — Run the Windows bridge script (once, as Administrator)

Open PowerShell **as Administrator**:

```powershell
cd \path\to\workspace\projects\3d-printing   # or \\wsl$\Ubuntu\workspace\projects\3d-printing
.\scripts\fusion-mcp-bridge.ps1
```

This adds:
1. A `netsh portproxy` rule: `0.0.0.0:9876 → 127.0.0.1:9876`
2. A Windows Firewall inbound rule for port 9876 from Docker/WSL2 subnets

Both rules persist across reboots. Re-running is safe (idempotent). To remove:
```powershell
.\scripts\fusion-mcp-bridge.ps1 -Remove
```

## Step 3 — Verify from inside the container

Test that the TCP path is open end-to-end:

```bash
# Should connect and immediately close (Fusion's add-in speaks its own protocol, not HTTP)
python3 -c "
import socket
s = socket.socket()
s.settimeout(3)
s.connect(('host.docker.internal', 9876))
print('Connected — bridge is working')
s.close()
"
```

If you get `Connection refused`: add-in isn't running in Fusion.  
If you get `Connection timed out`: portproxy or firewall rule is missing — re-run bridge script.

## Step 4 — Confirm in Claude Code

```
/mcp
```

`fusion` should show as **connected**. Claude Code spawns the wrapper script, which starts the TCP relay and then the MCP server, which pings the add-in.

## Step 5 — Smoke test

Ask Claude:
> "Use the fusion MCP to create a 20×20×10mm box with a 2mm fillet on all top edges, export STL to designs/test-box/output/test-box.stl, report bounding box."

Expected: Fusion creates the geometry, STL lands in the container filesystem, bounding box 20×20×10mm.

## Export path note

Fusion writes to Windows paths. The workspace is mounted at:
- Container: `/workspace/projects/3d-printing/`  
- Windows: `\\wsl$\Ubuntu\workspace\projects\3d-printing\`

The modeler-fusion agent should export STL to the UNC path. If Fusion can't write to UNC paths, export to `C:\Users\<user>\AppData\Local\Temp\` and add a copy step.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `/mcp` shows `fusion` disconnected | Wrapper failed to start | Run `bash scripts/fusion-mcp-wrapper.sh` in a terminal to see errors |
| `uvx: not found` in wrapper | uv not on PATH in non-interactive shell | Change wrapper to use `/home/node/.local/bin/uvx` |
| Python relay error on port 9876 | Port already in use | Kill stale relay: `lsof -ti:9876 \| xargs kill` |
| TCP connect: Connection refused | Fusion add-in not running | Shift+S → Add-Ins → Fusion360MCP → Run |
| TCP connect: Timed out | Portproxy or firewall rule missing | Re-run `fusion-mcp-bridge.ps1` as Administrator |
| STL path not found | UNC path issue | Export to Windows temp, update wrapper to copy |
| Wrong unit scale | Fusion API is centimeters | Agent multiplies by 10 for mm |

## When to use the Fusion backend

Set `"modelingBackend": "fusion"` in `spec.json` for designs with organic/compound-curve geometry — lofts, sweeps, T-splines, complex surface blends. Keep `"openscad"` (default) for functional parts, gridfinity bins, and anything that needs headless rendering without Fusion open.
