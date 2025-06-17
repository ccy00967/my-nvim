#!/bin/bash

set -e

NVIM_VERSION="v0.11.2"
NVIM_TAR="nvim-linux-x86_64.tar.gz"
NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_TAR}"
INSTALL_DIR="/usr/local"
NODE_MIN_VERSION="16"

echo "[1/8] OS 및 Neovim 설치 상태 확인 중..."
OS_ID=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
ARCH=$(uname -m)

if ! command -v nvim >/dev/null; then
  echo "[INFO] Neovim 미설치 상태. 설치를 진행합니다."
else
  echo "[INFO] 기존 Neovim 제거 중..."
  sudo rm -f "$(command -v nvim)" || true
fi

echo "[2/8] Neovim ${NVIM_VERSION} 다운로드 중..."
wget -q --show-progress "${NVIM_URL}"
tar xzf "${NVIM_TAR}"

echo "[3/8] Neovim 설치 중..."
sudo cp -r nvim-linux-*/* "${INSTALL_DIR}/"
rm -rf nvim-linux-* "${NVIM_TAR}"

echo "[4/8] vim-plug 설치 중..."
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "[5/8] Node.js 설치 확인 중..."
if ! command -v node >/dev/null; then
  echo "[INFO] Node.js가 없어 설치를 진행합니다."
  if [[ "$OS_ID" == "ubuntu" || "$OS_ID" == "debian" ]]; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
  elif [[ "$OS_ID" == "centos" || "$OS_ID" == "rhel" ]]; then
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
    sudo yum install -y nodejs
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install node
  fi
else
  echo "[INFO] Node.js는 이미 설치되어 있음"
fi

echo "[6/8] tree-sitter CLI 설치 확인 중..."
if ! command -v tree-sitter >/dev/null; then
  echo "[INFO] tree-sitter CLI 미설치 상태. 설치를 진행합니다."
  if command -v npm >/dev/null; then
    sudo npm install -g tree-sitter-cli
  else
    echo "[경고] npm이 없어 tree-sitter를 설치할 수 없습니다. Node.js가 올바르게 설치되었는지 확인하세요."
  fi
else
  echo "[INFO] tree-sitter CLI는 이미 설치되어 있음"
fi

echo "[7/8] Neovim 설정 복사 중..."
mkdir -p ~/.config/nvim
cp -r ./nvim-config/* ~/.config/nvim/

echo "[8/8] Neovim 플러그인 설치 시작..."
nvim --headless +PlugInstall +qall

echo "✅ Neovim 설치 및 설정 완료. 'nvim' 명령어로 실행할 수 있습니다."

