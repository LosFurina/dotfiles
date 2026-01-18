# P10k 瞬时提示
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export DOTZSH="$HOME/dotfiles/zsh"

# 加载模块
source "$DOTZSH/.zsh_env"
source "$DOTZSH/.zsh_plugins"
source "$DOTZSH/.zsh_aliases"

# 补全初始化
autoload -U compinit && compinit
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:*' fzf-command fzf

# 外部初始化
[ -f ~/.p10k.zsh ] && source ~/.p10k.zsh
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v fzf >/dev/null && source <(fzf --zsh)

# 私密配置
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# 启动展示
command -v fastfetch >/dev/null && fastfetch
