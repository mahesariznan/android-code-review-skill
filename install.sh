#!/bin/bash

SKILL_DIR="$HOME/.claude/skills/android-code-review"
SKILL_FILE="skills/android-code-review/SKILL.md"

if [ ! -f "$SKILL_FILE" ]; then
    echo "Error: SKILL.md not found. Pastikan kamu menjalankan script ini dari root repo."
    exit 1
fi

mkdir -p "$SKILL_DIR"
cp "$SKILL_FILE" "$SKILL_DIR/SKILL.md"

echo "✅ Skill 'android-code-review' berhasil diinstall di $SKILL_DIR"
echo "👉 Restart Claude Code atau jalankan /reload-plugins untuk mengaktifkan."
