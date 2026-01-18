# === .zprofile - Zsh 登录 Shell 初始化文件 ===
# 这个文件在登录 Shell 时执行（在 .zshrc 之前）
# 用于设置环境变量和登录时的一次性设置

# ============================================
# 加载环境变量配置
# ============================================

# 加载 .zsh_env（如果存在）
[[ -f ~/.zsh_env ]] && source ~/.zsh_env

# ============================================
# 平台特定配置
# ============================================

# macOS 特定配置
if [[ "$(uname)" == "Darwin" ]]; then
    # Homebrew 路径（根据架构）
    if [[ "$(uname -m)" == "arm64" ]]; then
        export HOMEBREW_PREFIX="/opt/homebrew"
    else
        export HOMEBREW_PREFIX="/usr/local"
    fi

    # 添加 Homebrew 到 PATH
    export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"

    # macOS 应用程序路径
    export PATH="/Applications:$PATH"

    # GNU 工具路径（如果通过 Homebrew 安装）
    if [[ -d "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin" ]]; then
        export PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
    fi

    # macOS 特定环境变量
    export BROWSER='open'
fi

# Linux 特定配置
if [[ "$(uname)" == "Linux" ]]; then
    # Snap 包管理器
    if [[ -d /snap/bin ]]; then
        export PATH="/snap/bin:$PATH"
    fi

    # Flatpak 应用
    if [[ -d /var/lib/flatpak/exports/bin ]]; then
        export PATH="/var/lib/flatpak/exports/bin:$PATH"
    fi

    # X11 显示服务器
    if [[ -z "$DISPLAY" ]] && [[ -n "$XDG_VTNR" ]] && [[ "$XDG_VTNR" -eq 1 ]]; then
        export DISPLAY=:0
    fi
fi

# ============================================
# 语言环境
# ============================================

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# ============================================
# 通用路径配置
# ============================================

# 用户本地二进制文件
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Cargo (Rust)
if [[ -d "$HOME/.cargo/bin" ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# Go
if [[ -d "$HOME/go/bin" ]]; then
    export PATH="$HOME/go/bin:$PATH"
fi

# Node.js 全局包
if [[ -d "$HOME/.npm-global/bin" ]]; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

# Python 用户级包
if [[ -d "$HOME/.local/share/python/bin" ]]; then
    export PATH="$HOME/.local/share/python/bin:$PATH"
fi

# ============================================
# XDG Base Directory
# ============================================

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# ============================================
# 默认编辑器
# ============================================

export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

# ============================================
# 自动启动 X 或 Wayland (可选)
# ============================================

# 如果在 tty1 并且没有运行图形界面，自动启动 X
# if [[ -z "$DISPLAY" ]] && [[ "$XDG_VTNR" -eq 1 ]]; then
#     exec startx
# fi

# ============================================
# 登录消息 (可选)
# ============================================

# 显示登录欢迎信息（仅在交互式 shell 且登录时显示一次）
if [[ -o interactive ]] && [[ -o login ]]; then
    # 可以在这里添加自定义的欢迎消息
    # echo "欢迎回来，$(whoami)！"
    :
fi

# ============================================
# SSH Agent (可选)
# ============================================

# 自动启动 SSH agent
# if ! pgrep -u "$USER" ssh-agent > /dev/null; then
#     eval "$(ssh-agent -s)" > /dev/null
# fi
