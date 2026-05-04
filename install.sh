#!/bin/bash
# Symlinks all skills from this repo into ~/.claude/skills/
# Run once to set up, or re-run after adding new skills.

SKILLS_DIR="$HOME/.claude/skills"
REPO_DIR="$(cd "$(dirname "$0")/skills" && pwd)"

mkdir -p "$SKILLS_DIR"

for skill_path in "$REPO_DIR"/*/; do
  skill_name="$(basename "$skill_path")"
  target="$SKILLS_DIR/$skill_name"

  if [ -L "$target" ]; then
    echo "already linked: $skill_name"
  elif [ -e "$target" ]; then
    echo "skipped (already exists, not a symlink): $skill_name"
  else
    ln -s "$skill_path" "$target"
    echo "linked: $skill_name"
  fi
done

echo "done"
