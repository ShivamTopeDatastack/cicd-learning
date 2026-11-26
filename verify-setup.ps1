$failed = 0
function Check {
    param([string]$Name, [bool]$Ok, [string]$Hint)
    if ($Ok) { Write-Host "[PASS] $Name" -ForegroundColor Green }
    else { Write-Host "[FAIL] $Name -> $Hint" -ForegroundColor Red; $script:failed++ }
}

git rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: ye Git repo nahi hai" -ForegroundColor Red
    exit 1
}

$name   = git config user.name
$email  = git config user.email
$remote = git remote get-url origin 2>$null
$tracked = @(git ls-files)

Check "git user.name set hai"        ([bool]$name)  "git config --global user.name ..."
Check "git user.email set hai"       ([bool]$email) "git config --global user.email ..."
Check "origin remote GitHub ka hai"  ($remote -match "github.com") "git remote -v dekho"
Check "README.md maujood"            (Test-Path README.md) "README.md banao"
Check ".gitignore maujood"           (Test-Path .gitignore) ".gitignore banao"
Check "LICENSE maujood"              (Test-Path LICENSE) "License add karo"
Check "src/ folder"                  (Test-Path src) "src banao"
Check "tests/ folder"                (Test-Path tests) "tests banao"
Check "docs/ folder"                 (Test-Path docs) "docs banao"
Check "workflows folder"             (Test-Path .github\workflows) ".github\workflows banao"
Check "PR template"                  (Test-Path .github\pull_request_template.md) "template banao"

$secrets = @($tracked | Where-Object { ($_ -match '(^|/)\.env($|\.)' -and $_ -notmatch '\.env\.example$') -or $_ -match '\.(pem|key)$' })
Check "Koi secret file tracked nahi" ($secrets.Count -eq 0) ("Tracked secrets: " + ($secrets -join ", "))

Write-Host ""
if ($failed -eq 0) { Write-Host "RESULT: Setup sahi hai." -ForegroundColor Green; exit 0 }
else { Write-Host "RESULT: $failed check(s) FAIL." -ForegroundColor Red; exit 1 }
