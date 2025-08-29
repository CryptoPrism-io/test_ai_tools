# CI/CD Pipeline Setup Guide

## Overview
This repository now includes a complete CI/CD pipeline that:
- ✅ Runs Python script every 5 minutes on GitHub Actions
- ✅ Automatically commits CSV updates with detailed messages
- ✅ Automatically pulls latest changes to your local repository every 6 minutes
- ✅ Logs all sync operations locally

## Architecture
```
GitHub Actions (every 5min) → Commits to repo → Local pulls (every 6min) → Sync complete
```

## Files Created

### 1. GitHub Workflow
- **File**: `.github/workflows/run-script.yml`
- **Purpose**: Runs `test_hello.py` every 5 minutes and commits CSV updates
- **Features**: 
  - Enhanced commit messages with process status
  - Conflict detection and handling
  - UTC timestamps in commit messages

### 2. PowerShell Auto-Pull Script
- **File**: `auto-pull.ps1`
- **Purpose**: Automatically pulls latest changes from GitHub
- **Features**:
  - Detects and stashes local changes before pulling
  - Comprehensive error handling and logging
  - Automatic log cleanup (keeps last 100 entries)
  - Verbose output option for debugging

### 3. Task Scheduler Setup
- **File**: `setup-task-scheduler.bat`
- **Purpose**: Creates Windows scheduled task for auto-pull
- **Schedule**: Every 6 minutes (offset from GitHub's 5-minute schedule)

### 4. Sync Logging
- **File**: `sync_log.csv` (auto-generated)
- **Purpose**: Tracks all local pull operations
- **Columns**: timestamp, status, message, details, local_action

## Setup Instructions

### Step 1: Automatic Setup (Recommended)
1. Run the batch file as Administrator:
   ```cmd
   setup-task-scheduler.bat
   ```
2. The scheduled task will be created and start running automatically

### Step 2: Manual Setup (Alternative)
1. Open Task Scheduler (`taskschd.msc`)
2. Create Basic Task with these settings:
   - **Name**: GitAutoPull_CPIO
   - **Trigger**: Daily, repeat every 6 minutes
   - **Action**: Start a program
   - **Program**: `powershell.exe`
   - **Arguments**: `-ExecutionPolicy Bypass -File "C:\path\to\auto-pull.ps1"`

## Verification

### Check GitHub Actions
1. Visit: https://github.com/CryptoPrism-io/test_ai_tools/actions
2. Verify workflows are running every 5 minutes

### Check Local Sync
1. Monitor `sync_log.csv` for pull operations
2. Run manually: `powershell -ExecutionPolicy Bypass -File auto-pull.ps1 -Verbose`

### Check Task Scheduler
1. View task: `schtasks /query /tn "GitAutoPull_CPIO"`
2. Run manually: `schtasks /run /tn "GitAutoPull_CPIO"`

## File Status

### Tracked by Git
- `test_hello.py` - Main Python script
- `execution_log.csv` - Remote execution log
- `sync_log.csv` - Local sync log
- `.github/workflows/run-script.yml` - GitHub workflow
- `auto-pull.ps1` - PowerShell script
- `setup-task-scheduler.bat` - Task scheduler setup

### Ignored by Git
- `.env` - Environment variables (contains secrets)

## Troubleshooting

### Common Issues
1. **PowerShell execution policy**: Run as Administrator or use `-ExecutionPolicy Bypass`
2. **Git authentication**: Ensure GitHub CLI is properly authenticated
3. **Task scheduler permissions**: Run setup batch file as Administrator
4. **Merge conflicts**: Script automatically stashes local changes before pulling

### Logs to Check
- `sync_log.csv` - Local sync operations
- GitHub Actions logs - Remote execution status
- Windows Event Viewer - Task scheduler events

## Monitoring

### CSV Files
- `execution_log.csv` - Updates every 5 minutes (remote)
- `sync_log.csv` - Updates every 6 minutes (local)

### Commands
```cmd
# View scheduled task
schtasks /query /tn "GitAutoPull_CPIO"

# Test PowerShell script
powershell -ExecutionPolicy Bypass -File auto-pull.ps1 -Verbose

# Check git status
git status

# View recent commits
git log --oneline -10
```

## Success Indicators
- ✅ New entries in `execution_log.csv` every 5 minutes
- ✅ New entries in `sync_log.csv` every 6 minutes  
- ✅ GitHub commits with "🚀 Automated execution log update" messages
- ✅ Local repository stays synchronized with remote changes
- ✅ No merge conflicts in sync logs

The CI/CD pipeline is now complete and running automatically!