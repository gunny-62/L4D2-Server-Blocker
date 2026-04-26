# Script to block Left 4 Dead 2 server IPs via Windows Firewall
# Must be run as Administrator
# Based on Steam Community guide: https://steamcommunity.com/sharedfiles/filedetails/?id=3419848194

param(
    [string]$IPAddress
)

# Function to validate IP address (checks each octet is 0-255)
function Test-ValidIP {
    param([string]$IP)
    
    if ($IP -notmatch '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
        return $false
    }
    
    $octets = $IP.Split('.')
    foreach ($octet in $octets) {
        if ([int]$octet -gt 255) {
            return $false
        }
    }
    return $true
}

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator', then run this script again." -ForegroundColor Yellow
    pause
    exit 1
}

# Fallback IP list (used only if Steam Community is unreachable)
$fallbackIPs = @(
    "1.117.155.157", "1.12.235.136", "1.13.188.69", "1.15.87.79", "1.15.90.156", "101.33.205.158", "101.43.145.105", "103.131.188.71", "106.52.119.202", "106.52.229.216", "106.53.172.59", "109.236.90.41", "111.230.193.134", "111.230.6.213", "114.132.222.201", "114.132.67.16", "118.25.236.72", "123.113.148.8", "124.222.210.29", "154.8.209.16", "157.20.105.71", "162.62.120.167", "164.132.201.202", "172.93.102.9", "175.137.207.82", "175.140.7.89", "178.239.171.97", "18.180.172.93", "180.72.180.53", "185.121.26.7", "185.187.155.10", "2.58.200.5", "2.58.201.66", "202.184.32.249", "202.186.76.249", "36.41.163.157", "42.193.7.57", "42.194.235.96", "43.133.59.151", "43.140.252.45", "43.153.78.32", "43.156.101.68", "43.156.30.210", "43.156.84.96", "43.159.138.253", "43.161.233.17", "43.161.251.101", "43.163.71.148", "45.11.230.10", "45.11.231.30", "45.134.110.25", "45.58.126.33", "45.67.85.139", "46.174.48.20", "46.174.50.13", "46.174.51.200", "47.239.43.116", "47.83.28.85", "49.51.230.98", "49.51.34.109", "74.91.112.162", "74.91.112.169", "74.91.119.75", "74.91.124.246", "8.217.126.121", "8.217.160.56", "81.70.247.179", "82.156.195.10", "93.190.139.252", "94.72.141.139", "96.126.124.92"
)
    "1.117.155.157", "1.12.235.136", "1.13.188.69", "1.15.87.79", "1.15.90.156", "101.33.205.158", "101.43.145.105", "103.131.188.71", "106.52.119.202", "106.52.229.216", "106.53.172.59", "109.236.90.41", "111.230.193.134", "111.230.6.213", "114.132.222.201", "114.132.67.16", "118.25.236.72", "123.113.148.8", "124.222.210.29", "154.8.209.16", "157.20.105.71", "162.62.120.167", "164.132.201.202", "172.93.102.9", "175.137.207.82", "175.140.7.89", "178.239.171.97", "18.180.172.93", "180.72.180.53", "185.121.26.7", "185.187.155.10", "2.58.200.5", "2.58.201.66", "202.184.32.249", "202.186.76.249", "36.41.163.157", "42.193.7.57", "42.194.235.96", "43.133.59.151", "43.140.252.45", "43.153.78.32", "43.156.101.68", "43.156.30.210", "43.156.84.96", "43.159.138.253", "43.161.233.17", "43.161.251.101", "43.163.71.148", "45.11.230.10", "45.11.231.30", "45.134.110.25", "45.58.126.33", "45.67.85.139", "46.174.48.20", "46.174.50.13", "46.174.51.200", "47.239.43.116", "47.83.28.85", "49.51.230.98", "49.51.34.109", "74.91.112.162", "74.91.112.169", "74.91.119.75", "74.91.124.246", "8.217.126.121", "8.217.160.56", "81.70.247.179", "82.156.195.10", "93.190.139.252", "94.72.141.139", "96.126.124.92"
)
    "1.117.155.157", "1.12.235.136", "1.13.188.69", "1.15.87.79", "1.15.90.156", "101.33.205.158", "101.43.145.105", "103.131.188.71", "106.52.119.202", "106.52.229.216", "106.53.172.59", "109.236.90.41", "111.230.193.134", "111.230.6.213", "114.132.222.201", "114.132.67.16", "118.25.236.72", "123.113.148.8", "124.222.210.29", "154.8.209.16", "157.20.105.71", "162.62.120.167", "164.132.201.202", "172.93.102.9", "175.137.207.82", "175.140.7.89", "178.239.171.97", "18.180.172.93", "180.72.180.53", "185.121.26.7", "185.187.155.10", "2.58.200.5", "2.58.201.66", "202.184.32.249", "202.186.76.249", "36.41.163.157", "42.193.7.57", "42.194.235.96", "43.133.59.151", "43.140.252.45", "43.153.78.32", "43.156.101.68", "43.156.30.210", "43.156.84.96", "43.159.138.253", "43.161.233.17", "43.161.251.101", "43.163.71.148", "45.11.230.10", "45.11.231.30", "45.134.110.25", "45.58.126.33", "45.67.85.139", "46.174.48.20", "46.174.50.13", "46.174.51.200", "47.239.43.116", "47.83.28.85", "49.51.230.98", "49.51.34.109", "74.91.112.162", "74.91.112.169", "74.91.124.246", "8.217.126.121", "8.217.160.56", "81.70.247.179", "82.156.195.10", "93.190.139.252", "94.72.141.139", "96.126.124.92"
)
    "1.117.155.157", "1.12.235.136", "1.13.188.69", "1.15.87.79", "1.15.90.156", "101.33.205.158", "101.43.145.105", "103.131.188.71", "106.52.119.202", "106.52.229.216", "106.53.172.59", "109.236.90.41", "111.230.193.134", "111.230.6.213", "114.132.222.201", "114.132.67.16", "118.25.236.72", "123.113.148.8", "124.222.210.29", "154.8.209.16", "157.20.105.71", "162.62.120.167", "164.132.201.202", "172.93.102.9", "175.137.207.82", "175.140.7.89", "178.239.171.97", "18.180.172.93", "180.72.180.53", "185.121.26.7", "185.187.155.10", "2.58.200.5", "2.58.201.66", "202.184.32.249", "202.186.76.249", "36.41.163.157", "42.193.7.57", "42.194.235.96", "43.133.59.151", "43.140.252.45", "43.153.78.32", "43.156.101.68", "43.156.30.210", "43.156.84.96", "43.159.138.253", "43.161.233.17", "43.161.251.101", "43.163.71.148", "45.11.230.10", "45.11.231.30", "45.134.110.25", "45.67.85.139", "46.174.48.20", "46.174.50.13", "46.174.51.200", "47.239.43.116", "47.83.28.85", "49.51.230.98", "49.51.34.109", "74.91.112.162", "74.91.112.169", "74.91.124.246", "8.217.126.121", "8.217.160.56", "81.70.247.179", "82.156.195.10", "93.190.139.252", "94.72.141.139", "96.126.124.92"
)
    "1.117.155.157", "1.12.235.136", "1.13.188.69", "1.15.87.79", "1.15.90.156", "101.33.205.158", "101.43.145.105", "103.131.188.71", "106.52.119.202", "106.52.229.216", "106.53.172.59", "109.236.90.41", "111.230.193.134", "111.230.6.213", "114.132.222.201", "114.132.67.16", "118.25.236.72", "123.113.148.8", "124.222.210.29", "154.8.209.16", "157.20.105.71", "162.62.120.167", "164.132.201.202", "172.93.102.9", "175.137.207.82", "175.140.7.89", "178.239.171.97", "18.180.172.93", "180.72.180.53", "185.121.26.7", "185.187.155.10", "2.58.200.5", "2.58.201.66", "202.184.32.249", "202.186.76.249", "36.41.163.157", "42.193.7.57", "42.194.235.96", "43.133.59.151", "43.140.252.45", "43.153.78.32", "43.156.101.68", "43.156.30.210", "43.156.84.96", "43.159.138.253", "43.161.233.17", "43.161.251.101", "43.163.71.148", "45.11.230.10", "45.11.231.30", "45.134.110.25", "45.67.85.139", "46.174.48.20", "46.174.50.13", "46.174.51.200", "47.239.43.116", "47.83.28.85", "49.51.230.98", "49.51.34.109", "74.91.112.162", "74.91.112.169", "74.91.124.246", "8.217.126.121", "8.217.160.56", "81.70.247.179", "82.156.195.10", "93.190.139.252", "94.72.141.139", "96.126.124.92"
)
    "1.117.155.157", "1.12.235.136", "1.13.188.69", "1.15.87.79", "1.15.90.156", "101.43.145.105", "103.131.188.71", "106.52.119.202", "106.52.229.216", "106.53.172.59", "109.236.90.41", "111.230.193.134", "111.230.6.213", "114.132.222.201", "114.132.67.16", "118.25.236.72", "123.113.148.8", "124.222.210.29", "154.8.209.16", "157.20.105.71", "162.62.120.167", "164.132.201.202", "172.93.102.9", "175.137.207.82", "175.140.7.89", "178.239.171.97", "18.180.172.93", "180.72.180.53", "185.121.26.7", "185.187.155.10", "2.58.200.5", "2.58.201.66", "202.184.32.249", "202.186.76.249", "36.41.163.157", "42.193.7.57", "42.194.235.96", "43.133.59.151", "43.140.252.45", "43.153.78.32", "43.156.101.68", "43.156.30.210", "43.156.84.96", "43.159.138.253", "43.161.233.17", "43.161.251.101", "43.163.71.148", "45.11.230.10", "45.11.231.30", "45.134.110.25", "45.67.85.139", "46.174.48.20", "46.174.50.13", "46.174.51.200", "47.239.43.116", "47.83.28.85", "49.51.230.98", "49.51.34.109", "74.91.112.162", "74.91.112.169", "74.91.124.246", "8.217.126.121", "8.217.160.56", "81.70.247.179", "82.156.195.10", "93.190.139.252", "94.72.141.139", "96.126.124.92"
)
    "1.117.155.157", "1.12.235.136", "1.13.188.69", "1.15.87.79", "1.15.90.156", "103.131.188.71", "106.52.119.202", "106.52.229.216", "106.53.172.59", "109.236.90.41", "111.230.193.134", "111.230.6.213", "114.132.222.201", "114.132.67.16", "118.25.236.72", "124.222.210.29", "154.8.209.16", "157.20.105.71", "162.62.120.167", "172.93.102.9", "175.137.207.82", "175.140.7.89", "178.239.171.97", "18.180.172.93", "180.72.180.53", "185.121.26.7", "185.187.155.10", "2.58.200.5", "2.58.201.66", "202.184.32.249", "202.186.76.249", "36.41.163.157", "42.193.7.57", "42.194.235.96", "43.133.59.151", "43.140.252.45", "43.153.78.32", "43.156.101.68", "43.156.30.210", "43.156.84.96", "43.161.233.17", "43.161.251.101", "43.163.71.148", "45.11.230.10", "45.11.231.30", "45.134.110.25", "45.67.85.139", "46.174.48.20", "46.174.50.13", "46.174.51.200", "47.239.43.116", "47.83.28.85", "49.51.230.98", "49.51.34.109", "74.91.112.162", "74.91.112.169", "74.91.124.246", "8.217.126.121", "8.217.160.56", "81.70.247.179", "82.156.195.10", "93.190.139.252", "94.72.141.139", "96.126.124.92"
)
    "1.117.155.157", "1.12.235.136", "1.13.188.69", "1.15.87.79", "1.15.90.156", "103.131.188.71", "106.52.119.202", "106.52.229.216", "106.53.172.59", "109.236.90.41", "111.230.193.134", "111.230.6.213", "114.132.222.201", "114.132.67.16", "118.25.236.72", "124.222.210.29", "154.8.209.16", "157.20.105.71", "162.62.120.167", "172.93.102.9", "175.137.207.82", "175.140.7.89", "178.239.171.97", "18.180.172.93", "180.72.180.53", "185.121.26.7", "185.187.155.10", "2.58.200.5", "2.58.201.66", "202.184.32.249", "202.186.76.249", "36.41.163.157", "42.193.7.57", "42.194.235.96", "43.133.59.151", "43.140.252.45", "43.153.78.32", "43.156.101.68", "43.156.30.210", "43.156.84.96", "43.161.233.17", "43.161.251.101", "43.163.71.148", "45.11.230.10", "45.11.231.30", "45.134.110.25", "45.67.85.139", "46.174.48.20", "46.174.50.13", "46.174.51.200", "47.239.43.116", "47.83.28.85", "49.51.230.98", "49.51.34.109", "74.91.112.162", "74.91.112.169", "74.91.124.246", "8.217.126.121", "8.217.160.56", "81.70.247.179", "82.156.195.10", "93.190.139.252", "94.72.141.139", "96.126.124.92"
)
    "1.117.155.157", "1.12.235.136", "1.13.188.69", "1.15.87.79", "1.15.90.156", "103.131.188.71", "106.52.119.202", "106.52.229.216", "106.53.172.59", "109.236.90.41", "111.230.193.134", "111.230.6.213", "114.132.222.201", "114.132.67.16", "118.25.236.72", "124.222.210.29", "154.8.209.16", "157.20.105.71", "162.62.120.167", "172.93.102.9", "175.137.207.82", "175.140.7.89", "178.239.171.97", "18.180.172.93", "180.72.180.53", "185.121.26.7", "185.187.155.10", "2.58.200.5", "2.58.201.66", "202.184.32.249", "202.186.76.249", "36.41.163.157", "42.193.7.57", "42.194.235.96", "43.133.59.151", "43.140.252.45", "43.153.78.32", "43.156.101.68", "43.156.30.210", "43.156.84.96", "43.161.233.17", "43.161.251.101", "43.163.71.148", "45.11.230.10", "45.11.231.30", "45.134.110.25", "45.67.85.139", "46.174.48.20", "46.174.50.13", "46.174.51.200", "47.239.43.116", "47.83.28.85", "49.51.230.98", "49.51.34.109", "74.91.112.162", "74.91.112.169", "74.91.124.246", "8.217.126.121", "8.217.160.56", "81.70.247.179", "82.156.195.10", "93.190.139.252", "94.72.141.139", "96.126.124.92"
)
    "1.117.155.157", "1.12.235.136", "1.13.188.69", "1.15.87.79", "1.15.90.156", "103.131.188.71", "106.52.119.202", "106.52.229.216", "106.53.172.59", "109.236.90.41", "111.230.193.134", "111.230.6.213", "114.132.222.201", "114.132.67.16", "118.25.236.72", "124.222.210.29", "154.8.209.16", "157.20.105.71", "162.62.120.167", "172.93.102.9", "175.137.207.82", "175.140.7.89", "178.239.171.97", "18.180.172.93", "180.72.180.53", "185.121.26.7", "185.187.155.10", "2.58.200.5", "2.58.201.66", "202.184.32.249", "202.186.76.249", "36.41.163.157", "42.193.7.57", "42.194.235.96", "43.133.59.151", "43.140.252.45", "43.153.78.32", "43.156.101.68", "43.156.30.210", "43.156.84.96", "43.161.233.17", "43.161.251.101", "43.163.71.148", "45.11.230.10", "45.11.231.30", "45.134.110.25", "45.67.85.139", "46.174.48.20", "46.174.50.13", "46.174.51.200", "47.239.43.116", "47.83.28.85", "49.51.230.98", "49.51.34.109", "74.91.112.162", "74.91.112.169", "74.91.124.246", "8.217.126.121", "8.217.160.56", "81.70.247.179", "82.156.195.10", "93.190.139.252", "94.72.141.139", "96.126.124.92"
)
    "1.117.155.157", "1.12.235.136", "1.13.188.69", "1.15.87.79", "1.15.90.156", "103.131.188.71", "106.52.119.202", "106.52.229.216", "106.53.172.59", "109.236.90.41", "111.230.193.134", "111.230.6.213", "114.132.222.201", "114.132.67.16", "118.25.236.72", "124.222.210.29", "154.8.209.16", "157.20.105.71", "162.62.120.167", "172.93.102.9", "175.137.207.82", "175.140.7.89", "178.239.171.97", "18.180.172.93", "180.72.180.53", "185.121.26.7", "185.187.155.10", "2.58.200.5", "2.58.201.66", "202.184.32.249", "202.186.76.249", "36.41.163.157", "42.193.7.57", "42.194.235.96", "43.133.59.151", "43.140.252.45", "43.153.78.32", "43.156.101.68", "43.156.30.210", "43.156.84.96", "43.161.233.17", "43.161.251.101", "43.163.71.148", "45.11.230.10", "45.11.231.30", "45.134.110.25", "45.67.85.139", "46.174.48.20", "46.174.50.13", "46.174.51.200", "47.239.43.116", "47.83.28.85", "49.51.230.98", "49.51.34.109", "74.91.112.162", "74.91.112.169", "74.91.124.246", "8.217.126.121", "8.217.160.56", "81.70.247.179", "82.156.195.10", "93.190.139.252", "94.72.141.139", "96.126.124.92"
)

Write-Host "=== L4D2 Server IP Blocker ===" -ForegroundColor Cyan
Write-Host "Source: https://steamcommunity.com/sharedfiles/filedetails/?id=3419848194`n" -ForegroundColor Gray

# Main menu
Write-Host "What would you like to do?" -ForegroundColor Yellow
Write-Host "  [1] Block a specific IP address" -ForegroundColor White
Write-Host "  [2] Auto-block all known malicious servers (recommended for first run)" -ForegroundColor White
Write-Host "  [3] Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-3)"

if ($choice -eq "3") {
    Write-Host "Exiting..." -ForegroundColor Yellow
    exit 0
}
elseif ($choice -eq "1") {
    # Manual IP blocking mode
    Write-Host "`n=== Manual IP Blocking Mode ===" -ForegroundColor Cyan
    
    # Show current protection status
    $currentRules = @(Get-NetFirewallRule -DisplayName "1A_L4D2_Block_*" -ErrorAction SilentlyContinue)
    $currentBlockedCount = $currentRules.Count / 2  # Divide by 2 (inbound + outbound)
    Write-Host "Currently blocking: $currentBlockedCount server(s)`n" -ForegroundColor Gray
    
    $manualBlockedCount = 0
    
    while ($true) {
        $IPAddress = Read-Host "`nEnter IP address to block (or 'exit' to quit)"
        
        if ($IPAddress -eq 'exit' -or $IPAddress -eq 'quit' -or $IPAddress -eq 'q') {
            break
        }
        
        if ([string]::IsNullOrWhiteSpace($IPAddress)) {
            continue
        }
        
        # Validate IP address format and range
        if (-not (Test-ValidIP $IPAddress)) {
            Write-Host "ERROR: Invalid IP address. Each octet must be 0-255." -ForegroundColor Red
            continue
        }
        
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $inboundRuleName = "1A_L4D2_Block_${IPAddress}_Inbound"
        $outboundRuleName = "1A_L4D2_Block_${IPAddress}_Outbound"
        
        Write-Host "Blocking IP: $IPAddress..." -ForegroundColor Gray -NoNewline
        
        try {
            New-NetFirewallRule -DisplayName $inboundRuleName `
                -Direction Inbound `
                -Action Block `
                -RemoteAddress $IPAddress `
                -Protocol Any `
                -Enabled True `
                -Profile Any `
                -Description "Blocks L4D2 server at $IPAddress (Manually added: $timestamp)" -ErrorAction Stop | Out-Null
        
            New-NetFirewallRule -DisplayName $outboundRuleName `
                -Direction Outbound `
                -Action Block `
                -RemoteAddress $IPAddress `
                -Protocol Any `
                -Enabled True `
                -Profile Any `
                -Description "Blocks L4D2 server at $IPAddress (Manually added: $timestamp)" -ErrorAction Stop | Out-Null
        
            Write-Host " Blocked" -ForegroundColor Green
            $manualBlockedCount++
        }
        catch {
            if ($_.Exception.Message -match "Cannot create a file when that file already exists") {
                Write-Host " Already blocked" -ForegroundColor Yellow
            }
            else {
                Write-Host " Failed!" -ForegroundColor Red
                Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    Write-Host "`n=== Summary ===" -ForegroundColor Cyan
    Write-Host "  Total IPs blocked: $manualBlockedCount" -ForegroundColor Green
    Write-Host ""
    exit 0
}
elseif ($choice -eq "2") {
    # Auto-block mode
    Write-Host "`n=== Auto-Block Mode ===" -ForegroundColor Cyan
    Write-Host ""

# Fetch IP list from Steam Community (primary source)
Write-Host "[STEP 1] Fetching IP list from Steam Community..." -ForegroundColor Yellow
$knownBadIPs = @()
$usedFallback = $false

try {
    # Suppress progress bar to avoid blue flicker
    $ProgressPreference = 'SilentlyContinue'
    $webContent = Invoke-WebRequest -Uri "https://steamcommunity.com/sharedfiles/filedetails/?id=3419848194" -TimeoutSec 5 -ErrorAction Stop -UseBasicParsing
    $ProgressPreference = 'Continue'
    $pageText = $webContent.Content
    
    # Extract only IPs from the main guide content (not comments)
    # Look for IPs in structured sections before the comments
    $guideSectionMatch = [regex]::Match($pageText, '(?s)IPs To Block.*?(?=<div class="commentthread|$)')
    $guideSection = if ($guideSectionMatch.Success) { $guideSectionMatch.Value } else { $pageText }
    
    # Extract and validate IPs from the guide section only
    $potentialIPs = [regex]::Matches($guideSection, '\b(?:\d{1,3}\.){3}\d{1,3}\b') | ForEach-Object { $_.Value }
    $knownBadIPs = @($potentialIPs | Where-Object { Test-ValidIP $_ } | Sort-Object -Unique)
    
    if ($knownBadIPs.Count -gt 0) {
        Write-Host "  Successfully loaded $($knownBadIPs.Count) IPs from Steam Community" -ForegroundColor Green
    }
    else {
        Write-Host "  No IPs found in guide, using fallback list" -ForegroundColor Yellow
        $knownBadIPs = $fallbackIPs
        $usedFallback = $true
    }
}
catch {
    Write-Host "  Could not reach Steam Community, using fallback list ($($fallbackIPs.Count) IPs)" -ForegroundColor Yellow
    $knownBadIPs = $fallbackIPs
    $usedFallback = $true
}

# Check and block known IPs
Write-Host "`n[STEP 2] Auto-blocking known problematic servers..." -ForegroundColor Yellow
Write-Host "Loading existing rules..." -ForegroundColor Gray -NoNewline

# Get all existing L4D2 rules at once (fast)
$existingRules = @(Get-NetFirewallRule -DisplayName "1A_L4D2_Block_*" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName)

Write-Host " Done!" -ForegroundColor Green
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
    
    # Check if both rules already exist
    $inboundExists = $existingRules -contains $inboundRuleName
    $outboundExists = $existingRules -contains $outboundRuleName
    
    if ($inboundExists -and $outboundExists) {
        Write-Host " Skipped" -ForegroundColor DarkGray
        $skipped++
        continue
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $bothCreated = $true
    
    # Create inbound rule if it doesn't exist
    if (-not $inboundExists) {
        try {
            New-NetFirewallRule -DisplayName $inboundRuleName `
                -Direction Inbound `
                -Action Block `
                -RemoteAddress $ip `
                -Protocol Any `
                -Enabled True `
                -Profile Any `
                -Description "Blocks L4D2 server at $ip (Auto-blocked from known list)" -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Host " Failed (Inbound)!" -ForegroundColor Red
            $failed++
            $bothCreated = $false
        }
    }
    
    # Create outbound rule if it doesn't exist
    if (-not $outboundExists -and $bothCreated) {
        try {
            New-NetFirewallRule -DisplayName $outboundRuleName `
                -Direction Outbound `
                -Action Block `
                -RemoteAddress $ip `
                -Protocol Any `
                -Enabled True `
                -Profile Any `
                -Description "Blocks L4D2 server at $ip (Auto-blocked from known list)" -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Host " Failed (Outbound)!" -ForegroundColor Red
            $failed++
            $bothCreated = $false
        }
    }
    
    if ($bothCreated) {
        Write-Host " Blocked" -ForegroundColor Green
        $newlyBlocked++
    }
}

    Write-Host "`n=== Auto-Block Summary ===" -ForegroundColor Cyan
    Write-Host "  Newly blocked:     $newlyBlocked" -ForegroundColor Green
    Write-Host "  Already protected: $skipped" -ForegroundColor DarkGray
    $totalProtected = $newlyBlocked + $skipped
    Write-Host "  Total protection:  $totalProtected server(s)" -ForegroundColor Cyan
    if ($failed -gt 0) {
        Write-Host "  Failed:            $failed" -ForegroundColor Red
    }
    Write-Host ""
}
else {
    Write-Host "Invalid choice. Please run the script again and select 1, 2, or 3." -ForegroundColor Red
    exit 1
}
