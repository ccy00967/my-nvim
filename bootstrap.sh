#!/usr/bin/env bash
set -e

# 원하는 Neovim 버전
NVIM_VERSION="v0.11.2"
NVIM_DISTRO="nvim-linux-x86_64"
TARBALL="${NVIM_DISTRO}.tar.gz"
INSTALL_DIR="/usr/local"
BIN_PATH="/usr/local/bin/nvim"
SYMLINK="/usr/bin/nvim"

# macOS의 경우 다른 변수로 처리
if [[ "$OSTYPE" == "darwin"* ]]; then
  NVIM_DISTRO="nvim-macos"
  TARBALL="${NVIM_DISTRO}.tar.gz"
  INSTALL_DIR="/usr/local"
  BIN_PATH="/usr/local/bin/nvim"
  SYMLINK="/usr/local/bin/nvim"
fi

echo "[1] Neovim 설치 준비 중"

# 기존 nvim 제거
if command -v nvim >/dev/null 2>&1; then
  echo "[2] 기존 Neovim 제거 중"
  sudo rm -f "$(command -v nvim)" || true
  sudo rm -rf /usr/local/nvim || true
fi

# 다운로드
echo "[3] Neovim $NVIM_VERSION 다운로드 중"
wget -q --show-progress "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${TARBALL}" || {
  echo "[오류] Neovim 릴리스 파일을 다운로드할 수 없습니다."
  exit 1
}

# 압축 해제
echo "[4] 압축 해제 중"
tar -xzf "$TARBALL" || {
  echo "[오류] 압축 해제 실패"
  exit 1
}
rm -f "$TARBALL"

# 복사
echo "[5] Neovim 설치 중"
sudo cp -r "$NVIM_DISTRO"/* "$INSTALL_DIR"
rm -rf "$NVIM_DISTRO"

# 실행 권한 부여 및 심볼릭 링크 설정
sudo chmod +x "$BIN_PATH"
if [[ ! -f "$SYMLINK" || "$(readlink "$SYMLINK")" != "$BIN_PATH" ]]; then
  sudo ln -sf "$BIN_PATH" "$SYMLINK"
fi

# 버전 확인
echo "[6] 설치된 Neovim 버전:"
nvim --version | head -n 1

