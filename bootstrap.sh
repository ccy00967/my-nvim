#!/bin/bash

set -e

NEOVIM_VERSION="v0.11.2"
NEOVIM_URL="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux64.tar.gz"
INSTALL_DIR="/opt/nvim"

echo "[0/6] 운영체제 및 Neovim 버전 확인 중..."

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Linux)
    echo "[INFO] Linux 환경 감지됨"
    ;;
  Darwin)
    echo "[INFO] macOS 환경 감지됨"
    ;;
  *)
    echo "[ERROR] 지원되지 않는 운영체제: $OS"
    exit 1
    ;;
esac

# 기존 nvim 제거
echo "[INFO] 기존 Neovim 제거 중..."
sudo rm -rf /usr/local/bin/nvim /opt/nvim
sudo apt remove -y neovim 2>/dev/null || true
sudo dnf remove -y neovim 2>/dev/null || true
sudo yum remove -y neovim 2>/dev/null || true
brew uninstall neovim 2>/dev/null || true

# 최신 Neovim 다운로드 및 설치
echo "[INFO] Neovim ${NEOVIM_VERSION} 다운로드 중..."
curl -L -o nvim-linux64.tar.gz "${NEOVIM_URL}"

if file nvim-linux64.tar.gz | grep -q "gzip compressed"; then
    tar xzf nvim-linux64.tar.gz
    sudo mv nvim-linux64 "${INSTALL_DIR}"
    sudo ln -sf "${INSTALL_DIR}/bin/nvim" /usr/local/bin/nvim
    rm -f nvim-linux64.tar.gz
    echo "[OK] Neovim ${NEOVIM_VERSION} 설치 완료"
else
    echo "[ERROR] 다운로드한 파일이 gzip 형식이 아닙니다."
    exit 1
fi

# 설정 복사
echo "[1/6] Neovim 설정 복사 중..."
mkdir -p ~/.config/nvim
cp -r ./init.vim ./after ./coc-settings.json ~/.config/nvim/

# vim-plug 설치
echo "[2/6] vim-plug 설치 확인 중..."
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Node.js 설치 (coc.nvim용)
echo "[3/6] Node.js 설치 확인 중..."
if ! command -v node >/dev/null 2>&1; then
    echo "[INFO] Node.js 설치 중..."
    if [[ "$OS" == "Darwin" ]]; then
        brew install node
    else
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
else
    echo "[OK] Node.js는 이미 설치되어 있습니다."
fi

# 플러그인 설치
echo "[4/6] Neovim 플러그인 설치 중..."
nvim +'PlugInstall --sync' +qa

# 확인
echo "[5/6] 플러그인 디렉토리 확인:"
ls ~/.local/share/nvim/plugged || echo "⚠️ 플러그인이 설치되지 않았을 수 있습니다."

# 종료 안내
echo "[6/6] 모든 설정이 완료되었습니다."
echo "nvim 을 실행하여 정상 작동하는지 확인하세요."

