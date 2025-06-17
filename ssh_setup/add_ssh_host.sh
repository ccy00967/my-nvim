#!/bin/bash

echo "[ SSH 호스트 등록 스크립트 ]"

read -p "Host 이름 (별칭): " host_alias
read -p "HostName (서버 IP 또는 도메인): " host_name
read -p "Port (기본 22): " port
read -p "User (예: ubuntu): " user
port=${port:-22}

key_file="$HOME/.ssh/id_ed25519"

# 1. SSH 키가 없으면 생성
if [ ! -f "$key_file" ]; then
  echo "SSH 키가 없습니다. 새로 생성합니다."
  ssh-keygen -t ed25519 -f "$key_file" -N ""
fi

# 2. 공개 키 등록 여부 확인
read -p "서버에 공개 키를 등록할까요? (y/N): " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  echo "공개 키를 서버에 등록합니다..."
  ssh-copy-id -i "$key_file.pub" -p "$port" "$user@$host_name"
else
  echo "공개 키 등록을 건너뜁니다."
fi

# 3. ~/.ssh/config에 호스트 정보 추가
config_file="$HOME/.ssh/config"

# 중복 방지
if grep -q "Host $host_alias" "$config_file" 2>/dev/null; then
  echo "이미 등록된 Host입니다. 중단합니다."
  exit 1
fi

{
  echo ""
  echo "Host $host_alias"
  echo "  HostName $host_name"
  echo "  User $user"
  echo "  Port $port"
  echo "  IdentityFile $key_file"
} >> "$config_file"

echo "등록 완료: ssh $host_alias 로 접속할 수 있습니다."

