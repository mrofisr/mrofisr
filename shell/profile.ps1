#aws ecr get-login-password --region ap-southeast-1 --profile askdea | docker login --username AWS --password-stdin 891377385085.dkr.ecr.ap-southeast-1.amazonaws.com >$null 2>&1
#region Module Imports
# Import essential modules with error handling
$modules = @('Terminal-Icons', 'PSReadLine', 'PSFzf', 'Pester', 'PowerShellGet')
foreach ($module in $modules) {
    try {
        Import-Module -Name $module -ErrorAction Stop -Force
        Write-Host "✓ $module" -ForegroundColor Green -NoNewline
        Write-Host " loaded" -ForegroundColor DarkGray
    }
    catch {
        Write-Host "✗ $module" -ForegroundColor Red -NoNewline
        Write-Host " failed" -ForegroundColor DarkGray
    }
}
#endregion

#region PSFzf Configuration
if (Get-Module -Name PSFzf) {
    # Enhanced fuzzy finder options
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PsFzfOption -EnableAliasFuzzyEdit -EnableAliasFuzzyHistory -EnableAliasFuzzyKillProcess
    Set-PsFzfOption -EnableAliasFuzzySetLocation -EnableAliasFuzzyScoop
    
    # Enhanced fzf options for better UI
    $env:FZF_DEFAULT_OPTS = @"
--height=50% 
--layout=reverse 
--border=rounded 
--margin=1,2 
--padding=1 
--info=inline 
--prompt='❯ ' 
--pointer='▶' 
--marker='✓' 
--color=bg+:#2d3748,bg:#1a202c,spinner:#81e6d9,hl:#81e6d9 
--color=fg:#e2e8f0,header:#81e6d9,info:#81e6d9,pointer:#81e6d9 
--color=marker:#81e6d9,fg+:#ffffff,prompt:#81e6d9,hl+:#81e6d9 
--bind='ctrl-u:preview-up,ctrl-d:preview-down' 
--bind='ctrl-f:preview-page-down,ctrl-b:preview-page-up' 
--preview-window=right:50%:wrap
"@

    # Enhanced history search with preview
    $env:FZF_CTRL_R_OPTS = @"
--preview 'echo {+}' 
--preview-window down:3:wrap 
--bind 'ctrl-y:execute-silent(echo {+} | clip)+abort' 
--color header:italic 
--header 'Press CTRL-Y to copy command into clipboard'
"@
}
#endregion

#region PSReadLine Configuration
if (Get-Module -Name PSReadLine) {
    # Enhanced history and prediction
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -MaximumHistoryCount 10000
    Set-PSReadLineOption -HistoryNoDuplicates
    Set-PSReadLineOption -HistorySearchCaseSensitive:$false
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -ShowToolTips

    # DevOps-focused key bindings
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key 'Ctrl+d' -Function DeleteChar
    Set-PSReadLineKeyHandler -Key 'Ctrl+w' -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Key 'Alt+d' -Function DeleteWord
    Set-PSReadLineKeyHandler -Key 'Ctrl+LeftArrow' -Function BackwardWord
    Set-PSReadLineKeyHandler -Key 'Ctrl+RightArrow' -Function ForwardWord
    Set-PSReadLineKeyHandler -Key 'Ctrl+k' -Function DeleteToEnd
    Set-PSReadLineKeyHandler -Key 'Ctrl+u' -Function DeleteLineToFirstChar

    # Syntax highlighting for better code readability
    Set-PSReadLineOption -Colors @{
        Command            = 'Cyan'
        Parameter          = 'Gray'
        Operator           = 'Magenta'
        Variable           = 'Green'
        String             = 'Yellow'
        Number             = 'Red'
        Type               = 'DarkCyan'
        Comment            = 'DarkGreen'
        Keyword            = 'Blue'
        Error              = 'Red'
        Selection          = 'DarkGray'
        InlinePrediction   = 'DarkGray'
    }
}
#endregion

#region Core Aliases
# File system operations
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value 'Get-ChildItem -Force'
Set-Alias -Name grep -Value Select-String
Set-Alias -Name touch -Value New-Item
Set-Alias -Name which -Value Get-Command
Set-Alias -Name cat -Value Get-Content
Set-Alias -Name wget -Value Invoke-WebRequest
Set-Alias -Name curl -Value Invoke-RestMethod

# Git shortcuts
Set-Alias -Name g -Value git
Set-Alias -Name gst -Value 'git status'
Set-Alias -Name glog -Value 'git log --oneline -10'
Set-Alias -Name gpush -Value 'git push'
Set-Alias -Name gpull -Value 'git pull'
Set-Alias -Name gcom -Value 'git commit'
Set-Alias -Name gco -Value 'git checkout'
Set-Alias -Name gbr -Value 'git branch'

# Docker shortcuts
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Set-Alias -Name d -Value docker
    Set-Alias -Name dc -Value docker-compose
    Set-Alias -Name dps -Value 'docker ps'
    Set-Alias -Name di -Value 'docker images'
}

# Kubernetes shortcuts
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    Set-Alias -Name k -Value kubectl
    Set-Alias -Name kgp -Value 'kubectl get pods'
    Set-Alias -Name kgs -Value 'kubectl get services'
    Set-Alias -Name kgd -Value 'kubectl get deployments'
    Set-Alias -Name kaf -Value 'kubectl apply -f'
    Set-Alias -Name kdf -Value 'kubectl delete -f'
}

# Terraform shortcuts
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    Set-Alias -Name tf -Value terraform
    Set-Alias -Name tfi -Value 'terraform init'
    Set-Alias -Name tfp -Value 'terraform plan'
    Set-Alias -Name tfa -Value 'terraform apply'
    Set-Alias -Name tfd -Value 'terraform destroy'
    Set-Alias -Name tfv -Value 'terraform validate'
    Set-Alias -Name tff -Value 'terraform fmt'
}
#endregion

#region DevOps Utility Functions
# Enhanced directory navigation
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }
function cd~ { Set-Location ~ }
function cdtemp { Set-Location $env:TEMP }

# Create and enter directory
function mkcd {
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
    Write-Host "Created and moved to: $Path" -ForegroundColor Green
}

# Enhanced file operations
function touch {
    param([string]$Path)
    if (Test-Path $Path) {
        (Get-Item $Path).LastWriteTime = Get-Date
        Write-Host "Updated timestamp: $Path" -ForegroundColor Yellow
    } else {
        New-Item -ItemType File -Path $Path -Force | Out-Null
        Write-Host "Created file: $Path" -ForegroundColor Green
    }
}

# Quick file finding
function ff {
    param(
        [string]$Name,
        [string]$Path = "."
    )
    Get-ChildItem -Path $Path -Recurse -Name "*$Name*" -ErrorAction SilentlyContinue | 
    Select-Object -First 20
}

# Process management
function Get-ProcessTree {
    param([string]$ProcessName)
    Get-Process | Where-Object { $_.ProcessName -like "*$ProcessName*" } | 
    Select-Object Id, ProcessName, CPU, WorkingSet, Path
}

function Kill-ProcessByName {
    param([string]$ProcessName)
    Get-Process -Name "*$ProcessName*" | Stop-Process -Force
    Write-Host "Killed processes matching: $ProcessName" -ForegroundColor Red
}

# Network utilities
function Get-PublicIP {
    try {
        $ip = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5).Trim()
        Write-Host "Public IP: $ip" -ForegroundColor Cyan
        return $ip
    }
    catch {
        Write-Warning "Failed to get public IP"
    }
}

function Test-Connectivity {
    param(
        [string]$Target,
        [int]$Port = 80
    )
    Test-NetConnection -ComputerName $Target -Port $Port -InformationLevel Detailed
}

# System information for monitoring
function Get-SystemInfo {
    $cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1
    $memory = Get-CimInstance -ClassName Win32_ComputerSystem
    $disk = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object DriveType -eq 3
    
    [PSCustomObject]@{
        CPU = $cpu.Name
        Cores = $cpu.NumberOfCores
        RAM_GB = [math]::Round($memory.TotalPhysicalMemory / 1GB, 2)
        Disks = $disk | Select-Object DeviceID, @{Name="Size_GB";Expression={[math]::Round($_.Size / 1GB, 2)}}, @{Name="Free_GB";Expression={[math]::Round($_.FreeSpace / 1GB, 2)}}
        Uptime = (Get-Date) - (Get-CimInstance -ClassName win32_operatingsystem).LastBootUpTime
    }
}

# Docker utilities
function docker-cleanup {
    Write-Host "Cleaning up Docker..." -ForegroundColor Yellow
    docker system prune -f
    docker volume prune -f
    docker network prune -f
    Write-Host "Docker cleanup completed" -ForegroundColor Green
}

function docker-stats-live {
    docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# Kubernetes utilities
function k-ctx {
    kubectl config current-context
}

function k-ns {
    param([string]$Namespace)
    if ($Namespace) {
        kubectl config set-context --current --namespace=$Namespace
        Write-Host "Switched to namespace: $Namespace" -ForegroundColor Green
    } else {
        kubectl config view --minify --output 'jsonpath={..namespace}'
    }
}

function k-pods {
    kubectl get pods --all-namespaces -o wide
}

function k-logs {
    param(
        [string]$PodName,
        [switch]$Follow
    )
    if ($Follow) {
        kubectl logs -f $PodName
    } else {
        kubectl logs $PodName
    }
}

# Git utilities
function git-status-all {
    Get-ChildItem -Directory | ForEach-Object {
        if (Test-Path "$($_.FullName)\.git") {
            Push-Location $_.FullName
            Write-Host "`n📁 $($_.Name)" -ForegroundColor Cyan
            git status --porcelain
            Pop-Location
        }
    }
}

function git-branch-clean {
    Write-Host "Cleaning up merged branches..." -ForegroundColor Yellow
    git branch --merged | Where-Object { $_ -notmatch "main|master|\*" } | ForEach-Object { 
        git branch -d $_.Trim() 
    }
    Write-Host "Branch cleanup completed" -ForegroundColor Green
}



# Enhanced history search
function hist {
    param([string]$Pattern = "")
    if ($Pattern) {
        Get-History | Where-Object CommandLine -Like "*$Pattern*" | Select-Object -Last 30 | Format-Table Id, @{Name="Command";Expression={$_.CommandLine.Substring(0, [Math]::Min(80, $_.CommandLine.Length))}}
    } else {
        Get-History | Select-Object -Last 30 | Format-Table Id, @{Name="Command";Expression={$_.CommandLine.Substring(0, [Math]::Min(80, $_.CommandLine.Length))}}
    }
}

# Profile management
function Edit-Profile {
    code $PROFILE
}

function Reload-Profile {
    Clear-Host
    & $PROFILE
}
Set-Alias -Name reload -Value Reload-Profile
Set-Alias -Name edit-profile -Value Edit-Profile

# Quick help function
function devops-help {
    Write-Host "`n🚀 DevOps PowerShell Profile - Quick Reference" -ForegroundColor Cyan
    Write-Host "==============================================`n" -ForegroundColor DarkCyan
    
    Write-Host "📁 Navigation:" -ForegroundColor Yellow
    Write-Host "  .., ..., .... - Go up directories"
    Write-Host "  mkcd <path>   - Create and enter directory"
    Write-Host "  ff <name>     - Find files"
    
    Write-Host "`n🐙 Git:" -ForegroundColor Yellow
    Write-Host "  g, gs, gl, gp, gpl - Git shortcuts"
    Write-Host "  git-status-all     - Check status of all repos"
    Write-Host "  git-branch-clean   - Clean merged branches"
    
    Write-Host "`n🐳 Docker:" -ForegroundColor Yellow
    Write-Host "  d, dc, dps, di     - Docker shortcuts"
    Write-Host "  docker-cleanup     - Clean up Docker resources"
    Write-Host "  docker-stats-live  - Live container stats"
    
    Write-Host "`n☸️  Kubernetes:" -ForegroundColor Yellow
    Write-Host "  k, kgp, kgs, kgd   - kubectl shortcuts"
    Write-Host "  k-ctx, k-ns        - Context and namespace management"
    Write-Host "  k-pods, k-logs     - Pod operations"
    
    Write-Host "`n🏗️  Terraform:" -ForegroundColor Yellow
    Write-Host "  tf, tfi, tfp, tfa  - Terraform shortcuts"
    
    Write-Host "`n🔧 System:" -ForegroundColor Yellow
    Write-Host "  sysinfo           - System information"
    Write-Host "  Get-PublicIP      - Get public IP address"
    Write-Host "  Test-Connectivity - Test network connectivity"
    
    Write-Host "`n📚 Profile:" -ForegroundColor Yellow
    Write-Host "  reload       - Reload this profile"
    Write-Host "  edit-profile - Edit profile in VS Code"
    Write-Host "  devops-help  - Show this help"
    Write-Host ""
}
Set-Alias -Name help -Value devops-help
#endregion

#region Oh My Posh Configuration
# Initialize Oh My Posh with a clean, informative prompt
try {
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        # Use a built-in theme optimized for development
        oh-my-posh init powershell --config "$env:POSH_THEMES_PATH\agnoster.omp.json" | Invoke-Expression
        Write-Host "✓ Oh My Posh" -ForegroundColor Green -NoNewline
        Write-Host " loaded" -ForegroundColor DarkGray
    }
}
catch {
    Write-Host "✗ Oh My Posh" -ForegroundColor Red -NoNewline
    Write-Host " failed" -ForegroundColor DarkGray
}
#endregion

#region Startup Message
Clear-Host
Write-Host "🚀 DevOps PowerShell Profile Loaded" -ForegroundColor Cyan
Write-Host "Type " -ForegroundColor Gray -NoNewline
Write-Host "devops-help" -ForegroundColor Yellow -NoNewline
Write-Host " for quick reference" -ForegroundColor Gray

# Show current context information
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    $k8sContext = kubectl config current-context 2>$null
    if ($k8sContext) {
        Write-Host "☸️  Kubernetes: " -ForegroundColor Blue -NoNewline
        Write-Host $k8sContext -ForegroundColor White
    }
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitBranch = git branch --show-current 2>$null
    if ($gitBranch) {
        Write-Host "🐙 Git Branch: " -ForegroundColor Green -NoNewline
        Write-Host $gitBranch -ForegroundColor White
    }
}

Write-Host ""
#endregion
