#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
SETTINGS_JSON="$CLAUDE_DIR/settings.json"

FRAGMENT_JSON="$SCRIPT_DIR/settings-fragment.json"

START_DELIM="<!-- hai-notes:start -->"
END_DELIM="<!-- hai-notes:end -->"

echo "hai-notes uninstall"
echo "==================="
echo

# --- Skills ---
echo "Skills:"

for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    name=$(basename "$skill_dir")
    target="$SKILLS_DIR/$name"

    if [ -L "$target" ]; then
        existing=$(readlink "$target")
        if [ "$existing" = "$skill_dir" ] || [ "$existing" = "${skill_dir%/}" ]; then
            rm "$target"
            echo "  $name: removed"
        else
            echo "  $name: symlink points elsewhere ($existing), skipping"
        fi
    elif [ -d "$target" ]; then
        echo "  $name: is a directory (not a symlink), skipping"
    else
        echo "  $name: not present (skip)"
    fi
done
echo

# --- CLAUDE.md ---
echo "CLAUDE.md:"

if [ -f "$CLAUDE_MD" ] && grep -qF "$START_DELIM" "$CLAUDE_MD"; then
    python3 -c "
import sys

start = '$START_DELIM'
end = '$END_DELIM'

with open('$CLAUDE_MD', 'r') as f:
    content = f.read()

s = content.find(start)
e = content.find(end)
if s == -1 or e == -1:
    print('  ERROR: found start but not end delimiter', file=sys.stderr)
    sys.exit(1)

# Remove the block and any trailing blank line
new_content = content[:s] + content[e + len(end):]
# Clean up double blank lines left behind
while '\n\n\n' in new_content:
    new_content = new_content.replace('\n\n\n', '\n\n')
new_content = new_content.strip() + '\n'

with open('$CLAUDE_MD', 'w') as f:
    f.write(new_content)
"
    echo "  Removed hai-notes fragment"
else
    echo "  No hai-notes fragment found (skip)"
fi
echo

# --- settings.json ---
echo "settings.json:"

if [ -f "$SETTINGS_JSON" ] && [ -f "$FRAGMENT_JSON" ]; then
    export FRAGMENT_JSON_PATH="$FRAGMENT_JSON"
    export SETTINGS_JSON_PATH="$SETTINGS_JSON"

    python3 << 'PYEOF'
import json
import os

settings_path = os.environ["SETTINGS_JSON_PATH"]
fragment_path = os.environ["FRAGMENT_JSON_PATH"]

with open(settings_path) as f:
    settings = json.load(f)

with open(fragment_path) as f:
    fragment = json.load(f)

# Build set of commands/prompts to remove
remove_commands = set()
for hook_type, hook_entries in fragment["hooks"].items():
    for entry in hook_entries:
        for h in entry.get("hooks", []):
            cmd = h.get("command", h.get("prompt", ""))
            remove_commands.add(cmd)

removed = []

for hook_type in list(settings.get("hooks", {}).keys()):
    entries = settings["hooks"][hook_type]
    new_entries = []
    for entry in entries:
        keep = True
        for h in entry.get("hooks", []):
            cmd = h.get("command", h.get("prompt", ""))
            if cmd in remove_commands:
                keep = False
                removed.append(f"{hook_type}: removed")
                break
        if keep:
            new_entries.append(entry)
    settings["hooks"][hook_type] = new_entries

    # Remove empty hook type arrays
    if not settings["hooks"][hook_type]:
        del settings["hooks"][hook_type]

# Remove empty hooks dict
if not settings.get("hooks"):
    del settings["hooks"]

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

for msg in removed:
    print(f"  {msg}")

if not removed:
    print("  No hooks to remove")
PYEOF
else
    echo "  No settings.json or fragment found (skip)"
fi
echo

echo "Session notes data remains at ~/.claude/session-notes/ — not deleted."
echo "Done."
