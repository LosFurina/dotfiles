# ============================================
# Zsh Configuration - Consolidated
# ============================================
# 适配 macOS、Arch、Debian 的通用配置

# 调试模式（取消注释以启用）
# export ZSHRC_DEBUG=1
[[ -n "$ZSHRC_DEBUG" ]] && echo "[DEBUG] Loading .zshrc..."

# 启动展示（必须在 P10k instant prompt 之前）
command -v fastfetch >/dev/null && fastfetch

# P10k 瞬时提示
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ============================================
# 平台检测
# ============================================

# 检测操作系统
if [[ "$(uname)" == "Darwin" ]]; then
    export OS_TYPE="macos"
    export OS_ARCH="$(uname -m)"
elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    export OS_TYPE="$ID"
else
    export OS_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
fi

# ============================================
# Homebrew 配置 (macOS)
# ============================================

if [[ "$OS_TYPE" == "macos" ]]; then
    # 根据架构选择 Homebrew 路径
    if [[ "$OS_ARCH" == "arm64" ]]; then
        export HOMEBREW_PREFIX="/opt/homebrew"
    else
        export HOMEBREW_PREFIX="/usr/local"
    fi

    # 检查 Homebrew 是否安装
    if [[ ! -f "$HOMEBREW_PREFIX/bin/brew" ]]; then
        echo "⚠️  Homebrew is not installed!"
        echo "   Many tools (git, neovim, etc.) require Homebrew on macOS."
        echo ""
        echo "   Install Homebrew with:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo ""
        echo "   Then restart your terminal."
    else
        # 初始化 Homebrew 环境
        eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

        # Homebrew 配置
        export HOMEBREW_NO_ANALYTICS=1
        export HOMEBREW_NO_AUTO_UPDATE=1
    fi
fi

# ============================================
# Linux 特定配置
# ============================================

if [[ "$OS_TYPE" != "macos" ]] && [[ -o interactive ]]; then
    # Debian/Ubuntu: bat 命令别名
    if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
        alias bat='batcat'
    fi

    # fd-find 命令别名 (Debian/Ubuntu)
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        alias fd='fdfind'
    fi
fi

# ============================================
# 历史记录设置
# ============================================

export HISTSIZE=50000          # 内存中保存的历史行数
export SAVEHIST=50000          # 文件中保存的历史行数
export HISTFILE="$HOME/.zsh_history"

# 历史记录选项（仅在交互式 shell 中设置）
if [[ -o interactive ]]; then
  setopt HIST_IGNORE_ALL_DUPS    # 删除重复命令
  setopt HIST_FIND_NO_DUPS       # 搜索时不显示重复
  setopt HIST_REDUCE_BLANKS      # 删除多余空格
  setopt SHARE_HISTORY           # 实时跨窗口共享历史记录
  setopt INC_APPEND_HISTORY      # 立即写入历史文件
  setopt HIST_VERIFY             # 历史扩展时先显示，不立即执行
  setopt EXTENDED_HISTORY        # 保存时间戳和执行时长
fi

# ============================================
# 基础环境变量
# ============================================

export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

# Less 配置
export LESS='-R -M -i -j4'
export LESSHISTFILE='-'

# ============================================
# 路径管理
# ============================================

# 用户本地路径（优先级最高）
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Cargo (Rust)
if [[ -d "$HOME/.cargo/bin" ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
    export CARGO_HOME="$HOME/.cargo"
fi

# Go
if [[ -d "$HOME/go/bin" ]]; then
    export PATH="$HOME/go/bin:$PATH"
    export GOPATH="$HOME/go"
fi

# Node.js 全局包
if [[ -d "$HOME/.npm-global/bin" ]]; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

# Python 用户级包
if command -v python3 >/dev/null 2>&1; then
    PYTHON_USER_BASE="$(python3 -m site --user-base 2>/dev/null)"
    if [[ -n "$PYTHON_USER_BASE" ]] && [[ -d "$PYTHON_USER_BASE/bin" ]]; then
        export PATH="$PYTHON_USER_BASE/bin:$PATH"
    fi
fi

# uv import
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

# Deno
if [[ -d "$HOME/.deno/bin" ]]; then
    export PATH="$HOME/.deno/bin:$PATH"
    export DENO_INSTALL="$HOME/.deno"
fi

# Bun
if [[ -d "$HOME/.bun/bin" ]]; then
    export PATH="$HOME/.bun/bin:$PATH"
    export BUN_INSTALL="$HOME/.bun"
fi

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # 延迟加载 NVM 以加快 shell 启动速度
    # 如果需要立即使用，可以取消注释下面这行
    # \. "$NVM_DIR/nvm.sh"

    # 使用函数进行懒加载，避免 alias 与 nvm.sh 冲突
    _nvm_lazy_load() {
        unalias nvm node npm 2>/dev/null
        unset -f nvm node npm
        \. "$NVM_DIR/nvm.sh"
    }

    nvm() {
        _nvm_lazy_load
        nvm "$@"
    }

    node() {
        _nvm_lazy_load
        command node "$@"
    }

    npm() {
        _nvm_lazy_load
        command npm "$@"
    }
fi

# 加载 NVM bash 补全（可选）
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"

# ============================================
# FZF 配置
# ============================================

# FZF 默认命令（使用 ripgrep）
if command -v rg >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
elif command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# FZF 配色方案
export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --inline-info
    --color=fg:#d0d0d0,bg:#121212,hl:#5f87af
    --color=fg+:#d0d0d0,bg+:#262626,hl+:#5fd7ff
    --color=info:#afaf87,prompt:#d7005f,pointer:#af5fff
    --color=marker:#87ff00,spinner:#af5fff,header:#87afaf
"

# ============================================
# 语言环境
# ============================================

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# ============================================
# 开发工具配置
# ============================================

# Docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# GPG - 仅在有 tty 时设置
if tty -s 2>/dev/null; then
    export GPG_TTY=$(tty 2>/dev/null)
fi

# ============================================
# 性能优化
# ============================================

# 禁用 compinit 的安全检查（加快启动速度）
# 如果遇到权限问题，请注释掉这行
skip_global_compinit=1

# ============================================
# 颜色支持
# ============================================

# 启用颜色
export CLICOLOR=1

# LS_COLORS (GNU coreutils) - 仅在交互式 shell 中设置
if [[ -o interactive ]] && command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)" 2>/dev/null || true
fi

# LSCOLORS (BSD/macOS)
export LSCOLORS=ExGxBxDxCxEgEdxbxgxcxd

# ============================================
# 终端配置
# ============================================

# Kitty 终端特定配置 - 仅在交互式 shell 中设置
if [[ -o interactive ]] && [[ "$TERM" == "xterm-kitty" ]]; then
    alias ssh='kitty +kitten ssh'
fi

# ============================================
# macOS 特定工具别名
# ============================================

if [[ "$OS_TYPE" == "macos" ]] && [[ -o interactive ]]; then
    # 使用 GNU 工具替代 BSD 工具
    if command -v gls >/dev/null 2>&1; then
        alias ls='gls --color=auto'
    fi
    if command -v gsed >/dev/null 2>&1; then
        alias sed='gsed'
    fi
    if command -v gtar >/dev/null 2>&1; then
        alias tar='gtar'
    fi
    if command -v gmake >/dev/null 2>&1; then
        alias make='gmake'
    fi
fi

# ============================================
# Antidote 插件管理
# ============================================

[[ -n "$ZSHRC_DEBUG" ]] && echo "[DEBUG] Loading antidote..."

# 设置 antidote 路径
ANTIDOTE_HOME="${ANTIDOTE_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/antidote}"

# 自动安装 antidote（如果不存在）
if [[ ! -d "$ANTIDOTE_HOME" ]]; then
    echo "Installing antidote..."
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$ANTIDOTE_HOME"
fi

# 加载 antidote
source "$ANTIDOTE_HOME/antidote.zsh"

# 初始化插件
antidote load <<EOBUNDLES
# 主题
romkatv/powerlevel10k

# 核心功能增强
zsh-users/zsh-autosuggestions
zsh-users/zsh-completions
Aloxaf/fzf-tab

# 编辑器模式
jeffreytse/zsh-vi-mode
hlissner/zsh-autopair

# Git 增强
wfxr/forgit

# 提示与帮助
djui/alias-tips
popstas/zsh-command-time

# 开发工具集成
ohmyzsh/ohmyzsh path:plugins/kubectl
MichaelAquilina/zsh-autoswitch-virtualenv
ohmyzsh/ohmyzsh path:plugins/copyfile
ohmyzsh/ohmyzsh path:plugins/copybuffer

# 历史记录增强
zsh-users/zsh-history-substring-search

# 语法高亮 (必须最后加载)
zsh-users/zsh-syntax-highlighting
EOBUNDLES

[[ -n "$ZSHRC_DEBUG" ]] && echo "[DEBUG] Antidote plugins loaded"

# ============================================
# 插件配置
# ============================================

# ZSH Autosuggestions 配置
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# Command Time configuration
ZSH_COMMAND_TIME_MIN_SECONDS=3
ZSH_COMMAND_TIME_MSG="Execution time: %s"
ZSH_COMMAND_TIME_COLOR="cyan"

# History Substring Search 配置
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# ============================================
# 补全初始化
# ============================================

[[ -n "$ZSHRC_DEBUG" ]] && echo "[DEBUG] Initializing completion system..."
autoload -U compinit && compinit
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:*' fzf-command fzf

# fzf-tab 目录预览配置
if command -v eza >/dev/null 2>&1; then
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
  zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
else
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath 2>/dev/null'
  zstyle ':fzf-tab:complete:z:*' fzf-preview 'ls -1 --color=always $realpath 2>/dev/null'
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls -1 --color=always $realpath 2>/dev/null'
fi

# fzf-tab 其他配置
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-flags --height=80%

# ============================================
# 基础导航别名
# ============================================

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias -- -='cd -'  # 返回上一个目录

alias cls='clear'
alias zshconfig='nvim ~/dotfiles/zsh/.zshrc'
alias zshsource='source ~/.zshrc'

# ============================================
# 安全开关
# ============================================

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# 更安全的删除（使用 trash 如果可用）
if command -v trash >/dev/null 2>&1; then
    alias del='trash'
elif command -v gio >/dev/null 2>&1; then
    alias del='gio trash'
else
    alias del='rm -i'
fi

# ============================================
# 现代工具替代
# ============================================

# Eza (ls 替代)
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza --icons -l --git --group-directories-first'
    alias la='eza --icons -la --git --group-directories-first'
    alias lt='eza --icons --tree --level=2 --group-directories-first'
    alias lt3='eza --icons --tree --level=3 --group-directories-first'
    alias lsd='eza --icons -lD'  # 仅显示目录
    alias lsf='eza --icons -lf --color=always | grep -v /'  # 仅显示文件
else
    alias ls='ls --color=auto'
    alias ll='ls -lh'
    alias la='ls -lAh'
fi

# Bat (cat 替代)
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
    alias ccat='bat --style=plain --paging=never'  # 纯文本模式
    alias bathelp='bat --list-themes'
fi

# Zoxide (cd 替代)
if command -v zoxide >/dev/null 2>&1; then
    alias cd='z'
fi

# ============================================
# Yazi 文件管理器增强
# ============================================

# 退出时自动 cd 到当前目录
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# ============================================
# 编辑器别名
# ============================================

alias vi='nvim'
alias vim='nvim'
alias v='nvim'
alias nv='nvim'

# 快速编辑配置文件
alias vimconfig='nvim ~/dotfiles/nvim/.config/nvim/init.lua'
alias kittyconfig='nvim ~/dotfiles/kitty/.config/kitty/kitty.conf'
alias gitconfig='nvim ~/dotfiles/git/.gitconfig'
alias tmuxconfig='nvim ~/dotfiles/tmux/.tmux.conf'
alias dotfiles='cd ~/dotfiles && nvim'

# ============================================
# Git 增强别名
# ============================================

alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add -p'  # 交互式添加
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'

alias gp='git push'
alias gpf='git push --force-with-lease'  # 更安全的强制推送
alias gl='git pull'
alias gf='git fetch'

alias gd='git diff'
alias gds='git diff --staged'
alias gdt='git difftool'

alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gswc='git switch -c'

alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gbD='git branch -D'

alias gm='git merge'
alias gma='git merge --abort'
alias gr='git rebase'
alias gri='git rebase -i'
alias gra='git rebase --abort'
alias grc='git rebase --continue'

alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gsta='git stash apply'

alias glg='git log --graph --oneline --decorate --all'
alias glgs='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias glo='git log --oneline'
alias glast='git log -1 HEAD'

alias gclean='git clean -fd'
alias grh='git reset HEAD'
alias grhh='git reset --hard HEAD'
alias gundo='git reset HEAD~1 --mixed'

# Lazygit
if command -v lazygit >/dev/null 2>&1; then
    alias lg='lazygit'
fi

# ============================================
# Docker 快捷方式
# ============================================

alias d='docker'
alias dc='docker-compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dimg='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dstop='docker stop'
alias drm='docker rm'
alias drmi='docker rmi'
alias dprune='docker system prune -af'
alias dvol='docker volume ls'
alias dnet='docker network ls'

# Docker Compose
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dcl='docker-compose logs -f'
alias dcr='docker-compose restart'
alias dcb='docker-compose build'

# Lazydocker
if command -v lazydocker >/dev/null 2>&1; then
    alias ld='lazydocker'
fi

# ============================================
# Kubernetes 快捷方式
# ============================================

alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deploy'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'

alias kdesc='kubectl describe'
alias kdel='kubectl delete'
alias klog='kubectl logs -f'
alias kexec='kubectl exec -it'

alias kctx='kubectl config current-context'
alias kns='kubectl config set-context --current --namespace'

# ============================================
# 系统监控工具
# ============================================

# Bottom (top/htop 替代)
if command -v btm >/dev/null 2>&1; then
    alias top='btm'
    alias htop='btm'
elif command -v htop >/dev/null 2>&1; then
    alias top='htop'
fi

# Procs (ps 替代)
if command -v procs >/dev/null 2>&1; then
    alias ps='procs'
    alias psa='procs --tree'
fi

# Duf (df 替代)
if command -v duf >/dev/null 2>&1; then
    alias df='duf'
fi

# Dust (du 替代)
if command -v dust >/dev/null 2>&1; then
    alias du='dust'
fi

# Fd (find 替代)
if command -v fd >/dev/null 2>&1; then
    alias find='fd'
fi

# ============================================
# 网络工具
# ============================================

# HTTPie (curl 替代)
if command -v http >/dev/null 2>&1; then
    alias get='http GET'
    alias post='http POST'
    alias put='http PUT'
    alias delete='http DELETE'
fi

# 网络测试
alias myip='curl -s https://ipinfo.io/ip'
alias myipinfo='curl -s https://ipinfo.io/json | bat -l json'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'

# 端口扫描
alias ports='netstat -tulanp'
alias listening='lsof -i -P | grep LISTEN'

# ============================================
# Python 虚拟环境
# ============================================

alias venv='python3 -m venv venv'
alias activate='source venv/bin/activate'
alias deactivate='deactivate'
alias py='python3'
alias pip='pip3'
alias pipi='pip3 install'
alias pipu='pip3 install --upgrade'
alias pipr='pip3 install -r requirements.txt'

# ============================================
# Node.js / npm / yarn
# ============================================

alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nr='npm run'
alias ns='npm start'
alias nt='npm test'
alias nb='npm run build'
alias nci='rm -rf node_modules package-lock.json && npm install'

alias yi='yarn install'
alias ya='yarn add'
alias yad='yarn add --dev'
alias yr='yarn run'
alias ys='yarn start'
alias yt='yarn test'
alias yb='yarn build'

# ============================================
# Tmux 快捷方式
# ============================================

alias ta='tmux attach -t'
alias tad='tmux attach -d -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias tksv='tmux kill-server'
alias tkss='tmux kill-session -t'

# ============================================
# 实用函数
# ============================================

# 创建目录并进入
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archives
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# 查找进程
psg() {
    ps aux | grep -v grep | grep -i -e VSZ -e "$1"
}

# 快速查找文件
ff() {
    if command -v fd >/dev/null 2>&1; then
        fd "$1"
    else
        find . -type f -name "*$1*"
    fi
}

# 快速查找目录
ffd() {
    if command -v fd >/dev/null 2>&1; then
        fd -t d "$1"
    else
        find . -type d -name "*$1*"
    fi
}

# Git 仓库克隆并进入
gcl() {
    git clone "$1" && cd "$(basename "$1" .git)"
}

# 快速服务器（Python HTTP Server）
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

# 备份文件
backup() {
    cp "$1"{,.backup-$(date +%Y%m%d-%H%M%S)}
}

# ============================================
# Cleanup functions
# ============================================

# Clean Docker
cleanup-docker() {
    echo "Cleaning Docker system..."
    docker system prune -af --volumes
    echo "✅ Docker cleanup complete"
}

# Clean Homebrew (macOS)
cleanup-brew() {
    if command -v brew >/dev/null 2>&1; then
        echo "Cleaning Homebrew..."
        brew cleanup
        brew autoremove
        echo "✅ Homebrew cleanup complete"
    fi
}

# Clean npm
cleanup-npm() {
    echo "Cleaning npm cache..."
    npm cache clean --force
    echo "✅ npm cleanup complete"
}

# Clean all
cleanup-all() {
    cleanup-docker
    cleanup-brew
    cleanup-npm
    echo "🎉 All cleanup complete!"
}

# ============================================
# 趣味命令
# ============================================

# 显示历史命令使用频率
alias histop='history | awk "{print \$2}" | sort | uniq -c | sort -rn | head -20'

# 快速备忘录
note() {
    echo "$(date +'%Y-%m-%d %H:%M:%S'): $*" >> ~/notes.txt
}

viewnotes() {
    if command -v bat >/dev/null 2>&1; then
        bat ~/notes.txt
    else
        cat ~/notes.txt
    fi
}

# ============================================
# 外部初始化
# ============================================

[[ -n "$ZSHRC_DEBUG" ]] && echo "[DEBUG] Initializing external tools..."
[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
if command -v fzf >/dev/null 2>&1; then
  # 尝试新版 fzf --zsh，失败则尝试旧版路径
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  elif [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
  elif [ -f /usr/share/fzf/completion.zsh ]; then
    source /usr/share/fzf/completion.zsh
    source /usr/share/fzf/key-bindings.zsh
  fi
fi

# ============================================
# 私密配置
# ============================================

[[ -n "$ZSHRC_DEBUG" ]] && echo "[DEBUG] Loading local config..."
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

[[ -n "$ZSHRC_DEBUG" ]] && echo "[DEBUG] .zshrc loaded successfully!"
