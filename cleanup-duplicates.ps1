# Cleanup script to remove duplicate L4D2 firewall rules
# Must be run as Administrator

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator', then run this script again." -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "=== L4D2 Firewall Rules Cleanup ===" -ForegroundColor Cyan
Write-Host "Checking for duplicate rules...`n" -ForegroundColor Gray

# Get all L4D2 rules and group by DisplayName
$allRules = Get-NetFirewallRule -DisplayName "1A_L4D2_Block_*" -ErrorAction SilentlyContinue
$grouped = $allRules | Group-Object DisplayName

$duplicatesFound = 0
$duplicatesRemoved = 0

foreach ($group in $grouped) {
    if ($group.Count -gt 1) {
        $duplicatesFound += ($group.Count - 1)
        Write-Host "Found $($group.Count) copies of: $($group.Name)" -ForegroundColor Yellow
        
        # Keep the first rule, remove the rest
        $rulesToRemove = $group.Group | Select-Object -Skip 1
        
        foreach ($rule in $rulesToRemove) {
            try {
                Remove-NetFirewallRule -Name $rule.Name -ErrorAction Stop
                Write-Host "  Removed duplicate: $($rule.Name)" -ForegroundColor Green
                $duplicatesRemoved++
            }
            catch {
                Write-Host "  Failed to remove: $($rule.Name)" -ForegroundColor Red
            }
        }
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
if ($duplicatesFound -eq 0) {
    Write-Host "  No duplicates found. All clean!" -ForegroundColor Green
}
else {
    Write-Host "  Duplicates found:   $duplicatesFound" -ForegroundColor Yellow
    Write-Host "  Duplicates removed: $duplicatesRemoved" -ForegroundColor Green
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
