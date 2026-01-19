# 🏠 Wayne's Dotfiles

> 现代化、跨平台的开发环境配置，支持 macOS (Apple Silicon & Intel)、Arch Linux 和 Debian/Ubuntu

## ✨ 特性

- 🚀 **完全自动化安装** - 一键部署所有配置
- 🌍 **跨平台支持** - macOS、Arch、Debian/Ubuntu 完美适配
- 🎨 **现代化工具链** - 使用最新的 CLI 工具替代传统命令
- ⚡ **性能优化** - Zsh 启动速度快，配置简洁高效
- 🔒 **安全可靠** - 敏感文件自动忽略，支持本地私密配置
- 📦 **模块化设计** - 使用 GNU Stow 管理，易于扩展

---

## 📦 包含的配置

| 工具 | 描述 | 主要特性 |
|------|------|----------|
| **Zsh** | Shell 环境 | Powerlevel10k 主题、15+ 插件、智能补全 |
| **Neovim** | 文本编辑器 | LazyVim 配置、LSP 支持、40+ 插件 |
| **Kitty** | 终端模拟器 | GPU 加速、字体配置、快捷键优化 |
| **Tmux** | 终端复用器 | Vim 风格快捷键、插件管理、会话保存 |
| **Yazi** | 文件管理器 | Vim 快捷键、预览支持、主题配置 |
| **Git** | 版本控制 | 别名配置、Delta 集成、全局忽略文件 |
| **SSH** | 远程连接 | 连接复用、跳板机配置、安全设置 |
| **EditorConfig** | 代码风格 | 跨编辑器统一代码格式 |
| **Starship** | 提示符 (可选) | P10k 备选方案，跨 shell 支持 |

---

## 🚀 快速开始

### 前置要求

- **Git** (克隆仓库)
- **Zsh** (Shell 环境)
- **Curl/Wget** (下载工具)

### 一键安装

```bash
# 克隆仓库
git clone https://github.com/LosFurina/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 运行安装脚本
chmod +x install.sh
./install.sh
```

安装脚本会自动：
1. 检测你的操作系统
2. 安装所有必需的包和工具
3. 使用 Stow 部署配置文件
4. 设置 Zplug 插件管理器

### 手动安装

如果你只想安装部分配置：

```bash
# 进入 dotfiles 目录
cd ~/dotfiles

# 使用 Stow 部署特定配置 (以 zsh 为例)
stow zsh

# 部署多个配置
stow zsh nvim kitty tmux
```

---

## 🛠️ 工具列表

### 核心工具

| 工具 | 用途 | 安装方式 |
|------|------|----------|
| [zplug](https://github.com/zplug/zplug) | Zsh 插件管理器 | 自动安装 |
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | Zsh 提示符主题 | via Zplug |
| [LazyVim](https://github.com/LazyVim/LazyVim) | Neovim 配置框架 | 自动安装 |
| [TPM](https://github.com/tmux-plugins/tpm) | Tmux 插件管理器 | 自动安装 |

### 现代化 CLI 工具

| 传统工具 | 现代替代 | 功能增强 |
|----------|----------|----------|
| `ls` | [eza](https://github.com/eza-community/eza) | Git 集成、图标、颜色 |
| `cat` | [bat](https://github.com/sharkdp/bat) | 语法高亮、Git 差异 |
| `cd` | [zoxide](https://github.com/ajeetdsouza/zoxide) | 智能跳转、频率记录 |
| `find` | [fd](https://github.com/sharkdp/fd) | 更快、更简单 |
| `grep` | [ripgrep](https://github.com/BurntSushi/ripgrep) | 极速搜索 |
| `top` | [bottom](https://github.com/ClementTsang/bottom) | 更美观的系统监控 |
| `du` | [dust](https://github.com/bootandy/dust) | 可视化磁盘使用 |
| `df` | [duf](https://github.com/muesli/duf) | 彩色磁盘信息 |
| `ps` | [procs](https://github.com/dalance/procs) | 现代进程查看器 |
| `curl` | [httpie](https://httpie.io/) | 更友好的 HTTP 客户端 |

### Git 工具

- [lazygit](https://github.com/jesseduffield/lazygit) - TUI Git 客户端
- [delta](https://github.com/dandavison/delta) - 更好的 Git diff 查看器
- [forgit](https://github.com/wfxr/forgit) - FZF + Git 交互式工具

---

## 📁 目录结构

```
dotfiles/
├── zsh/              # Zsh 配置
│   ├── .zshrc       # 主配置文件
│   ├── .zsh_env     # 环境变量
│   ├── .zsh_aliases # 别名和函数
│   ├── .zsh_plugins # 插件管理
│   └── .zprofile    # 登录 shell 配置
├── nvim/             # Neovim 配置
│   └── .config/nvim/
├── kitty/            # Kitty 终端配置
│   └── .config/kitty/
├── tmux/             # Tmux 配置
│   └── .tmux.conf
├── yazi/             # Yazi 文件管理器配置
│   └── .config/yazi/
├── git/              # Git 全局配置
│   ├── .gitconfig
│   └── .gitignore_global
├── ssh/              # SSH 配置
│   └── .ssh/config
├── editorconfig/     # EditorConfig
│   └── .editorconfig
├── starship/         # Starship 提示符 (可选)
│   └── .config/starship.toml
├── install.sh        # 安装脚本
├── README.md         # 本文件
└── .gitignore        # Git 忽略规则
```

---

## ⚙️ 自定义配置

### 私密配置

创建 `.local` 文件存储私密配置（已在 .gitignore 中忽略）：

```bash
# Zsh 私密配置
touch ~/dotfiles/zsh/.zshrc.local
echo 'export SECRET_API_KEY="your-key"' >> ~/dotfiles/zsh/.zshrc.local
```

`.zshrc` 会自动加载 `.zshrc.local` 文件。

### Git 用户信息

编辑 `git/.gitconfig` 设置你的信息：

```bash
nvim ~/dotfiles/git/.gitconfig

# 修改以下内容:
[user]
    name = Your Name
    email = your.email@example.com
```

### SSH 配置

编辑 `ssh/.ssh/config` 添加你的服务器：

```bash
nvim ~/dotfiles/ssh/.ssh/config

# 示例:
Host myserver
    HostName example.com
    User username
    Port 22
    IdentityFile ~/.ssh/id_ed25519
```

### Neovim 插件

编辑 `nvim/.config/nvim/lua/config/lazy.lua` 启用更多语言支持：

```lua
-- 取消注释以下行启用 Go 支持
{ import = "lazyvim.plugins.extras.lang.go" },

-- 取消注释启用 AI 代码补全
{ import = "lazyvim.plugins.extras.coding.copilot" },
```

---

## 🎯 常用别名

### 导航
```bash
..       # cd ..
...      # cd ../..
-        # 返回上一个目录
```

### Git
```bash
g        # git
gs       # git status -sb
ga       # git add
gc       # git commit
gp       # git push
gl       # git pull
gd       # git diff
gco      # git checkout
gb       # git branch
glg      # git log --graph
lg       # lazygit (TUI)
```

### Docker
```bash
d        # docker
dc       # docker-compose
dps      # docker ps (美化)
dex      # docker exec -it
dlogs    # docker logs -f
dprune   # docker system prune -af
```

### Kubernetes
```bash
k        # kubectl
kgp      # kubectl get pods
kgs      # kubectl get svc
klog     # kubectl logs -f
kexec    # kubectl exec -it
```

### 文件操作
```bash
ls       # eza --icons
ll       # eza -l --git
la       # eza -la --git
lt       # eza --tree
cat      # bat --paging=never
```

更多别名请查看 `zsh/.zsh_aliases`

---

## 🔧 故障排查

### Zsh 插件安装失败

```bash
# 重新安装 Zplug
rm -rf ~/.zplug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/zplug/master/installer.zsh | zsh

# 重新加载 zsh
source ~/.zshrc
```

### Neovim 插件问题

```bash
# 清理并重装插件
nvim
:Lazy clean
:Lazy sync
```

### Tmux 插件未加载

```bash
# 安装 TPM 插件
~/.tmux/plugins/tpm/bin/install_plugins

# 或在 tmux 中按: Prefix + I (大写 i)
```

### SSH 连接失败

```bash
# 确保 ControlPath 目录存在
mkdir -p ~/.ssh/sockets

# 检查 SSH 配置权限
chmod 600 ~/.ssh/config
chmod 700 ~/.ssh
```

### macOS 特定问题

```bash
# Homebrew 未找到
# 根据架构手动设置
# Apple Silicon:
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel:
eval "$(/usr/local/bin/brew shellenv)"
```

---

## 📝 待办事项

- [ ] 添加 Windows WSL 支持
- [ ] 创建 Neovim 自定义配色方案
- [ ] 添加 Alacritty 终端配置
- [ ] 创建自动备份脚本
- [ ] 添加 Ansible playbook

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

## 📄 许可证

MIT License - 随意使用和修改

---

## 🙏 致谢

感谢以下项目的灵感和参考：

- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
- [holman/dotfiles](https://github.com/holman/dotfiles)
- [thoughtbot/dotfiles](https://github.com/thoughtbot/dotfiles)
- [LazyVim](https://github.com/LazyVim/LazyVim)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)

---

## 📮 联系方式

- GitHub: [@Wayne](https://github.com/LosFurina)
- Email: github@weijun.online

---

**⭐ 如果这个项目对你有帮助，请给个 Star！**
