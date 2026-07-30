#!/bin/sh
# Emergency shell restart -- the escape hatch out of a locked session whose lock
# surface is dead (Hyprland then shows its fallback "lock error" screen).
#
# This must never end with zero shells running. `caelestia shell -d` cannot be
# used here: it runs `qs -c caelestia -n -d`, and `-n` makes qs print "An
# instance of this configuration is already running." and exit 0 without
# starting anything while the previous instance is still shutting down. Lock
# teardown routinely takes over a second, so a fixed `sleep` raced it -- the
# escape hatch silently did nothing but kill the shell, which is the one
# outcome it exists to prevent.

CONFIG="$HOME/.config/quickshell/caelestia/shell.qml"

qs -c caelestia kill 2>/dev/null

# Wait for the old instance to actually release, but never longer than ~4s.
i=0
while [ "$i" -lt 40 ] && qs list --all 2>/dev/null | grep -qF "$CONFIG"; do
    sleep 0.1
    i=$((i + 1))
done

# Deliberately no -n: if a stale instance outlives the wait, still start a shell.
exec qs -c caelestia -d
