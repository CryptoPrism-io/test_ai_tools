# Auto-Pull Script for CI/CD Pipeline
# This script automatically pulls the latest changes from the remote repository

param(
    [string]$LogFile = "sync_log.csv",
    [switch]$Verbose = $false
)

# Set error action preference
$ErrorActionPreference = "Continue"

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

# Function to write log entries
function Write-SyncLog {
    param(
        [string]$Status,
        [string]$Message,
        [string]$Details = ""
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = [PSCustomObject]@{
        timestamp = $Timestamp
        status = $Status
        message = $Message
        details = $Details
        local_action = "auto-pull"
    }
    
    # Check if log file exists, create with headers if not
    if (-not (Test-Path $LogFile)) {
        "timestamp,status,message,details,local_action" | Out-File -FilePath $LogFile -Encoding UTF8
    }
    
    # Append log entry
    "$($LogEntry.timestamp),$($LogEntry.status),$($LogEntry.message),$($LogEntry.details),$($LogEntry.local_action)" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    
    if ($Verbose) {
        $Color = if ($Status -eq "SUCCESS") { "Green" } elseif ($Status -eq "ERROR") { "Red" } else { "Yellow" }
        Write-Host "[$Timestamp] ${Status}: $Message" -ForegroundColor $Color
    }
}

# Main execution
try {
    Write-SyncLog -Status "INFO" -Message "Starting auto-pull process"
    
    # Check if we're in a git repository
    $gitStatus = git status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-SyncLog -Status "ERROR" -Message "Not in a git repository" -Details $gitStatus
        exit 1
    }
    
    # Check for local changes
    $localChanges = git status --porcelain
    if ($localChanges) {
        Write-SyncLog -Status "WARNING" -Message "Local changes detected, stashing before pull" -Details $localChanges
        git stash push -m "Auto-stash before pull - $(Get-Date)"
    }
    
    # Fetch latest changes
    Write-SyncLog -Status "INFO" -Message "Fetching from remote repository"
    $fetchResult = git fetch origin 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-SyncLog -Status "ERROR" -Message "Failed to fetch from remote" -Details $fetchResult
        exit 1
    }
    
    # Check if there are new commits to pull
    $behindCount = git rev-list --count HEAD..origin/master 2>$null
    
    if ($behindCount -and $behindCount -gt 0) {
        Write-SyncLog -Status "INFO" -Message "Pulling $behindCount new commits from remote"
        
        # Pull changes
        $pullResult = git pull origin master 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-SyncLog -Status "SUCCESS" -Message "Successfully pulled $behindCount commits" -Details $pullResult
            
            # If we stashed changes, try to apply them back
            if ($localChanges) {
                $stashResult = git stash pop 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-SyncLog -Status "SUCCESS" -Message "Successfully restored local changes"
                } else {
                    Write-SyncLog -Status "WARNING" -Message "Conflict restoring local changes" -Details $stashResult
                }
            }
        } else {
            Write-SyncLog -Status "ERROR" -Message "Failed to pull changes" -Details $pullResult
            exit 1
        }
    } else {
        Write-SyncLog -Status "INFO" -Message "Repository already up to date"
    }
    
    Write-SyncLog -Status "SUCCESS" -Message "Auto-pull process completed successfully"
    
} catch {
    Write-SyncLog -Status "ERROR" -Message "Unexpected error during auto-pull" -Details $_.Exception.Message
    exit 1
}

# Clean up old log entries (keep last 100 entries)
try {
    $logContent = Get-Content $LogFile
    if ($logContent.Count -gt 101) {  # 100 entries + header
        $header = $logContent[0]
        $recentEntries = $logContent[-100..-1]
        @($header) + $recentEntries | Set-Content $LogFile
        Write-SyncLog -Status "INFO" -Message "Cleaned up old log entries"
    }
} catch {
    # Ignore cleanup errors
}