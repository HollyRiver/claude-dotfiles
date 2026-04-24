# claude-dotfiles

Claude Code shared configuration — rules and memory profile.

## Structure

```
rules/      # ~/.claude/rules/   — behavior guidelines loaded into every session
memory/     # ~/.claude/projects/memory/  — user profile and project context
```

## Sync to a new environment

```bash
# Clone
git clone https://github.com/HollyRiver/claude-dotfiles.git

# Apply rules
cp -r claude-dotfiles/rules/* ~/.claude/rules/

# Apply memory
mkdir -p ~/.claude/projects/memory
cp -r claude-dotfiles/memory/* ~/.claude/projects/memory/
```

## Update from local changes

```bash
cd ~/claude-dotfiles
cp ~/.claude/rules/* rules/
cp ~/.claude/projects/memory/* memory/
git add -A && git commit -m "sync: update rules and memory"
git push
```
