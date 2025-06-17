#!/bin/bash

echo "[🌀] Neovim 설정 초기화 스크립트 실행 중..."

# 설정 복사
if [ ! -d "$HOME/.config/nvim" ]; then
  echo "[📁] ~/.config/nvim 디렉토리가 없습니다. 복사 중..."
  mkdir -p "$HOME/.config"
  cp -r "$(pwd)" "$HOME/.config/nvim"
else
  echo "[⚠️] 이미 ~/.config/nvim 디렉토리가 존재합니다. 덮어쓰기 원하면 수동 삭제 필요."
  exit 1
fi

# vim-plug 설치
if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
  echo "[📦] vim-plug 설치 중..."
  curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
else
  echo "[✔] vim-plug 이미 설치됨"
fi

# 플러그인 설치
echo "[🔧] 플러그인 설치 중 (PlugInstall)..."
nvim +PlugInstall +qall

echo "[✅] Neovim 설정 완료! 이제 'nvim' 명령으로 시작해보세요 🎉"

