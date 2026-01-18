#!/usr/bin/env bash

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${BLUE}开始分析系统环境...${NC}"

# 辅助函数：检查命令是否存在
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# 1. 精准识别系统
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS_TYPE="macos"
  ARCH_TYPE=$(uname -m)
elif [[ -f /etc/os-release ]]; then
  # 通过 source 命令直接把 os-release 里的变量（如 ID）读入当前脚本环境
  . /etc/os-release
  OS_TYPE=$ID
else
  # 最后的保底手段
  OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
fi

echo -e "${BLUE}检测到系统类型: ${GREEN}$OS_TYPE${NC}"
[[ -n "$ARCH_TYPE" ]] && echo -e "${BLUE}系统架构: ${GREEN}$ARCH_TYPE${NC}"

# 2. 定义安装函数
install_packages() {
  case $OS_TYPE in
  "macos")
    echo -e "${BLUE}正在检查 Homebrew...${NC}"
    if ! command_exists brew; then
      echo -e "${YELLOW}Homebrew 未安装，正在安装...${NC}"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      # 根据架构设置 Homebrew 路径
      if [[ "$ARCH_TYPE" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      else
        eval "$(/usr/local/bin/brew shellenv)"
      fi
    fi

    echo -e "${BLUE}正在通过 Homebrew 安装依赖...${NC}"
    brew install stow git nvim eza bat zoxide fzf ripgrep fastfetch kitty yazi tmux lazygit git-delta

    # 可选工具
    echo -e "${YELLOW}是否安装额外的现代化工具? (bottom, procs, duf, dust, fd, httpie) [y/N]${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      brew install bottom procs duf dust fd httpie lazydocker glow
    fi
    ;;

  "arch" | "archarm")
    echo -e "${BLUE}正在通过 Pacman 安装依赖...${NC}"
    sudo pacman -S --noconfirm stow git neovim eza bat zoxide fzf ripgrep fastfetch kitty yazi tmux lazygit git-delta

    # 可选工具
    echo -e "${YELLOW}是否安装额外的现代化工具? (bottom, procs, duf, dust, fd, httpie) [y/N]${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      sudo pacman -S --noconfirm bottom procs duf dust fd httpie
    fi
    ;;

  "ubuntu" | "debian" | "raspbian")
    echo -e "${BLUE}正在通过 APT 安装基础依赖...${NC}"
    sudo apt update
    sudo apt install -y stow git neovim fzf ripgrep curl wget gpg kitty tmux

    # 安装 eza (现代化 ls 替代)
    if ! command_exists eza; then
      echo -e "${BLUE}安装 eza...${NC}"
      sudo mkdir -p /etc/apt/keyrings
      wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
      echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
      sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
      sudo apt update && sudo apt install -y eza
    fi

    # 安装 bat (在 Debian/Ubuntu 中叫 batcat)
    if ! command_exists bat && ! command_exists batcat; then
      echo -e "${BLUE}安装 bat...${NC}"
      sudo apt install -y bat
      mkdir -p ~/.local/bin
      ln -sf /usr/bin/batcat ~/.local/bin/bat
    fi

    # 安装 zoxide (智能 cd)
    if ! command_exists zoxide; then
      echo -e "${BLUE}安装 zoxide...${NC}"
      curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi

    # 安装 fastfetch (系统信息显示)
    if ! command_exists fastfetch; then
      echo -e "${BLUE}安装 fastfetch...${NC}"
      if command_exists add-apt-repository; then
        sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
        sudo apt update && sudo apt install -y fastfetch
      else
        echo -e "${YELLOW}无法自动安装 fastfetch，请手动从 GitHub 安装${NC}"
      fi
    fi

    # 安装 yazi (文件管理器 - 需要从源码安装或下载二进制)
    if ! command_exists yazi; then
      echo -e "${YELLOW}Yazi 需要手动安装，请访问: https://github.com/sxyazi/yazi${NC}"
    fi

    # 安装 lazygit (Git TUI)
    if ! command_exists lazygit; then
      echo -e "${BLUE}安装 lazygit...${NC}"
      LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
      curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
      tar xf lazygit.tar.gz lazygit
      sudo install lazygit /usr/local/bin
      rm lazygit lazygit.tar.gz
    fi

    # 安装 git-delta (更好的 git diff)
    if ! command_exists delta; then
      echo -e "${BLUE}安装 git-delta...${NC}"
      DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
      curl -Lo git-delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb"
      sudo dpkg -i git-delta.deb
      rm git-delta.deb
    fi

    # 可选工具
    echo -e "${YELLOW}是否安装额外的现代化工具? (bottom, duf, fd, httpie) [y/N]${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      sudo apt install -y fd-find duf httpie 2>/dev/null || echo -e "${YELLOW}部分工具需要更新的系统版本${NC}"

      # bottom (htop 替代)
      if ! command_exists btm; then
        echo -e "${BLUE}安装 bottom...${NC}"
        BOTTOM_VERSION=$(curl -s "https://api.github.com/repos/ClementTsang/bottom/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
        curl -Lo bottom.deb "https://github.com/ClementTsang/bottom/releases/latest/download/bottom_${BOTTOM_VERSION}_amd64.deb"
        sudo dpkg -i bottom.deb
        rm bottom.deb
      fi
    fi

    echo -e "${GREEN}Debian/Ubuntu 依赖安装完成！${NC}"
    echo -e "${YELLOW}注意: 某些工具可能需要重启终端才能生效${NC}"
    ;;

  *)
    echo -e "${RED}未识别的系统类型: $OS_TYPE，请手动安装基础依赖。${NC}"
    echo -e "${BLUE}基础依赖: stow git neovim eza bat zoxide fzf ripgrep fastfetch kitty yazi tmux${NC}"
    ;;
  esac
}

# 3. 执行安装流程
install_packages

# 4. 执行 Stow 部署
DOTFILES_DIR=$(
  cd "$(dirname "$0")"
  pwd
)
cd "$DOTFILES_DIR"

echo -e "${BLUE}正在使用 Stow 建立软链接...${NC}"

# 创建必要的目录
mkdir -p ~/.config
mkdir -p ~/.ssh/sockets
mkdir -p ~/.local/bin

# 强制清理冲突的旧文件（小心使用！）
for folder in nvim zsh yazi kitty tmux git editorconfig starship ssh; do
  # 如果目标位置有真实文件而不是链接，先备份
  if [ -f ~/."$folder" ] && ! [ -L ~/."$folder" ]; then
    echo -e "${YELLOW}备份旧文件: ~/.$folder -> ~/.$folder.bak${NC}"
    mv ~/."$folder" ~/."$folder".bak
  fi

  # 只 stow 存在的目录
  if [ -d "$folder" ]; then
    echo -e "${BLUE}部署 $folder 配置...${NC}"
    stow -R "$folder" # -R 代表 Restow，会重新计算链接
  fi
done

# 5. 安装 Zplug
if [ ! -d ~/.zplug ]; then
  echo -e "${BLUE}正在安装 zplug...${NC}"
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/zplug/master/installer.zsh | zsh
fi

echo -e "${GREEN}全平台配置部署成功！${NC}"
