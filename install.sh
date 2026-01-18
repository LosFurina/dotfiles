#!/usr/bin/env bash

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}开始分析系统环境...${NC}"

# 1. 精准识别系统
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS_TYPE="macos"
elif [[ -f /etc/os-release ]]; then
  # 通过 source 命令直接把 os-release 里的变量（如 ID）读入当前脚本环境
  . /etc/os-release
  OS_TYPE=$ID
else
  # 最后的保底手段
  OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
fi

echo -e "${BLUE}检测到系统类型: ${GREEN}$OS_TYPE${NC}"

# 2. 定义安装函数
install_packages() {
  case $OS_TYPE in
  "macos")
    echo -e "${BLUE}正在通过 Homebrew 安装依赖...${NC}"
    brew install stow git nvim eza bat zoxide fzf ripgrep fastfetch
    ;;
  "arch" | "archarm")
    echo -e "${BLUE}正在通过 Pacman 安装依赖...${NC}"
    sudo pacman -S --noconfirm stow git neovim eza bat zoxide fzf ripgrep fastfetch
    ;;
  "ubuntu" | "debian" | "raspbian")
    echo -e "${BLUE}正在通过 APT 安装基础依赖...${NC}"
    sudo apt update && sudo apt install -y stow git neovim fzf ripgrep curl
    # 针对 Ubuntu 的现代工具补齐
    echo -e "${RED}注意: Ubuntu 源中的 eza/bat/zoxide 可能版本很旧或不存在。${NC}"
    echo -e "${BLUE}建议通过 Cargo 或官方 Github .deb 安装最新版。${NC}"
    ;;
  *)
    echo -e "${RED}未识别的系统类型: $OS_TYPE，请手动安装基础依赖。${NC}"
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
# 强制清理冲突的旧文件（小心使用！）
for folder in nvim zsh yazi; do
  # 如果目标位置有真实文件而不是链接，先备份
  [ -f ~/."$folder" ] && ![ -L ~/."$folder" ] && mv ~/."$folder" ~/."$folder".bak
  stow -R "$folder" # -R 代表 Restow，会重新计算链接
done

# 5. 安装 Zplug
if [ ! -d ~/.zplug ]; then
  echo -e "${BLUE}正在安装 zplug...${NC}"
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/zplug/master/installer.zsh | zsh
fi

echo -e "${GREEN}全平台配置部署成功！${NC}"
