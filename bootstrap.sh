#!/usr/bin/env bash

set -e

REQUIRED_NVIM_VERSION="0.8.0"
NEOVIM_VERSION="v0.11.2"
ARCHIVE_NAME=""
DOWNLOAD_URL=""
OS_TYPE=""

print_header() {
  echo "[0/6] 운영체제 및 Neovim 버전 확인 중..."
}

detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt &>/dev/null; then
      OS_TYPE="debian"
    elif command -v yum &>/dev/null || command -v dnf &>/dev/null; then
      OS_TYPE="rhel"
    else
      echo "[ERROR] 지원하지 않는 Linux 배포판입니다."
      exit 1
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
  else
    echo "[ERROR] 지원하지 않는 운영체제입니다."
    exit 1
  fi
}

remove_old_nvim() {
  echo "[INFO] 기존 Neovim 제거 중..."
  case "$OS_TYPE" in
    debian)
      sudo apt remove -y neovim || true
      ;;
    rhel)
      sudo yum remove -y neovim || sudo dnf remove -y neovim || true
      ;;
    macos)
      brew uninstall neovim || true
      ;;
  esac
}

set_download_url() {
  case "$OS_TYPE" in
    debian | rhel)
      ARCHIVE_NAME="nvim-linux64.tar.gz"
      ;;
    macos)
      ARCHIVE_NAME="nvim-macos.tar.gz"
      ;;
  esac
  DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/${ARCHIVE_NAME}"
}

check_url_exists() {
  echo "[INFO] Neovim ${NEOVIM_VERSION} 다운로드 URL 유효성 검사 중..."
  if ! curl -fsI "$DOWNLOAD_URL" >/dev/null; then
    echo "[ERROR] 유효하지 않은 Neovim 다운로드 링크입니다:"
    echo "→ $DOWNLOAD_URL"
    exit 1
  fi
}

download_and_install() {
  echo "[INFO] Neovim ${NEOVIM_VERSION} 설치 중..."
  curl -LO "$DOWNLOAD_URL"
  tar xzf "$ARCHIVE_NAME"

  case "$OS_TYPE" in
    debian | rhel)
      sudo mv nvim-linux64/bin/nvim /usr/local/bin/nvim
      sudo rm -rf nvim-linux64 "$ARCHIVE_NAME"
      ;;
    macos)
      sudo mv nvim-macos/bin/nvim /usr/local/bin/nvim
      sudo rm -rf nvim-macos "$ARCHIVE_NAME"
      ;;
  esac

  echo "[OK] Neovim ${NEOVIM_VERSION} 설치 완료 (/usr/local/bin/nvim)"
}

main() {
  print_header
  detect_os
  remove_old_nvim
  set_download_url
  check_url_exists
  download_and_install
}

main

