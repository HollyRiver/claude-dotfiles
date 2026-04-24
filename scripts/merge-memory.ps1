# merge-memory.ps1
# 두 환경의 메모리를 병합. 충돌 시 리눅스 도커(remote) 측 내용을 우선 보존.
# Windows에서 실행하는 것을 기준으로 작성됨.

$repo   = "C:\Users\hollyriver\claude-dotfiles"
$memDst = "C:\Users\hollyriver\.claude\projects\memory"

Push-Location $repo

Write-Host "[merge] Fetching remote..."
git fetch origin

# 로컬에 uncommitted 변경이 있으면 먼저 commit
$status = git status --short -- memory/
if ($status) {
    Copy-Item "$memDst\*" "$repo\memory\" -Force -ErrorAction SilentlyContinue
    git add memory/
    git commit -m "sync(pre-merge): local memory snapshot"
}

# 병합 — 충돌 시 remote(Docker 측) 우선
Write-Host "[merge] Merging with Docker-side priority..."
git merge origin/main -X theirs -m "merge: combine memories (docker priority)"

if ($LASTEXITCODE -ne 0) {
    Write-Host "[merge] Merge failed. Resolve conflicts manually in: $repo\memory\"
    Pop-Location
    exit 1
}

# 병합 결과를 Claude 메모리 경로에 반영
Copy-Item "$repo\memory\*" "$memDst\" -Force
Write-Host "[merge] Applied merged memory to ~/.claude/projects/memory/"

git push origin main --quiet
Write-Host "[merge] Pushed merged result to GitHub"

Pop-Location
