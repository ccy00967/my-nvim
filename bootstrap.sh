#!/bin/bash
set -e

REQUIRED_VERSION="0.8.0"
NEOVIM_VERSION="0.11.2"
NEOVIM_TAR="nvim-linux64.tar.gz"
NEOVIM_URL="https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/${NEOVIM_TAR}"
INSTALL_DIR="/opt/nvim"
BIN_PATH="/usr/local/bin/nvim"
IS_MAC=false

# [0] OS 확인
echo "[0/6] 운영체제 및 Neovim 버전 확인 중..."
OS=$(uname -s)

if [[ "$OS" == "Darwin" ]]; then
  IS_MAC=true
elif [[ -f /etc/os-release ]]; then
  . /etc/os-release
  DISTRO=$ID
else
  echo "[ERROR] 지원되지 않는 OS입니다."
  exit 1
fi

# [1] 현재 Neovim 버전 확인
check_neovim_version() {
  if ! command -v nvim &> /dev/null; then
    echo "[INFO] Neovim이 설치되어 있지 않습니다."
    return 1
  fi

  current=$(nvim --version | head -n 1 | awk '{print $2}' | sed 's/^v//')
  if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$current" | sort -V | head -n1)" = "$REQUIRED_VERSION" ]; then
    echo "[OK] Neovim 버전 $current 이상"
    return 0
  else
    echo "[WARN] Neovim 버전 $current < $REQUIRED_VERSION"
    return 1
  fi
}

# [2] Neovim 설치
install_neovim() {
  echo "[INFO] Neovim $NEOVIM_VERSION 설치 중..."

  # 기존 제거
  if command -v nvim &> /dev/null; then
    echo "[INFO] 기존 Neovim 제거 중..."
    if [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
      sudo apt remove -y neovim || true
    elif [[ "$DISTRO" == "centos" || "$DISTRO" == "rhel" ]]; then
      sudo yum remove -y neovim || true
    fi
  fi

  # 다운로드 및 설치
  curl -LO "$NEOVIM_URL"
  tar -xzf "$NEOVIM_TAR"
  sudo rm -rf "$INSTALL_DIR"
  sudo mv nvim-linux64 "$INSTALL_DIR"
  sudo ln -sf "$INSTALL_DIR/bin/nvim" "$BIN_PATH"
  rm "$NEOVIM_TAR"
}

# [3] 설정 복사
setup_config() {
  echo "[1/6] Neovim 설정 복사 중..."
  mkdir -p ~/.config/nvim
  cp -r init.vim after coc-settings.json ~/.config/nvim/
}

# [4] vim-plug 설치
install_vimplug() {
  echo "[2/6] vim-plug 설치 중..."
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

# [5] Node.js 설치
install_node() {
  echo "[3/6] Node.js 확인 중..."
  if ! command -v node &> /dev/null; then
    echo "[INFO] Node.js 설치 중..."
    if $IS_MAC; then
      brew install node
    elif [[ "$DISTRO" == "ubuntu" || "$DISTRO" == "debian" ]]; then
      curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
      sudo apt install -y nodejs
    elif [[ "$DISTRO" == "centos" || "$DISTRO" == "rhel" ]]; then
      curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
      sudo yum install -y nodejs
    else
      echo "[WARN] Node.js 설치 명령을 찾을 수 없습니다."
    fi
  else
    echo "[OK] Node.js는 이미 설치되어 있습니다."
  fi
}

# [6] 플러그인 설치
install_plugins() {
  echo "[4/6] Neovim 플러그인 설치 중..."
  nvim --headless +PlugInstall +qall
}

# [실행]
if ! check_neovim_version; then
  install_neovim
fi

setup_config
install_vimplug
install_node
install_plugins

echo "[5/6] 플러그인 디렉토리 확인:"
ls ~/.local/share/nvim/plugged || echo "[WARN] 플러그인 디렉토리가 비어있습니다."

echo "[6/6] 모든 설정이 완료되었습니다."
echo "nvim 을 실행하여 정상 작동하는지 확인하세요!"

