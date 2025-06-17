#!/bin/bash

echo "[1/5] Neovim 설정 복사 중..."
if [ ! -d "$HOME/.config/nvim" ]; then
  mkdir -p "$HOME/.config"
  cp -r "$(pwd)" "$HOME/.config/nvim"
else
  echo "[!] ~/.config/nvim 디렉토리가 이미 존재합니다. 덮어쓰려면 수동으로 삭제해주세요."
  exit 1
fi

echo "[2/5] vim-plug 설치 확인..."
if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
  curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
  echo "[OK] vim-plug는 이미 설치되어 있습니다."
fi

echo "[3/5] Node.js 설치 확인..."
if ! command -v node &> /dev/null; then
  echo "[INFO] Node.js가 설치되어 있지 않습니다. 설치를 진행합니다. (Ubuntu 기준)"
  sudo apt update
  sudo apt install -y nodejs npm
else
  echo "[OK] Node.js는 이미 설치되어 있습니다."
fi

echo "[4/5] Neovim 플러그인 설치 중..."
nvim --headless +PlugInstall +qall

echo "[5/5] 모든 설정이 완료되었습니다."
echo "Neovim을 실행하여 정상 작동하는지 확인해보세요."

