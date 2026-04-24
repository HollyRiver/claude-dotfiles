#!/usr/bin/env bash
# sync-memory.sh
# 메모리 파일을 dotfiles 레포에 복사하고, 변경량이 기준치 이상이면 GitHub에 push
# PostToolUse hook 또는 수동으로 실행
# 사용: ./sync-memory.sh [-f]

set -euo pipefail

FORCE=false
[[ "${1:-}" == "-f" ]] && FORCE=true

REPO="/root/claude-dotfiles"
MEM_SRC="/root/.claude/projects/-root/memory"
THRESHOLD=15

cp -f "$MEM_SRC"/* "$REPO/memory/" 2>/dev/null || true

cd "$REPO"

# 로컬 변경이 없으면 빠르게 종료
LOCAL_DIFF=$(git diff -- memory/ 2>/dev/null)
UNTRACKED=$(git ls-files --others --exclude-standard -- memory/ 2>/dev/null)

if [[ -z "$LOCAL_DIFF" && -z "$UNTRACKED" && "$FORCE" == "false" ]]; then
  exit 0
fi

# 원격과 비교
git fetch origin --quiet 2>/dev/null || true
REMOTE_STAT=$(git diff origin/main --shortstat -- memory/ 2>/dev/null || echo "")

INSERTIONS=0
DELETIONS=0
if [[ "$REMOTE_STAT" =~ ([0-9]+)\ insertion ]]; then INSERTIONS="${BASH_REMATCH[1]}"; fi
if [[ "$REMOTE_STAT" =~ ([0-9]+)\ deletion ]];  then DELETIONS="${BASH_REMATCH[1]}"; fi
LINES=$(( INSERTIONS + DELETIONS ))

if [[ "$LINES" -ge "$THRESHOLD" || "$FORCE" == "true" ]]; then
  git add memory/
  LABEL=$( [[ "$FORCE" == "true" ]] && echo "manual" || echo "auto" )
  git commit -m "sync($LABEL): memory update (~${LINES} lines changed)"
  git push origin main --quiet
  echo "[claude-dotfiles] Memory synced to GitHub (${LINES} lines changed)"
else
  echo "[claude-dotfiles] Memory staged locally (${LINES}/${THRESHOLD} lines, push deferred)"
fi
