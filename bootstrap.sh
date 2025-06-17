#!/bin/bash

echo "[✔] Neovim 설정 초기화 시작"

# vim-plug 설치
if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
  echo "[✔] vim-plug 설치 중..."
  curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
  echo "[✔] vim-plug 이미 설치됨"
fi

# 플러그인 설치
echo "[✔] Neovim 플러그인 설치 시작..."
nvim +PlugInstall +qall

echo "[✔] 완료! 이제 Neovim을 사용하세요 :)"

