#!/bin/bash
set -e

NVIM_VERSION="v0.11.2"
NVIM_TAR="nvim-linux-x86_64.tar.gz"
NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_TAR}"
INSTALL_DIR="/usr/local"

echo "[1/8] 시스템 정보 확인 중..."
OS_TYPE=$(uname -s)
ARCH=$(uname -m)

# /etc/os-release 파싱 (리눅스 전용)
if [[ "$OS_TYPE" == "Linux" ]]; then
  if grep -q WSL /proc/version; then
    PLATFORM="wsl"
  else
    source /etc/os-release
    PLATFORM="${ID,,}"
  fi
elif [[ "$OS_TYPE" == "Darwin" ]]; then
  PLATFORM="macos"
else
  echo "지원되지 않는 운영체제입니다: $OS_TYPE"
  exit 1
fi

# Neovim 제거
echo "[2/8] 기존 Neovim 제거..."
command -v nvim >/dev/null && sudo rm -f "$(command -v nvim)"

# macOS는 brew, 그 외는 tar.gz
echo "[3/8] Neovim 설치 중..."
if [[ "$PLATFORM" == "macos" ]]; then
  brew install neovim
else
  wget -q --show-progress "$NVIM_URL"
  tar xzf "$NVIM_TAR"
  sudo cp -r nvim-linux-*/* "$INSTALL_DIR/"
  rm -rf "$NVIM_TAR" nvim-linux-*
fi

# vim-plug
echo "[4/8] vim-plug 설치 중..."
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Node.js 설치
echo "[5/8] Node.js 설치 확인 중..."
if ! command -v node >/dev/null; then
  if [[ "$PLATFORM" == "ubuntu" || "$PLATFORM" == "debian" ]]; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
  elif [[ "$PLATFORM" == "centos" || "$PLATFORM" == "rhel" ]]; then
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
    sudo yum install -y nodejs
  elif [[ "$PLATFORM" == "macos" ]]; then
    brew install node
  elif [[ "$PLATFORM" == "wsl" ]]; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi
else
  echo "[INFO] Node.js 이미 설치됨"
fi

# tree-sitter CLI
echo "[6/8] tree-sitter CLI 설치 확인 중..."
if ! command -v tree-sitter >/dev/null; then
  if command -v npm >/dev/null; then
    sudo npm install -g tree-sitter-cli
  else
    echo "[경고] npm이 없어 tree-sitter CLI 설치를 건너뜁니다."
  fi
else
  echo "[INFO] tree-sitter CLI 이미 설치됨"
fi

# 설정 복사
echo "[7/8] Neovim 설정 복사 중..."
mkdir -p ~/.config/nvim
cp -r ./nvim-config/* ~/.config/nvim/

# 플러그인 설치
echo "[8/8] Neovim 플러그인 설치 시작..."
nvim --headless +PlugInstall +qall

echo "✅ 설치 완료: nvim을 실행해보세요!"

