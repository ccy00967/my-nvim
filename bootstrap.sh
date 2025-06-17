#!/bin/bash

echo "[0/6] 운영체제 및 Neovim 설치 방식 확인 중..."

OS="$(uname -s)"
IS_WSL=$(grep -i microsoft /proc/version 2>/dev/null && echo "yes" || echo "no")
ARCH="$(uname -m)"

install_neovim_ubuntu_debian() {
  echo "[INFO] Ubuntu/Debian 기반으로 감지됨"
  if ! command -v nvim &>/dev/null || [[ "$(nvim --version | head -n1 | awk '{print $2}' | sed 's/^v//')" < "0.8" ]]; then
    echo "[INFO] 최신 Neovim 설치를 위해 PPA 추가"
    sudo apt update
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:neovim-ppa/stable
    sudo apt update
    sudo apt install -y neovim
  else
    echo "[OK] Neovim이 이미 설치되어 있고 버전이 충분합니다."
  fi
}

install_neovim_centos() {
  echo "[INFO] CentOS 기반으로 감지됨"
  if ! command -v nvim &>/dev/null; then
    echo "[INFO] Neovim 설치 중 (EPEL 및 dnf 사용)"
    sudo yum install -y epel-release
    sudo yum install -y neovim
  else
    echo "[OK] Neovim이 이미 설치되어 있습니다."
  fi
}

install_neovim_mac() {
  echo "[INFO] macOS로 감지됨"
  if ! command -v brew &>/dev/null; then
    echo "[ERROR] Homebrew가 설치되어 있지 않습니다. https://brew.sh 참조 후 설치해주세요."
    exit 1
  fi
  brew install neovim
}

# OS별 설치
if [[ "$OS" == "Linux" ]]; then
  if [[ "$IS_WSL" == "yes" ]]; then
    echo "[INFO] WSL 환경 감지됨 → Ubuntu 방식 적용"
    install_neovim_ubuntu_debian
  elif [ -f /etc/debian_version ]; then
    install_neovim_ubuntu_debian
  elif [ -f /etc/redhat-release ] || grep -qi "centos" /etc/os-release; then
    install_neovim_centos
  else
    echo "[ERROR] 지원되지 않는 Linux 배포판입니다."
    exit 1
  fi
elif [[ "$OS" == "Darwin" ]]; then
  install_neovim_mac
else
  echo "[ERROR] 이 운영체제($OS)는 지원되지 않습니다."
  exit 1
fi

# 버전 확인
echo "[INFO] Neovim 버전:"
nvim --version | head -n 1

echo "[1/6] Neovim 설정 복사 중..."
if [ ! -d "$HOME/.config/nvim" ]; then
  mkdir -p "$HOME/.config"
  cp -r "$(pwd)" "$HOME/.config/nvim"
else
  echo "[!] ~/.config/nvim 디렉토리가 이미 존재합니다. 덮어쓰려면 삭제 후 다시 실행하세요."
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
if ! command -v node &>/dev/null; then
  echo "[INFO] Node.js가 설치되어 있지 않음 → 설치 진행"
  if [[ "$OS" == "Darwin" ]]; then
    brew install node
  else
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt install -y nodejs
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

