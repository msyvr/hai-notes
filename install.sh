#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
SETTINGS_JSON="$CLAUDE_DIR/settings.json"

FRAGMENT_MD="$SCRIPT_DIR/claude-md-fragment.md"
FRAGMENT_JSON="$SCRIPT_DIR/settings-fragment.json"

START_DELIM="<!-- hai-notes:start -->"
END_DELIM="<!-- hai-notes:end -->"

echo "hai-notes install"
echo "================="
echo

# --- Skills ---
echo "Skills:"
mkdir -p "$SKILLS_DIR"

for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    name=$(basename "$skill_dir")
    target="$SKILLS_DIR/$name"

    if [ -L "$target" ]; then
        existing=$(readlink "$target")
        if [ "$existing" = "$skill_dir" ] || [ "$existing" = "${skill_dir%/}" ]; then
            echo "  $name: already linked (skip)"
        else
            echo "  $name: symlink exists but points to $existing (skip)"
        fi
    elif [ -d "$target" ]; then
        echo "  $name: WARNING — directory exists (not a symlink), skipping"
    else
        ln -s "$skill_dir" "$target"
        echo "  $name: linked"
    fi
done
echo

# --- CLAUDE.md ---
echo "CLAUDE.md:"
fragment_content=$(cat "$FRAGMENT_MD")
delimited_block="$START_DELIM
$fragment_content
$END_DELIM"

if [ ! -f "$CLAUDE_MD" ]; then
    echo "$delimited_block" > "$CLAUDE_MD"
    echo "  Created $CLAUDE_MD with hai-notes fragment"
elif grep -qF "$START_DELIM" "$CLAUDE_MD"; then
    # Replace existing block
    python3 -c "
import sys

start = '$START_DELIM'
end = '$END_DELIM'

with open('$CLAUDE_MD', 'r') as f:
    content = f.read()

s = content.find(start)
e = content.find(end)
if s == -1 or e == -1:
    print('ERROR: found start but not end delimiter', file=sys.stderr)
    sys.exit(1)

replacement = open('$FRAGMENT_MD').read()
new_content = content[:s] + start + '\n' + replacement + '\n' + end + content[e + len(end):]

with open('$CLAUDE_MD', 'w') as f:
    f.write(new_content)
"
    echo "  Updated existing hai-notes fragment"
else
    printf '\n%s\n' "$delimited_block" >> "$CLAUDE_MD"
    echo "  Appended hai-notes fragment"
fi
echo

# --- settings.json ---
echo "settings.json:"

export FRAGMENT_JSON_PATH="$FRAGMENT_JSON"
export SETTINGS_JSON_PATH="$SETTINGS_JSON"

python3 << 'PYEOF'
import json
import os

settings_path = os.environ["SETTINGS_JSON_PATH"]
fragment_path = os.environ["FRAGMENT_JSON_PATH"]

# Load existing settings
if os.path.exists(settings_path):
    with open(settings_path) as f:
        settings = json.load(f)
else:
    settings = {}

# Load fragment
with open(fragment_path) as f:
    fragment = json.load(f)

if "hooks" not in settings:
    settings["hooks"] = {}

added = []
skipped = []

for hook_type, hook_entries in fragment["hooks"].items():
    if hook_type not in settings["hooks"]:
        settings["hooks"][hook_type] = []

    existing_commands = set()
    for entry in settings["hooks"][hook_type]:
        for h in entry.get("hooks", []):
            cmd = h.get("command", h.get("prompt", ""))
            existing_commands.add(cmd)

    for entry in hook_entries:
        for h in entry.get("hooks", []):
            cmd = h.get("command", h.get("prompt", ""))
            if cmd in existing_commands:
                skipped.append(f"{hook_type}: already present (skip)")
            else:
                settings["hooks"][hook_type].append(entry)
                added.append(f"{hook_type}: added")

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

for msg in added:
    print(f"  {msg}")
for msg in skipped:
    print(f"  {msg}")

if not added and not skipped:
    print("  No hook changes needed")
PYEOF

echo
echo "Done. Start a new Claude Code session to verify hooks fire."
