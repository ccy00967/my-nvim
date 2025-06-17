#!/bin/bash

echo "[0/6] 운영체제 및 Neovim 버전 확인 중..."

OS="$(uname -s)"
ARCH="$(uname -m)"
current_version=$(nvim --version 2>/dev/null | head -n1 | awk '{print $2}' | sed 's/^v//')
min_version="0.8.0"

version_lt() {
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

install_neovim_linux() {
  echo "[INFO] Ubuntu/Debian 계열로 감지됨. Neovim AppImage 설치 중..."
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
  chmod u+x nvim.appimage
  sudo mv nvim.appimage /usr/local/bin/nvim
  echo "[OK] Neovim 최신 버전 설치 완료 (/usr/local/bin/nvim)"
}

install_neovim_mac() {
  if ! command -v brew &>/dev/null; then
    echo "[ERROR] macOS에서 Homebrew가 설치되어 있지 않습니다. https://brew.sh 참고 후 설치해주세요."
    exit 1
  fi
  echo "[INFO] macOS로 감지됨. Homebrew로 Neovim 설치 중..."
  brew install neovim
  echo "[OK] Neovim 설치 완료"
}

if ! command -v nvim &>/dev/null; then
  echo "[INFO] Neovim이 설치되어 있지 않습니다."
  install_neovim_linux
elif version_lt "$current_version" "$min_version"; then
  echo "[INFO] 현재 Neovim 버전($current_version)이 너무 낮습니다. 최신 버전 설치 중..."
  if [[ "$OS" == "Linux" ]]; then
    install_neovim_linux
  elif [[ "$OS" == "Darwin" ]]; then
    install_neovim_mac
  else
    echo "[ERROR] 자동 설치가 지원되지 않는 운영체제입니다: $OS"
    exit 1
  fi
else
  echo "[OK] 현재 Neovim 버전: $current_version (충분함)"
fi

echo "[1/6] Neovim 설정 복사 중..."
if [ ! -d "$HOME/.config/nvim" ]; then
  mkdir -p "$HOME/.config"
  cp -r "$(pwd)" "$HOME/.config/nvim"
else
  echo "[!] ~/.config/nvim 디렉토리가 이미 존재합니다. 덮어쓰려면 수동으로 삭제 후 재실행하세요."
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
  echo "[INFO] Node.js가 설치되어 있지 않습니다. 설치 중..."
  if [[ "$OS" == "Linux" ]]; then
    sudo apt update && sudo apt install -y nodejs npm
  elif [[ "$OS" == "Darwin" ]]; then
    brew install node
  else
    echo "[ERROR] Node.js 설치 자동화가 지원되지 않는 운영체제입니다."
  fi
else
  echo "[OK] Node.js는 이미 설치되어 있습니다."
fi

echo "[4/6] Neovim 플러그인 설치 중..."
nvim --headless +PlugInstall +qall

echo "[5/6] 플러그인 설치 완료 여부 확인:"
ls "$HOME/.local/share/nvim/plugged"

echo "[6/6] 모든 설정이 완료되었습니다."
echo "Neovim을 실행하여 정상 작동하는지 확인하세요: nvim"

