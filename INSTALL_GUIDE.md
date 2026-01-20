# Dotfiles 安装指南

## 快速安装（推荐）

在 Arch Linux 上一键安装所有配置和工具：

```bash
cd ~/dotfiles
./install.sh
```

安装脚本会自动完成：
1. 安装系统包（stow, git, neovim, kitty, yazi, tmux, fzf, ripgrep 等）
2. 使用 Stow 创建配置文件的软链接
3. 安装 Zplug（Zsh 插件管理器）
4. 检查并安装 NVM 和 Node.js LTS 版本
5. 检查并安装 uv（Python 包管理器）

**智能安装机制：**
- 如果工具已安装，会显示当前版本并询问是否重新安装
- 默认不重新安装，输入 `y` 才会重新安装
- 首次安装会自动进行，无需确认

**示例输出：**
```
Checking development tools...
✓ NVM already installed (version: 0.40.1)
  - Node.js: v20.11.0
Reinstall NVM? [y/N] n
✓ uv already installed (version: 0.5.4)
Reinstall uv? [y/N] n
```

## 安装的开发环境工具

### NVM (Node Version Manager)
- 自动安装最新 LTS 版本的 Node.js
- 配置了懒加载以加快 shell 启动速度
- 第一次使用 `node`、`npm` 或 `nvm` 命令时会自动加载

**使用方法：**
```bash
nvm list                 # 列出已安装的 Node 版本
nvm install 20           # 安装指定版本
nvm use 20               # 切换到指定版本
nvm alias default 20     # 设置默认版本
```

### uv (Python 包管理器)
- 超快的 Python 包管理器和项目管理工具
- 安装位置：`~/.local/bin/uv`

**使用方法：**
```bash
uv venv                  # 创建虚拟环境
uv pip install package   # 安装包
uv pip list              # 列出已安装的包
```

## 重要修复

### KDE 登录问题修复
修复了导致 KDE 登录失败的配置问题：

**问题原因：**
- `zsh/.zsh_env:120` 行无条件加载了可能不存在的 `$HOME/.local/bin/env` 文件
- 导致 shell 初始化失败，KDE 会话无法启动

**已修复的文件：**
1. `zsh/.zsh_env` - 所有 source 命令都添加了文件存在性检查
2. `zsh/.zshrc` - 加载模块时添加了防御性检查

## 手动安装步骤（可选）

如果你想分步骤安装：

### 1. 安装系统依赖（Arch Linux）
```bash
sudo pacman -S stow git neovim eza bat zoxide fzf ripgrep fastfetch kitty yazi tmux lazygit git-delta
```

### 2. 部署配置文件
```bash
cd ~/dotfiles
mkdir -p ~/.config ~/.ssh/sockets ~/.local/bin

# 使用 Stow 创建软链接
stow nvim zsh yazi kitty tmux git editorconfig starship ssh
```

### 3. 安装 Zplug
```bash
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/zplug/master/installer.zsh | zsh
```

### 4. 安装 NVM
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.zshrc
nvm install --lts
```

### 5. 安装 uv
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## 安装后操作

### 重启终端
```bash
# 重新加载 zsh 配置
source ~/.zshrc

# 或者重启终端
```

### 验证安装
```bash
# 检查工具是否正确安装
command -v nvim && echo "✅ Neovim"
command -v kitty && echo "✅ Kitty"
command -v yazi && echo "✅ Yazi"
command -v tmux && echo "✅ Tmux"
command -v fzf && echo "✅ FZF"
command -v nvm && echo "✅ NVM"
command -v node && echo "✅ Node.js"
command -v uv && echo "✅ uv"
```

### 初始化 Neovim
首次启动 Neovim 时，LazyVim 会自动安装所有插件：
```bash
nvim
```

## 常见问题

### Q: KDE 登录后黑屏返回登录界面
A: 这是由于 shell 配置错误导致的。已修复 `.zsh_env` 中的文件加载逻辑。

### Q: NVM 命令找不到
A: NVM 使用了懒加载机制。第一次使用 `nvm`、`node` 或 `npm` 命令时会自动加载。

### Q: 如何更新 Node.js 版本
```bash
nvm install node        # 安装最新版本
nvm install --lts       # 安装最新 LTS 版本
nvm use node            # 使用最新版本
nvm alias default node  # 设置为默认
```

### Q: uv 找不到
A: 确保 `~/.local/bin` 在 PATH 中（配置文件已自动添加）。执行 `source ~/.zshrc` 重新加载配置。

### Q: 如何更新 NVM 或 uv
A: 重新运行 `./install.sh`，当提示是否重新安装时输入 `y`：
```bash
cd ~/dotfiles
./install.sh
# 当看到 "是否重新安装 NVM? [y/N]" 时输入 y
# 当看到 "是否重新安装 uv? [y/N]" 时输入 y
```

### Q: 安装脚本会覆盖我已有的配置吗
A: 不会。脚本会：
- 检测已安装的工具并显示版本
- 默认跳过已安装的工具（除非你输入 `y` 确认重新安装）
- 备份冲突的配置文件为 `.bak` 文件

## 配置文件说明

- `zsh/.zshrc` - Zsh 主配置文件
- `zsh/.zsh_env` - 环境变量配置
- `zsh/.zsh_aliases` - 命令别名
- `zsh/.zsh_plugins` - Zplug 插件配置
- `zsh/.zprofile` - 登录 Shell 配置
- `nvim/.config/nvim/` - Neovim 配置（基于 LazyVim）
- `kitty/.config/kitty/kitty.conf` - Kitty 终端配置
- `tmux/.tmux.conf` - Tmux 配置
- `git/.gitconfig` - Git 全局配置

## 卸载

如果需要移除配置：

```bash
cd ~/dotfiles

# 移除软链接
stow -D nvim zsh yazi kitty tmux git editorconfig starship ssh

# 恢复备份（如果有）
mv ~/.zshrc.bak ~/.zshrc 2>/dev/null || true
```

## 联系

如有问题，请查看各配置文件中的注释或提交 issue。
