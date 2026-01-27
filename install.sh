#!/usr/bin/env bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e "${BLUE}Analyzing system environment...${NC}"

# Helper function: check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# 1. Detect system type
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS_TYPE="macos"
  ARCH_TYPE=$(uname -m)
elif [[ -f /etc/os-release ]]; then
  # Source os-release to get distribution ID
  . /etc/os-release
  OS_TYPE=$ID
else
  # Fallback method
  OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
fi

echo -e "${BLUE}Detected system: ${GREEN}$OS_TYPE${NC}"
[[ -n "$ARCH_TYPE" ]] && echo -e "${BLUE}Architecture: ${GREEN}$ARCH_TYPE${NC}"

# 2. Define installation function
install_packages() {
  case $OS_TYPE in
  "macos")
    echo -e "${BLUE}Checking Homebrew...${NC}"
    if ! command_exists brew; then
      echo -e "${YELLOW}⚠️  Homebrew is not installed on your system.${NC}"
      echo -e "${YELLOW}   Homebrew is required to install most dependencies (git, neovim, etc.)${NC}"
      echo -e "${YELLOW}   Without Homebrew, the installation may fail or produce unpredictable errors.${NC}"
      echo ""
      echo -e "${BLUE}Do you want to install Homebrew now? [Y/n]${NC}"
      read -r response

      if [[ "$response" =~ ^[Nn]$ ]]; then
        echo -e "${RED}⚠️  Skipping Homebrew installation.${NC}"
        echo -e "${RED}   You will need to manually install all dependencies.${NC}"
        echo -e "${RED}   Installation may fail or be incomplete.${NC}"
        echo ""
        echo -e "${YELLOW}Press Enter to continue anyway, or Ctrl+C to abort...${NC}"
        read -r
      else
        echo -e "${BLUE}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Set Homebrew path based on architecture
        if [[ "$ARCH_TYPE" == "arm64" ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        else
          eval "$(/usr/local/bin/brew shellenv)"
        fi

        # Verify installation
        if command_exists brew; then
          echo -e "${GREEN}✓ Homebrew installed successfully${NC}"
        else
          echo -e "${RED}✗ Homebrew installation failed${NC}"
          echo -e "${RED}  Please install Homebrew manually: https://brew.sh${NC}"
          exit 1
        fi
      fi
    else
      echo -e "${GREEN}✓ Homebrew is already installed${NC}"
    fi

    echo -e "${BLUE}Installing dependencies via Homebrew...${NC}"
    brew install git nvim eza bat zoxide fzf ripgrep fastfetch kitty yazi tmux lazygit git-delta

    # Optional tools
    echo -e "${YELLOW}Install additional modern tools? (bottom, procs, duf, dust, fd, httpie) [y/N]${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      brew install bottom procs duf dust fd httpie lazydocker glow
    fi
    ;;

  "arch" | "archarm")
    echo -e "${BLUE}Installing dependencies via Pacman...${NC}"
    # 使用 --needed 避免重新安装已存在的包
    sudo pacman -S --needed --noconfirm git neovim eza bat zoxide fzf ripgrep fastfetch kitty yazi tmux lazygit git-delta || {
      echo -e "${RED}Failed to install some packages. Continuing anyway...${NC}"
    }

    # Optional tools
    echo -e "${YELLOW}Install additional modern tools? (bottom, procs, duf, dust, fd, httpie) [y/N]${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      sudo pacman -S --needed --noconfirm bottom procs duf dust fd httpie
    fi

    echo -e "${GREEN}Arch Linux dependencies installation complete!${NC}"
    ;;

  "ubuntu" | "debian" | "raspbian")
    echo -e "${BLUE}Installing base dependencies via APT...${NC}"
    sudo apt update
    sudo apt install -y git neovim fzf ripgrep curl wget gpg kitty tmux

    # Install eza (modern ls replacement)
    if ! command_exists eza; then
      echo -e "${BLUE}Installing eza...${NC}"
      sudo mkdir -p /etc/apt/keyrings
      wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
      echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
      sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
      sudo apt update && sudo apt install -y eza
    fi

    # Install bat (called batcat on Debian/Ubuntu)
    if ! command_exists bat && ! command_exists batcat; then
      echo -e "${BLUE}Installing bat...${NC}"
      sudo apt install -y bat
      mkdir -p ~/.local/bin
      ln -sf /usr/bin/batcat ~/.local/bin/bat
    fi

    # Install zoxide (smart cd)
    if ! command_exists zoxide; then
      echo -e "${BLUE}Installing zoxide...${NC}"
      curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi

    # Install fastfetch (system info)
    if ! command_exists fastfetch; then
      echo -e "${BLUE}Installing fastfetch...${NC}"
      if command_exists add-apt-repository; then
        sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
        sudo apt update && sudo apt install -y fastfetch
      else
        echo -e "${YELLOW}Cannot auto-install fastfetch, please install manually from GitHub${NC}"
      fi
    fi

    # Install yazi (file manager - requires manual install or binary download)
    if ! command_exists yazi; then
      echo -e "${YELLOW}Yazi requires manual installation, visit: https://github.com/sxyazi/yazi${NC}"
    fi

    # Install lazygit (Git TUI)
    if ! command_exists lazygit; then
      echo -e "${BLUE}Installing lazygit...${NC}"
      LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
      curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
      tar xf lazygit.tar.gz lazygit
      sudo install lazygit /usr/local/bin
      rm lazygit lazygit.tar.gz
    fi

    # Install git-delta (better git diff)
    if ! command_exists delta; then
      echo -e "${BLUE}Installing git-delta...${NC}"
      DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
      curl -Lo git-delta.deb "https://github.com/dandavison/delta/releases/latest/download/git-delta_${DELTA_VERSION}_amd64.deb"
      sudo dpkg -i git-delta.deb
      rm git-delta.deb
    fi

    # Optional tools
    echo -e "${YELLOW}Install additional modern tools? (bottom, duf, fd, httpie) [y/N]${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
      sudo apt install -y fd-find duf httpie 2>/dev/null || echo -e "${YELLOW}Some tools require newer system version${NC}"

      # bottom (htop replacement)
      if ! command_exists btm; then
        echo -e "${BLUE}Installing bottom...${NC}"
        BOTTOM_VERSION=$(curl -s "https://api.github.com/repos/ClementTsang/bottom/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
        curl -Lo bottom.deb "https://github.com/ClementTsang/bottom/releases/latest/download/bottom_${BOTTOM_VERSION}_amd64.deb"
        sudo dpkg -i bottom.deb
        rm bottom.deb
      fi
    fi

    echo -e "${GREEN}Debian/Ubuntu dependencies installation complete!${NC}"
    echo -e "${YELLOW}Note: Some tools may require terminal restart to take effect${NC}"
    ;;

  *)
    echo -e "${RED}Unrecognized system type: $OS_TYPE, please install dependencies manually.${NC}"
    echo -e "${BLUE}Required dependencies: git neovim eza bat zoxide fzf ripgrep fastfetch kitty yazi tmux${NC}"
    ;;
  esac
}

# 3. Execute installation
install_packages

# 4. Install Antidote (BEFORE stow to avoid shell errors)
echo -e "${BLUE}Checking Antidote (Zsh plugin manager)...${NC}"

ANTIDOTE_INSTALLED=false

# Check common antidote installation paths
if command_exists antidote; then
  ANTIDOTE_INSTALLED=true
  echo -e "${GREEN}✓ Antidote already installed (via package manager)${NC}"
elif [ -f "${ZDOTDIR:-~}/.antidote/antidote.zsh" ]; then
  ANTIDOTE_INSTALLED=true
  echo -e "${GREEN}✓ Antidote already installed (at ${ZDOTDIR:-~}/.antidote)${NC}"
fi

if [ "$ANTIDOTE_INSTALLED" = false ]; then
  echo -e "${BLUE}Installing Antidote...${NC}"

  # Install based on OS
  case $OS_TYPE in
  "macos")
    if command_exists brew; then
      brew install antidote
    else
      # Fallback to git clone
      git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-~}/.antidote"
    fi
    ;;
  *)
    # For Linux and others, use git clone
    git clone --depth=1 https://github.com/mattmc3/antidote.git "${ZDOTDIR:-~}/.antidote"
    ;;
  esac

  # Verify installation
  if command_exists antidote || [ -f "${ZDOTDIR:-~}/.antidote/antidote.zsh" ]; then
    echo -e "${GREEN}✓ Antidote installed successfully${NC}"
  else
    echo -e "${YELLOW}⚠️  Antidote installation may have failed${NC}"
    echo -e "${YELLOW}   Zsh plugins may not work correctly${NC}"
  fi
fi

# 5. Install development environment tools (BEFORE stow!)
echo -e "${BLUE}Checking development tools...${NC}"

# Install NVM (Node Version Manager)
if [ -d "$HOME/.nvm" ]; then
  # Load NVM temporarily to get version info
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  NVM_VERSION=$(nvm --version 2>/dev/null || echo "unknown")
  echo -e "${GREEN}✓ NVM already installed (version: ${NVM_VERSION})${NC}"

  # Check if Node.js is installed
  if command_exists node; then
    NODE_VERSION=$(node --version 2>/dev/null)
    echo -e "${GREEN}  - Node.js: ${NODE_VERSION}${NC}"
  else
    echo -e "${YELLOW}  - No Node.js version installed${NC}"
    echo -e "${YELLOW}  Tip: Run 'nvm install --lts' to install Node.js LTS${NC}"
  fi

  echo -e "${YELLOW}Reinstall NVM? [y/N]${NC}"
  read -r response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Reinstalling NVM...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    # Reload NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    echo -e "${GREEN}NVM reinstallation complete${NC}"
  fi
else
  echo -e "${BLUE}Installing NVM...${NC}"
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

  # Load NVM temporarily
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  # Install Node.js LTS version
  if command_exists nvm; then
    echo -e "${BLUE}Installing Node.js LTS via NVM...${NC}"
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'
  fi
fi

# Install uv (Python package manager)
if command_exists uv; then
  UV_VERSION=$(uv --version 2>/dev/null | awk '{print $2}' || echo "unknown")
  echo -e "${GREEN}✓ uv already installed (version: ${UV_VERSION})${NC}"

  echo -e "${YELLOW}Reinstall uv? [y/N]${NC}"
  read -r response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Reinstalling uv (Python package manager)...${NC}"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add uv to current PATH
    export PATH="$HOME/.local/bin:$PATH"
    UV_VERSION=$(uv --version 2>/dev/null | awk '{print $2}' || echo "unknown")
    echo -e "${GREEN}uv reinstallation complete (version: ${UV_VERSION})${NC}"
  fi
else
  echo -e "${BLUE}Installing uv (Python package manager)...${NC}"
  curl -LsSf https://astral.sh/uv/install.sh | sh

  # Add uv to current PATH
  export PATH="$HOME/.local/bin:$PATH"

  if command_exists uv; then
    UV_VERSION=$(uv --version 2>/dev/null | awk '{print $2}' || echo "unknown")
    echo -e "${GREEN}uv installation complete (version: ${UV_VERSION})${NC}"
  fi
fi

# 6. Create symlinks (AFTER all dependencies are installed!)
DOTFILES_DIR=$(
  cd "$(dirname "$0")"
  pwd
)
cd "$DOTFILES_DIR"

echo -e "${BLUE}Creating symlinks...${NC}"

# Create necessary directories
mkdir -p ~/.config
mkdir -p ~/.ssh/sockets
mkdir -p ~/.local/bin

# Helper function: create symlink with backup
create_symlink() {
  local source="$1"
  local target="$2"

  if [ -L "$target" ]; then
    echo -e "${YELLOW}  Removing existing symlink: $target${NC}"
    rm "$target"
  elif [ -e "$target" ]; then
    echo -e "${YELLOW}  Backing up: $target -> ${target}.bak${NC}"
    mv "$target" "${target}.bak"
  fi

  ln -s "$source" "$target"
  echo -e "${GREEN}  ✓ Linked: $target -> $source${NC}"
}

# Helper function: get config info (bash 3.x compatible)
# Returns: folder:src_rel:target
get_config_info() {
  local config_key="$1"
  case "$config_key" in
    nvim)        echo "nvim:.config/nvim:$HOME/.config/nvim" ;;
    zsh)         echo "zsh:.zshrc:$HOME/.zshrc" ;;
    zsh_plugins) echo "zsh:.zsh_plugins.txt:$HOME/.zsh_plugins.txt" ;;
    yazi)        echo "yazi:.config/yazi:$HOME/.config/yazi" ;;
    kitty)       echo "kitty:.config/kitty:$HOME/.config/kitty" ;;
    tmux)        echo "tmux:.tmux.conf:$HOME/.tmux.conf" ;;
    git)         echo "git:.gitconfig:$HOME/.gitconfig" ;;
    editorconfig) echo "editorconfig:.editorconfig:$HOME/.editorconfig" ;;
    starship)    echo "starship:.config/starship.toml:$HOME/.config/starship.toml" ;;
    ssh)         echo "ssh:.ssh/config:$HOME/.ssh/config" ;;
  esac
}

echo ""
echo -e "${BLUE}=== Configuration Symlinks ===${NC}"
echo -e "${YELLOW}For each config, enter y to create symlink, n to skip${NC}"
echo ""

for config_key in nvim zsh zsh_plugins yazi kitty tmux git editorconfig starship ssh; do
  config_info=$(get_config_info "$config_key")

  # Parse folder:src_rel:target
  actual_folder=$(echo "$config_info" | cut -d: -f1)
  src_rel=$(echo "$config_info" | cut -d: -f2)
  target=$(echo "$config_info" | cut -d: -f3)

  if [ -d "$actual_folder" ]; then
    source_path="$DOTFILES_DIR/$actual_folder/$src_rel"

    if [ -e "$source_path" ]; then
      echo -e "${BLUE}[$config_key]${NC} $target"
      read -p "  Create symlink? [y/N] " response
      if [[ "$response" =~ ^[Yy]$ ]]; then
        # Ensure parent directory exists
        mkdir -p "$(dirname "$target")"
        create_symlink "$source_path" "$target"
      else
        echo -e "  Skipped"
      fi
      echo ""
    else
      echo -e "${YELLOW}[$config_key] Source not found: $source_path, skipping${NC}"
    fi
  fi
done

echo -e "${GREEN}Dotfiles setup complete!${NC}"
echo -e "${YELLOW}Tip: Restart your terminal or run 'source ~/.zshrc' to apply changes${NC}"
