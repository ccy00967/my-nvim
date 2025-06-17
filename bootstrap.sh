#!/bin/bash

echo "[0/6] 운영체제 및 Neovim 버전 확인 중..."

OS="$(uname -s)"
current_version=$(nvim --version 2>/dev/null | head -n1 | awk '{print $2}' | sed 's/^v//')
min_version="0.8.0"

version_lt() {
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

install_neovim_appimage() {
  echo "[INFO] Neovim AppImage 다운로드 중..."
  curl -LO https://github.com/neovim/neovim/releases/download/v0.10.0/nvim.appimage
  chmod u+x nvim.appimage
  sudo mv nvim.appimage /usr/local/bin/nvim
  echo "[OK] /usr/local/bin/nvim 으로 최신 Neovim 설치 완료"
}

remove_old_neovim() {
  if command -v nvim &> /dev/null; then
    echo "[INFO] 기존 Neovim 제거 중..."
    sudo apt remove --purge -y neovim
    sudo rm -f /usr/bin/nvim
  fi
}

# 설치 여부 및 버전 체크
if ! command -v nvim &>/dev/null; then
  echo "[INFO] Neovim이 설치되어 있지 않음 → AppImage 설치 진행"
  install_neovim_appimage
elif version_lt "$current_version" "$min_version"; then
  echo "[INFO] 현재 Neovim 버전 $current_version (최소 요구: $min_version)"
  remove_old_neovim
  install_neovim_appimage
else
  echo "[OK] 현재 Neovim 버전 $current_version (충분함)"
fi

echo "[1/6] Neovim 설정 복사 중..."
if [ ! -d "$HOME/.config/nvim" ]; then
  mkdir -p "$HOME/.config"
  cp -r "$(pwd)" "$HOME/.config/nvim"
else
  echo "[!] ~/.config/nvim 디렉토리가 이미 존재합니다. 덮어쓰려면 수동 삭제 후 다시 실행하세요."
  exit 1
fi

echo "[2/6] vim-plug 설치 확인 중..."
if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
  curl -fLo "$HOME/.local/share/nvim/site/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
else
  echo "[OK] vim-plug는 이미 설치되어 있습니다."
fi

echo "[3/6] Node.js 설치 확인 중 (coc.nvim 용)..."
if ! command -v node &> /dev/null; then
  echo "[INFO] Node.js가 설치되어 있지 않음 → 설치 진행"
  if [[ "$OS" == "Linux" ]]; then
    sudo apt update && sudo apt install -y nodejs npm
  elif [[ "$OS" == "Darwin" ]]; then
    brew install node
  else
    echo "[ERROR] Node.js 자동 설치가 지원되지 않는 OS입니다: $OS"
  fi
else
  echo "[OK] Node.js는 이미 설치되어 있습니다."
fi

echo "[4/6] Neovim 플러그인 설치 중..."
nvim --headless +PlugInstall +qall

echo "[5/6] 플러그인 디렉토리 확인:"
ls "$HOME/.local/share/nvim/plugged"

echo "[6/6] 모든 설정이 완료되었습니다."
echo "nvim 을 실행하여 정상 작동하는지 확인하세요."

