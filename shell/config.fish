#  ~/.config/fish/config.fish
#  Fast DevOps-oriented Fish configuration – lazy-load heavy stuff,
#  zero network calls on startup, oh-my-posh removed.

if status is-interactive
    # ------------------------------------------------------------------
    # 1.  Instant essentials
    # ------------------------------------------------------------------
    set fish_greeting ""                       # no greeting = 0 ms
    fish_add_path -p $HOME/.local/bin \
                  $HOME/.volta/bin \
                  $HOME/.asdf/shims

    set -gx VOLTA_HOME  $HOME/.volta
    set -gx EDITOR      code
    set -g fish_history_max 20000

    # ------------------------------------------------------------------
    # 2.  FAST prompt (no oh-my-posh)
    # ------------------------------------------------------------------
    function fish_prompt
        set_color cyan
        echo -n (basename (prompt_pwd))
        set_color normal

        # cheap git branch (cached by fish_git_prompt if you prefer)
        if git rev-parse --git-dir >/dev/null 2>&1
            set -l branch (git branch --show-current 2>/dev/null)
            and begin
                set_color yellow
                echo -n " ($branch)"
                set_color normal
            end
        end
        echo -n ' ❯ '
    end

    fish_vi_key_bindings

    # ------------------------------------------------------------------
    # 3.  One-shot lazy loader (fires only on first prompt)
    # ------------------------------------------------------------------
    function __lazy_devops --on-event fish_prompt
        functions -e __lazy_devops          # remove immediately

        # ASDF
        test -f ~/.asdf/asdf.fish; and source ~/.asdf/asdf.fish &

        # FZF
        if command -q fzf
            set -gx FZF_DEFAULT_OPTS \
                "--height=50% --layout=reverse --border=rounded --margin=1,2 --padding=1 --info=inline --prompt='❯ ' --pointer='▶' --marker='✓' --color=bg+:#2d3748,bg:#1a202c,spinner:#81e6d9,hl:#81e6d9 --color=fg:#e2e8f0,header:#81e6d9,info:#81e6d9,pointer:#81e6d9 --color=marker:#81e6d9,fg+:#ffffff,prompt:#81e6d9,hl+:#81e6d9"
            set -gx FZF_CTRL_R_OPTS "--preview 'echo {}' --preview-window down:3:wrap --bind 'ctrl-y:execute-silent(echo {} | xclip -selection clipboard)+abort' --header 'Press CTRL-Y to copy'"
            fzf --fish | source &
        end

        # Completions
        complete -c docker &
        complete -c kubectl &
        complete -c git &
    end

    # ------------------------------------------------------------------
    # 4.  Context banner – also deferred to first prompt
    # ------------------------------------------------------------------
    function __show_ctx_once --on-event fish_prompt
        functions -e __show_ctx_once
        command -q kubectl; and set -l k (timeout 1 kubectl config current-context 2>/dev/null)
        test -n "$k"; and echo "☸️  $k" | set_color blue
    end

    # ------------------------------------------------------------------
    # 5.  Minimal startup banner (no external commands)
    # ------------------------------------------------------------------
    echo "🚀 DevOps Shell Ready" | set_color cyan
    echo "Type 'help' for commands" | set_color normal
    echo
end

# ==================================================================
# 6.  Aliases (instant)
# ==================================================================
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ls='ls --color=auto'

command -q bat; and alias cat='bat --style=plain'
command -q fd; and alias find='fd'
command -q exa; and alias ll='exa -la'

# Git
alias g='git'
alias gst='git status'
alias glog='git log --oneline -10'
alias gpush='git push'
alias gpull='git pull'
alias gcom='git commit'
alias gco='git checkout'
alias gbr='git branch'
alias gd='git diff'
alias ga='git add'
alias gaa='git add .'
alias gcm='git commit -m'
alias gacm='git add . && git commit -m'

# Docker
command -q docker; and begin
    alias d='docker'
    alias dc='docker-compose'
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias di='docker images'
    alias dex='docker exec -it'
    alias dlog='docker logs -f'
    alias drm='docker rm'
    alias drmi='docker rmi'
end

# Kubernetes
command -q kubectl; and begin
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgs='kubectl get services'
    alias kgd='kubectl get deployments'
    alias kgn='kubectl get nodes'
    alias kaf='kubectl apply -f'
    alias kdf='kubectl delete -f'
    alias kdesc='kubectl describe'
    alias klog='kubectl logs -f'
    alias kex='kubectl exec -it'
end

# Terraform
command -q terraform; and begin
    alias tf='terraform'
    alias tfi='terraform init'
    alias tfp='terraform plan'
    alias tfa='terraform apply'
    alias tfd='terraform destroy'
    alias tfv='terraform validate'
    alias tff='terraform fmt'
    alias tfs='terraform show'
end

# ==================================================================
# 7.  Helper functions
# ==================================================================
function ..      ; cd ..      ; end
function ...     ; cd ../..   ; end
function ....    ; cd ../../.. ; end

function mkcd
    mkdir -p $argv[1]; and cd $argv[1]
    echo "Created and moved to: $argv[1]" | set_color green; cat; set_color normal
end

function touch
    if test -e $argv[1]
        command touch $argv[1]
        echo "Updated: $argv[1]" | set_color yellow; cat; set_color normal
    else
        command touch $argv[1]
        echo "Created: $argv[1]" | set_color green; cat; set_color normal
    end
end

function ff
    count $argv -eq 0; and echo "Usage: ff <name>"; and return 1
    if command -q fd
        fd -H $argv[1] 2>/dev/null | head -20
    else
        find . -name "*$argv[1]*" -type f 2>/dev/null | head -20
    end
end

function get_public_ip
    command -q curl; and curl -s --max-time 3 https://api.ipify.org
end

function test_connectivity
    count $argv -eq 0; and echo "Usage: test_connectivity <host> [port]"; and return 1
    set -l host $argv[1]; set -l port 80
    test (count $argv) -gt 1; and set port $argv[2]
    command -q nc; and timeout 5 nc -zv $host $port
end

# Docker helpers
function docker_cleanup
    command -q docker; and docker system prune -f; and docker volume prune -f
end
function docker_stats_live
    command -q docker; and docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
end

# Kubernetes helpers
function k_ctx
    command -q kubectl; and kubectl config current-context
end
function k_ns
    if test (count $argv) -gt 0
        kubectl config set-context --current --namespace=$argv[1]
    else
        kubectl config view --minify -o jsonpath='{..namespace}'
    end
end
function k_pods
    command -q kubectl; and kubectl get pods --all-namespaces -o wide
end
function k_logs
    count $argv -eq 0; and echo "Usage: k_logs <pod> [--follow|-f]"; and return 1
    if contains -- --follow $argv; or contains -- -f $argv
        kubectl logs -f $argv[1]
    else
        kubectl logs $argv[1]
    end
end

# Git helpers
function git_status_all
    for dir in */
        test -d $dir/.git; and pushd $dir; and set_color cyan; echo "📁 "(basename $dir); set_color normal; git status --porcelain; popd
    end
end
function git_branch_clean
    echo "Cleaning merged branches..."
    git branch --merged | grep -v "main\|master\|\*" | xargs -n 1 git branch -d 2>/dev/null
    echo "Branches cleaned!"
end

# System
function sysinfo
    echo "🖥️  System Info"
    echo "=============="
    command -q uname; and echo "OS: "(uname -s)" "(uname -r)
    command -q free; and echo "Memory:"; and free -h | head -3
    command -q df; and echo "Disk:"; and df -h / | tail -1
    test -f /proc/uptime; and echo "Uptime: "(math round (cat /proc/uptime | cut -d' ' -f1)/3600)" hours"
end
function hist
    if test (count $argv) -gt 0
        history | grep -i $argv[1] | tail -30
    else
        history | tail -30
    end
end

# Config management
function reload_config
    source ~/.config/fish/config.fish
    echo "🔄 Config reloaded!"
end
function edit_config
    command -q code; and code ~/.config/fish/config.fish; or $EDITOR ~/.config/fish/config.fish
end
function devops_help
    echo "🚀 DevOps Fish Shell - Quick Reference"
    echo "======================================"
    echo "Navigation:  ..  ...  ....  mkcd  ff"
    echo "Git:         g  gst  glog  gpush  gpull  gcom  gco  gbr  git_status_all  git_branch_clean"
    echo "Docker:      d  dc  dps  di  dex  dlog  docker_cleanup  docker_stats_live"
    echo "Kubernetes:  k  kgp  kgs  kgd  k_ctx  k_ns  k_pods  k_logs"
    echo "Terraform:   tf  tfi  tfp  tfa  tfd  tfv  tff  tfs"
    echo "System:      sysinfo  get_public_ip  test_connectivity  hist"
    echo "Config:      reload_config  edit_config  devops_help"
end
alias help='devops_help'
