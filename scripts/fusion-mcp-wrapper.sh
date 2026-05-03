#!/bin/bash
# Relay container localhost:9876 → host.docker.internal:9876, then exec the MCP server.
# The fusion360-mcp Python server always connects to localhost:9876 (hardcoded in the lib).
# The Fusion add-in runs on Windows; host.docker.internal bridges Docker → Windows host.
# Windows must have the bridge script applied (scripts/fusion-mcp-bridge.ps1 -Port 9876).

python3 - <<'EOF' &
import socket, threading

def pipe(src, dst):
    try:
        while chunk := src.recv(4096):
            dst.sendall(chunk)
    finally:
        src.close(); dst.close()

srv = socket.socket()
srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
srv.bind(('127.0.0.1', 9876))
srv.listen(5)
while True:
    client, _ = srv.accept()
    try:
        remote = socket.socket()
        remote.connect(('host.docker.internal', 9876))
        for a, b in [(client, remote), (remote, client)]:
            threading.Thread(target=pipe, args=(a, b), daemon=True).start()
    except Exception:
        client.close()
EOF

sleep 0.5  # let relay bind before the MCP server tries to connect
exec "${HOME}/.local/bin/uvx" fusion360-mcp-server --mode socket
