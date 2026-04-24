# sync-memory.ps1
# 메모리 파일을 dotfiles 레포에 복사하고, 변경량이 기준치 이상이면 GitHub에 push
# PostToolUse hook 또는 수동으로 실행

param([switch]$Force)

$repo    = "C:\Users\hollyriver\claude-dotfiles"
$memSrc  = "C:\Users\hollyriver\.claude\projects\memory"
$threshold = 15   # 누적 변경 라인 수 기준

Copy-Item "$memSrc\*" "$repo\memory\" -Force -ErrorAction SilentlyContinue

Push-Location $repo

# 로컬 변경이 없으면 빠르게 종료
$localDiff = git diff -- memory/
if (-not $localDiff -and -not $Force) { Pop-Location; exit 0 }

# 원격과 비교
git fetch origin --quiet 2>$null
$remoteDiff = git diff origin/main --shortstat -- memory/

$lines = 0
if ($remoteDiff -match "(\d+) insertion") { $lines += [int]$Matches[1] }
if ($remoteDiff -match "(\d+) deletion")  { $lines += [int]$Matches[1] }

if ($lines -ge $threshold -or $Force) {
    git add memory/
    $label = if ($Force) { "manual" } else { "auto" }
    git commit -m "sync($label): memory update (~$lines lines changed)"
    git push origin main --quiet
    Write-Host "[claude-dotfiles] Memory synced to GitHub ($lines lines changed)"
} else {
    Write-Host "[claude-dotfiles] Memory staged locally ($lines/$threshold lines, push deferred)"
}

Pop-Location
