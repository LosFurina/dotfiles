# 启动展示（必须在 P10k instant prompt 之前）
command -v fastfetch >/dev/null && fastfetch

# P10k 瞬时提示
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export DOTZSH="$HOME/dotfiles/zsh"

# 加载模块
[[ -f "$DOTZSH/.zsh_env" ]] && source "$DOTZSH/.zsh_env"
[[ -f "$DOTZSH/.zsh_plugins" ]] && source "$DOTZSH/.zsh_plugins"
[[ -f "$DOTZSH/.zsh_aliases" ]] && source "$DOTZSH/.zsh_aliases"

# 补全初始化
autoload -U compinit && compinit
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:*' fzf-command fzf

# fzf-tab 目录预览配置
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls -1 --color=always $realpath'

# fzf-tab 其他配置
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-flags --height=80%

# 外部初始化
[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v fzf >/dev/null && source <(fzf --zsh)

# 私密配置
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
