# L4D2 Server Blocker

A PowerShell script to automatically block problematic Left 4 Dead 2 servers using Windows Firewall rules.

## About

This tool helps protect L4D2 players from malicious servers that:
- Expose player IP addresses in console
- Display inappropriate content (Lewd4Dead, etc.)
- Crash games with exploits
- Impersonate official Valve servers

The script automatically blocks 54 known problematic server IPs and provides an interactive mode to block additional servers you discover.

## Credits

Based on the Steam Community guide: [L4D2 Chemotherapy - Blocking Cancerous Servers](https://steamcommunity.com/sharedfiles/filedetails/?id=3419848194) by Noosent.

## Features

- ✅ **Auto-blocks 54 known malicious servers** from the community list
- ✅ **Smart detection** - skips IPs that are already blocked
- ✅ **Interactive mode** - easily add new IPs as you discover them
- ✅ **Detailed reporting** - see what was blocked and what was already protected
- ✅ **Safety checks** - validates IP format and requires administrator privileges
- ✅ **Named rules** - uses "1A_" prefix for easy identification in Windows Firewall

## Requirements

- **Windows 10/11** (or Windows Server with PowerShell)
- **PowerShell 5.1+** (included by default in Windows 10/11)
- **Administrator privileges** (required to modify firewall rules)

## Installation

1. Download `block-l4d2-server.ps1` from this repository
2. Save it anywhere on your computer (Desktop, Documents, etc.)

## Usage

### Running the Script

1. **Right-click PowerShell** and select **"Run as Administrator"**
2. Navigate to the script location:
   ```powershell
   cd C:\Path\To\Script
   ```
3. Run the script:
   ```powershell
   .\block-l4d2-server.ps1
   ```

### Menu Options

When you run the script, you'll see a menu:

```
What would you like to do?
  [1] Block a specific IP address
  [2] Auto-block all known malicious servers (recommended for first run)
  [3] Exit
```

**Option 1 - Manual IP Blocking:**
- Block specific IPs you discover while playing
- Enter IP addresses one at a time
- Type `exit` when done

**Option 2 - Auto-Block (Recommended for first time):**
- Checks Steam Community for latest IP updates
- Auto-blocks all 54+ known malicious servers
- Shows real-time progress
- Skips IPs already blocked

### Running Again

The script is **idempotent** - you can run it as many times as you want. It will:
- Skip IPs that are already blocked
- Only create rules for new IPs
- Show you what's already protected

<img width="822" height="215" alt="image" src="https://github.com/user-attachments/assets/fc9f3a25-6978-4485-b3a7-a8713ffcab97" />
<img width="705" height="1687" alt="image" src="https://github.com/user-attachments/assets/9a14c96c-a356-4901-8595-eaf681682511" />
<img width="736" height="1555" alt="image" src="https://github.com/user-attachments/assets/dd8c686e-e199-4725-8257-3cd27c284751" />

## How to Find Server IPs to Block

While in-game:
1. Open the developer console (usually `~` key)
2. Type `status` and press Enter
3. Look for the server IP in the output
4. If it's a problematic server, add it using this script

## What Gets Blocked

The script blocks these categories of servers:
- **Lewd4Dead servers** - inappropriate content servers
- **XPMod servers** - servers that expose player IPs
- **Fake Valve servers** - malicious servers pretending to be official
- **Doxing servers** - servers that expose player IPs and locations
- **Crash/modded servers** - servers with heavy mods which may crash your game

Full list of 54 IPs is maintained in the script based on community reports.

## Uninstalling / Removing Rules

To remove the firewall rules:

1. Open **Windows Defender Firewall with Advanced Security**
2. Go to **Inbound Rules** and **Outbound Rules**
3. Look for rules starting with `1A_L4D2_Block_`
4. Delete the rules you want to remove

Or use PowerShell:
```powershell
# Remove all L4D2 blocking rules
Get-NetFirewallRule -DisplayName "1A_L4D2_Block_*" | Remove-NetFirewallRule
```

## Troubleshooting

### "Script cannot be loaded because running scripts is disabled"

You need to allow script execution:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "ERROR: This script must be run as Administrator!"

You must run PowerShell as Administrator:
1. Search for "PowerShell" in Start Menu
2. Right-click and select "Run as Administrator"

### Rules aren't blocking servers

Make sure Windows Firewall is enabled and active for your network profile (Private/Public).

## Found a New Problematic Server?

The script automatically checks the [Steam Community guide](https://steamcommunity.com/sharedfiles/filedetails/?id=3419848194) for updates every time you run it.

**Important:** Only IPs added to the main guide content (approved by the guide author) are automatically scanned. Comments are NOT scanned to prevent malicious actors from adding legitimate IPs.

If you discover a new malicious server:
1. **Block it immediately** using **Option 1** (Manual IP Blocking) in the script
2. **Post the IP in the comments** of the Steam Community guide with details about why it's problematic
3. Once the guide author adds it to the main guide, the script will automatically pick it up
4. Your comment helps other users who may not have blocked it yet

This workflow protects you immediately while helping the entire L4D2 community.

## License

This project is released into the public domain. Use it freely to protect yourself and others from problematic L4D2 servers.

## Disclaimer

This script modifies your Windows Firewall rules. While it only adds blocking rules and doesn't remove existing protections, use at your own risk. Always run scripts from trusted sources.
