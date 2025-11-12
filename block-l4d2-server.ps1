# Script to block Left 4 Dead 2 server IPs via Windows Firewall
# Must be run as Administrator
# Based on Steam Community guide: https://steamcommunity.com/sharedfiles/filedetails/?id=3419848194

param(
    [string]$IPAddress
)

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator', then run this script again." -ForegroundColor Yellow
    pause
    exit 1
}

# Known problematic L4D2 server IPs from the Steam community guide
$knownBadIPs = @(
    "46.174.48.20", "18.180.172.93", "46.174.50.13", "46.174.51.200", "2.58.201.66",
    "93.190.139.252", "172.93.102.9", "96.126.124.92", "175.140.7.89", "109.236.90.41",
    "74.91.112.169", "74.91.112.162", "154.8.209.16", "43.163.71.148", "1.15.90.156",
    "42.194.235.96", "42.193.7.57", "36.41.163.157", "1.13.188.69", "106.52.119.202",
    "81.70.247.179", "106.52.229.216", "43.140.252.45", "43.156.101.68", "111.230.6.213",
    "82.156.195.10", "47.239.43.116", "1.117.155.157", "118.25.236.72", "1.15.87.79",
    "8.217.126.121", "8.217.160.56", "111.230.193.134", "47.83.28.85", "114.132.67.16",
    "175.137.207.82", "202.186.76.249", "103.131.188.71", "94.72.141.139", "185.187.155.10",
    "157.20.105.71", "45.67.85.139", "45.134.110.25", "202.184.32.249", "185.121.26.7",
    "45.11.231.30", "45.11.230.10", "2.58.200.5", "178.239.171.97", "180.72.180.53",
    "43.153.78.32", "49.51.230.98", "162.62.120.167", "43.156.84.96", "43.133.59.151"
)

Write-Host "=== L4D2 Server IP Blocker ===" -ForegroundColor Cyan
Write-Host "Source: https://steamcommunity.com/sharedfiles/filedetails/?id=3419848194`n" -ForegroundColor Gray

# Try to fetch updated IPs from Steam Community (optional - won't block if it fails)
Write-Host "[STEP 1] Checking for updated IP list from Steam Community..." -ForegroundColor Yellow
try {
    $webContent = Invoke-WebRequest -Uri "https://steamcommunity.com/sharedfiles/filedetails/?id=3419848194" -TimeoutSec 5 -ErrorAction Stop
    $pageText = $webContent.Content
    
    # Extract only IPs from the main guide content (not comments)
    # Look for IPs in structured sections before the comments
    $guideSectionMatch = [regex]::Match($pageText, '(?s)IPs To Block.*?(?=<div class="commentthread|$)')
    $guideSection = if ($guideSectionMatch.Success) { $guideSectionMatch.Value } else { $pageText }
    
    # Extract IPs from the guide section only
    $onlineIPs = [regex]::Matches($guideSection, '\b(?:\d{1,3}\.){3}\d{1,3}\b') | ForEach-Object { $_.Value } | Sort-Object -Unique
    
    if ($onlineIPs.Count -gt 0) {
        # Find IPs that are new (not in our list)
        $newIPs = $onlineIPs | Where-Object { $knownBadIPs -notcontains $_ }
        
        if ($newIPs.Count -gt 0) {
            Write-Host "  Found $($newIPs.Count) new IP(s) from Steam Community:" -ForegroundColor Green
            foreach ($newIP in $newIPs) {
                Write-Host "    + $newIP" -ForegroundColor Cyan
            }
            # Merge with known list
            $knownBadIPs = ($knownBadIPs + $newIPs) | Sort-Object -Unique
        }
        else {
            Write-Host "  IP list is up to date." -ForegroundColor Green
        }
    }
}
catch {
    Write-Host "  Could not fetch online list (continuing with built-in list)" -ForegroundColor Yellow
}

# Check and block known IPs
Write-Host "`n[STEP 2] Auto-blocking known problematic servers..." -ForegroundColor Yellow
Write-Host "Processing $($knownBadIPs.Count) known IPs...`n" -ForegroundColor Gray

$newlyBlocked = 0
$skipped = 0
$failed = 0
$processed = 0

foreach ($ip in $knownBadIPs) {
    $processed++
    $inboundRuleName = "1A_L4D2_Block_${ip}_Inbound"
    $outboundRuleName = "1A_L4D2_Block_${ip}_Outbound"
    
    # Show progress
    Write-Host "  [$processed/$($knownBadIPs.Count)] $ip..." -ForegroundColor Gray -NoNewline
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $ruleCreated = $false
    $ruleExists = $false
    
    # Try to create inbound rule
    try {
        New-NetFirewallRule -DisplayName $inboundRuleName `
            -Direction Inbound `
            -Action Block `
            -RemoteAddress $ip `
            -Protocol Any `
            -Enabled True `
            -Profile Any `
            -Description "Blocks L4D2 server at $ip (Auto-blocked from known list)" -ErrorAction Stop | Out-Null
        $ruleCreated = $true
    }
    catch {
        if ($_.Exception.Message -match "Cannot create a file when that file already exists") {
            $ruleExists = $true
        }
        else {
            Write-Host " Failed!" -ForegroundColor Red
            $failed++
            continue
        }
    }
    
    # Try to create outbound rule
    try {
        New-NetFirewallRule -DisplayName $outboundRuleName `
            -Direction Outbound `
            -Action Block `
            -RemoteAddress $ip `
            -Protocol Any `
            -Enabled True `
            -Profile Any `
            -Description "Blocks L4D2 server at $ip (Auto-blocked from known list)" -ErrorAction Stop | Out-Null
        $ruleCreated = $true
    }
    catch {
        if ($_.Exception.Message -match "Cannot create a file when that file already exists") {
            $ruleExists = $true
        }
        else {
            Write-Host " Failed!" -ForegroundColor Red
            $failed++
            continue
        }
    }
    
    if ($ruleCreated) {
        Write-Host " Blocked" -ForegroundColor Green
        $newlyBlocked++
    }
    elseif ($ruleExists) {
        Write-Host " Skipped" -ForegroundColor DarkGray
        $skipped++
    }
}

Write-Host "`n=== Known IPs Summary ===" -ForegroundColor Cyan
Write-Host "  Newly blocked:     $newlyBlocked" -ForegroundColor Green
Write-Host "  Skipped (exist):   $skipped" -ForegroundColor DarkGray
if ($failed -gt 0) {
    Write-Host "  Failed:            $failed" -ForegroundColor Red
}
Write-Host "`n[STEP 3] Block additional IPs (interactive mode)" -ForegroundColor Yellow

$manualBlockedCount = 0

# Main loop - keeps asking for IPs until user types 'exit'
while ($true) {
    # Prompt for IP
    $IPAddress = Read-Host "Enter IP address to block (or 'exit' to quit)"
    
    # Check if user wants to exit
    if ($IPAddress -eq 'exit' -or $IPAddress -eq 'quit' -or $IPAddress -eq 'q') {
        break
    }
    
    # Skip empty input
    if ([string]::IsNullOrWhiteSpace($IPAddress)) {
        continue
    }
    
    # Validate IP address format
    if ($IPAddress -notmatch '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
        Write-Host "ERROR: Invalid IP address format. Please use format: xxx.xxx.xxx.xxx" -ForegroundColor Red
        $IPAddress = $null
        continue
    }
    
    # Create rule names with timestamp to avoid conflicts
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $inboundRuleName = "1A_L4D2_Block_${IPAddress}_Inbound"
    $outboundRuleName = "1A_L4D2_Block_${IPAddress}_Outbound"
    
    Write-Host "`nBlocking IP: $IPAddress" -ForegroundColor Cyan
    
    try {
        # Create Inbound Rule
        New-NetFirewallRule -DisplayName $inboundRuleName `
            -Direction Inbound `
            -Action Block `
            -RemoteAddress $IPAddress `
            -Protocol Any `
            -Enabled True `
            -Profile Any `
            -Description "Blocks L4D2 server at $IPAddress (Created: $timestamp)" -ErrorAction Stop | Out-Null
    
        # Create Outbound Rule
        New-NetFirewallRule -DisplayName $outboundRuleName `
            -Direction Outbound `
            -Action Block `
            -RemoteAddress $IPAddress `
            -Protocol Any `
            -Enabled True `
            -Profile Any `
            -Description "Blocks L4D2 server at $IPAddress (Created: $timestamp)" -ErrorAction Stop | Out-Null
    
        Write-Host "[SUCCESS] Blocked $IPAddress" -ForegroundColor Green
        $manualBlockedCount++
    }
    catch {
        Write-Host "[ERROR] Failed to create firewall rules for $IPAddress" -ForegroundColor Red
        Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Final Summary ===" -ForegroundColor Cyan
Write-Host "  Known IPs (auto):  $newlyBlocked newly blocked" -ForegroundColor Green
Write-Host "  Manual IPs:        $manualBlockedCount" -ForegroundColor Green
$totalBlocked = $newlyBlocked + $manualBlockedCount
Write-Host "  Total new blocks:  $totalBlocked" -ForegroundColor Cyan
Write-Host ""
