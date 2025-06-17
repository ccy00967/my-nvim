#!/bin/bash

set -e

NEOVIM_MIN_VERSION="0.8.0"

echo "[1/5] 운영체제 및 Neovim 버전 확인 중..."

# OS 확인
OS=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/debian_version ]; then
        OS="debian"
    elif [ -f /etc/redhat-release ]; then
        OS="centos"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="mac"
elif grep -qi microsoft /proc/version; then
    OS="wsl"
else
    echo "지원하지 않는 운영체제입니다."
    exit 1
fi

# Neovim 버전 확인 함수
get_nvim_version() {
    command -v nvim >/dev/null || { echo "NONE"; return; }
    nvim --version | head -n 1 | awk '{print $2}'
}

compare_versions() {
    [ "$(printf '%s\n' "$@" | sort -V | head -n 1)" = "$1" ]
}

CURRENT_VERSION=$(get_nvim_version)

if [[ "$CURRENT_VERSION" == "NONE" ]] || ! compare_versions "$NEOVIM_MIN_VERSION" "$CURRENT_VERSION"; then
    echo "[INFO] 현재 Neovim 버전: ${CURRENT_VERSION:-없음} (최소 요구: $NEOVIM_MIN_VERSION)"
    echo "[INFO] 최신 Neovim 설치 중..."

    case "$OS" in
        debian|wsl)
            sudo apt update
            sudo apt remove -y neovim || true
            sudo apt install -y curl git software-properties-common
            sudo add-apt-repository -y ppa:neovim-ppa/stable
            sudo apt update
            sudo apt install -y neovim
            ;;
        centos)
            sudo dnf remove -y neovim || true
            sudo dnf install -y epel-release
            sudo dnf install -y neovim curl git
            ;;
        mac)
            brew install neovim
            ;;
    esac

    echo "[OK] Neovim 최신 버전 설치 완료"
else
    echo "[OK] Neovim 버전 $CURRENT_VERSION (요구 충족)"
fi

echo "[2/5] Neovim 설정 복사 중..."

mkdir -p ~/.config/nvim
cp ./init.vim ~/.config/nvim/init.vim
cp -r ./after ~/.config/nvim/
cp -f ./coc-settings.json ~/.config/nvim/

echo "[3/5] vim-plug 설치 중..."
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "[4/5] Node.js 확인 중 (coc.nvim 용)..."
if ! command -v node >/dev/null; then
    echo "[INFO] Node.js가 없어 설치합니다."
    if [[ "$OS" == "mac" ]]; then
        brew install node
    else
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt install -y nodejs
    fi
else
    echo "[OK] Node.js가 이미 설치되어 있습니다."
fi

echo "[5/5] Neovim 플러그인 설치 중..."
nvim +PlugInstall +qall

echo "[🎉] 모든 설정이 완료되었습니다. 이제 'nvim'을 실행하세요!"

