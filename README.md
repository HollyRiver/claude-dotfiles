# claude-dotfiles

Claude Code shared configuration — rules and memory profile.

## Structure

```
rules/      # ~/.claude/rules/         — behavior guidelines
memory/     # ~/.claude/projects/memory/ — user profile and context
scripts/
  sync-memory.ps1   # auto-push when diff >= 15 lines (Windows)
  merge-memory.ps1  # merge two environments (Docker priority)
```

## Auto-sync (Windows)

`settings.json`의 PostToolUse hook이 Write 도구 실행 후 `sync-memory.ps1`을 자동 호출합니다.
변경량이 15줄 이상 누적되면 GitHub에 자동 push됩니다.

수동으로 즉시 push하려면:
```powershell
powershell -File C:\Users\hollyriver\claude-dotfiles\scripts\sync-memory.ps1 -Force
```

## Initial setup (Linux Docker)

```bash
git clone https://github.com/HollyRiver/claude-dotfiles.git ~/claude-dotfiles

# rules 적용
cp -r ~/claude-dotfiles/rules/* ~/.claude/rules/

# memory 적용
mkdir -p ~/.claude/projects/memory
cp -r ~/claude-dotfiles/memory/* ~/.claude/projects/memory/
```

## Merge (두 환경 메모리가 달라졌을 때)

Windows에서 실행. 충돌 시 리눅스 도커(remote) 측 내용을 우선 보존합니다.

```powershell
powershell -File C:\Users\hollyriver\claude-dotfiles\scripts\merge-memory.ps1
```

Linux Docker에서 먼저 push한 후, Windows에서 이 스크립트를 실행하는 것을 권장합니다.
