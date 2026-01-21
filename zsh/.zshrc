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

export DOTZSH="$HOME/dotfiles/zsh"

# 加载模块
[[ -n "$ZSHRC_DEBUG" ]] && echo "[DEBUG] Loading .zsh_env..."
[[ -f "$DOTZSH/.zsh_env" ]] && source "$DOTZSH/.zsh_env"
[[ -n "$ZSHRC_DEBUG" ]] && echo "[DEBUG] Loading .zsh_plugins..."
[[ -f "$DOTZSH/.zsh_plugins" ]] && source "$DOTZSH/.zsh_plugins"
[[ -n "$ZSHRC_DEBUG" ]] && echo "[DEBUG] Loading .zsh_aliases..."
[[ -f "$DOTZSH/.zsh_aliases" ]] && source "$DOTZSH/.zsh_aliases"

# 补全初始化
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

# 外部初始化
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

# 私密配置
[[ -n "$ZSHRC_DEBUG" ]] && echo "[DEBUG] Loading local config..."
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

[[ -n "$ZSHRC_DEBUG" ]] && echo "[DEBUG] .zshrc loaded successfully!"
