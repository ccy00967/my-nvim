#!/bin/bash

set -e

echo "[0/6] 운영체제 및 Neovim 버전 확인 중..."

# 기존 nvim 제거
echo "[INFO] 기존 Neovim 제거 중..."
sudo rm -f /usr/bin/nvim /usr/local/bin/nvim

# 최신 Neovim 다운로드 (v0.11.2)
echo "[INFO] Neovim v0.11.2 다운로드 중..."
curl -LO https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux64.tar.gz
tar xzf nvim-linux64.tar.gz
sudo mv nvim-linux64 /opt/nvim
sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

# 확인
echo "[OK] Neovim 설치 완료: $(nvim --version | head -n 1)"

echo "[1/6] Neovim 설정 복사 중..."
mkdir -p ~/.config/nvim
cp -r ./nvim/* ~/.config/nvim/

echo "[2/6] vim-plug 설치 중..."
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "[3/6] Node.js 설치 확인 중 (coc.nvim 용)..."
if ! command -v node >/dev/null; then
  echo "[INFO] Node.js가 없어 설치합니다..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
  sudo apt-get install -y nodejs
else
  echo "[OK] Node.js는 이미 설치되어 있습니다."
fi

echo "[4/6] Neovim 플러그인 설치 중..."
nvim --headless +PlugInstall +qall || true
nvim --headless +TSUpdate +qall || true

echo "[5/6] 필수 플러그인 확인:"
ls ~/.local/share/nvim/plugged/ || echo "[WARN] 플러그인 설치가 실패했을 수 있습니다."

echo "[6/6] 모든 설정이 완료되었습니다. nvim을 실행해보세요."

