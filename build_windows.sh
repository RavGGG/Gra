#!/usr/bin/env bash
set -euo pipefail
: "${GODOT_BIN:=godot4}"
"$GODOT_BIN" --headless --export-release "Windows Desktop" build/SpudSurvivor.exe
