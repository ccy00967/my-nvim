#!/bin/bash

set -e

NEOVIM_VERSION="v0.11.2"
NEOVIM_URL="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux64.tar.gz"
INSTALL_DIR="/opt/nvim"

echo "[0/6] 운영체제 및 Neovim 버전 확인 중..."

OS_TYPE="$(uname -s)"
IS_MAC=false
if [[ "$OS_TYPE" == "Darwin" ]]; then
  IS_MAC=true
fi

if ! command -v nvim >/dev/null 2>&1; then
  echo "[INFO] Neovim이 설치되어 있지 않습니다."
else
  NVIM_VER=$(nvim --version | head -n1 | grep -oP 'v?\K[0-9]+\.[0-9]+')
  if [[ $(echo "$NVIM_VER < 0.8" | bc -l) -eq 1 ]]; then
    echo "[INFO] 기존 Neovim 제거 중..."
    if $IS_MAC; then
      brew uninstall neovim || true
    elif [ -f /etc/debian_version ]; then
      sudo apt remove -y neovim || true
    elif [ -f /etc/redhat-release ]; then
      sudo yum remove -y neovim || true
    fi
  else
    echo "[OK] 현재 Neovim 버전은 충분합니다. ($NVIM_VER)"
  fi
fi

echo "[INFO] Neovim ${NEOVIM_VERSION} 다운로드 중..."
curl -L -o nvim-linux64.tar.gz "${NEOVIM_URL}"

if file nvim-linux64.tar.gz | grep -q "gzip compressed"; then
  tar xzf nvim-linux64.tar.gz
  sudo rm -rf "$INSTALL_DIR"
  sudo mv nvim-linux64 "$INSTALL_DIR"
  sudo ln -sf "$INSTALL_DIR/bin/nvim" /usr/local/bin/nvim
  rm -f nvim-linux64.tar.gz
  echo "[OK] Neovim ${NEOVIM_VERSION} 설치 완료"
else
  echo "[ERROR] 다운로드한 파일이 gzip 형식이 아닙니다."
  head nvim-linux64.tar.gz
  exit 1
fi

echo "[1/6] Neovim 설정 복사 중..."
mkdir -p ~/.config/nvim
cp -r ./init.vim ./after ./coc-settings.json ~/.config/nvim/ 2>/dev/null || true

echo "[2/6] vim-plug 설치 확인 중..."
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "[3/6] Node.js 설치 확인 중 (coc.nvim 용)..."
if ! command -v node >/dev/null 2>&1; then
  if $IS_MAC; then
    brew install node
  elif [ -f /etc/debian_version ]; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
  elif [ -f /etc/redhat-release ]; then
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
    sudo yum install -y nodejs
  fi
else
  echo "[OK] Node.js는 이미 설치되어 있습니다."
fi

echo "[4/6] Neovim 플러그인 설치 중..."
nvim --headless +PlugInstall +qa

echo "[5/6] 플러그인 디렉토리 확인:"
ls ~/.local/share/nvim/plugged || echo "[INFO] 플러그인이 설치되지 않았습니다."

echo "[6/6] 모든 설정이 완료되었습니다."
echo "Neovim을 실행하여 정상 작동하는지 확인하세요: nvim"

