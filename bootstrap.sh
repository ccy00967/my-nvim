#!/usr/bin/env bash
set -e

REQUIRED_NVIM="0.8.0"
NEOVIM_VERSION="v0.11.2"
INSTALL_BIN="/usr/local/bin/nvim"

echo "[0/7] OS & Neovim 점검 중..."

# 운영체제 감지
OS_TYPE="unknown"
case "$OSTYPE" in
  linux*)
    if grep -qi microsoft /proc/version 2>/dev/null; then OS_TYPE="debian"
    elif command -v apt >/dev/null; then OS_TYPE="debian"
    elif command -v yum >/dev/null || command -v dnf >/dev/null; then OS_TYPE="rhel"; fi ;;
  darwin*) OS_TYPE="macos" ;;
esac
if [[ "$OS_TYPE" == "unknown" ]]; then
  echo "[ERROR] 해당 OS는 지원되지 않습니다: $OSTYPE"
  exit 1
fi

# 현재 설치된 nvim 버전 확인
check_nvim() {
  if ! command -v nvim >/dev/null; then return 1; fi
  current=$(nvim --version | head -n1 | awk '{print $2}' | sed 's/^v//')
  if [[ "$(printf '%s\n' "$REQUIRED_NVIM" "$current" | sort -V | head -n1)" = "$REQUIRED_NVIM" ]]; then
    echo "[OK] Neovim v$current (>= $REQUIRED_NVIM) 설치됨"
    return 0
  else
    echo "[WARN] Neovim v$current (< $REQUIRED_NVIM)"
    return 1
  fi
}

# 설치/업데이트 함수
install_nvim() {
  echo "[1/7] 기존 Neovim 제거 중..."
  case "$OS_TYPE" in
    debian) sudo apt remove -y neovim || true ;;
    rhel) sudo yum remove -y neovim 2>/dev/null || sudo dnf remove -y neovim || true ;;
    macos) brew uninstall neovim 2>/dev/null || true ;;
  esac

  echo "[2/7] Neovim v$NEOVIM_VERSION 다운로드 준비..."
  ARCHIVE="nvim-linux-x86_64.tar.gz"
  URL="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/${ARCHIVE}"
  # 유효성 확인
  if ! curl -fsI "$URL" >/dev/null; then
    echo "[ERROR] 다운로드 불가 URL: $URL"
    exit 1
  fi

  echo "[3/7] 다운로드 중..."
  curl -L -o "$ARCHIVE" "$URL"

  # 압축 확인 및 설치
  if file "$ARCHIVE" | grep -q "gzip compressed"; then
    tar xzf "$ARCHIVE"
    sudo mv nvim-linux-x86_64/bin/nvim /usr/local/bin/
    sudo chmod +x "$INSTALL_BIN"
    rm -rf nvim-linux-x86_64 "$ARCHIVE"
    echo "[OK] Neovim 설치 완료: $(nvim --version | head -n1)"
  else
    echo "[ERROR] 파일 포맷 오류: $ARCHIVE"
    exit 1
  fi
}

# 설치 필요하면 실행
if ! check_nvim; then install_nvim; fi

echo "[4/7] 환경 설정 복사 중..."
mkdir -p ~/.config/nvim
cp init.vim coc-settings.json ~/.config/nvim/
cp -r after ~/.config/nvim/ 2>/dev/null || true

echo "[5/7] vim-plug 설치..."
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "[6/7] Node.js 체크 (coc.nvim 용)..."
if ! command -v node >/dev/null; then
  echo "[INFO] Node.js 설치 중..."
  case "$OS_TYPE" in
    macos) brew install node ;;
    debian)
      curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
      sudo apt install -y nodejs ;;
    rhel)
      curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
      sudo yum install -y nodejs ;;
  esac
else
  echo "[OK] Node.js 설치됨"
fi

echo "[7/7] 플러그인 자동 설치..."
nvim --headless +PlugInstall +qall

echo "✅ 설치 완료! 'nvim' 실행하세요."

