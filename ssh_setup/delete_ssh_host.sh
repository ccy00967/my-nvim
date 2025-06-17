#!/bin/bash

config_file="$HOME/.ssh/config"

if [ ! -f "$config_file" ]; then
  echo "$config_file 파일이 없습니다."
  exit 1
fi

echo "[ SSH 호스트 삭제 스크립트 ]"

# Host 목록 추출
host_list=$(grep "^Host " "$config_file" | awk '{print $2}')

# 목록 없으면 종료
if [ -z "$host_list" ]; then
  echo "등록된 호스트가 없습니다."
  exit 0
fi

# fzf로 선택 (또는 수동 입력)
echo "삭제할 Host를 선택하세요:"
host=$(echo "$host_list" | fzf)

if [ -z "$host" ]; then
  echo "취소됨."
  exit 0
fi

# 시작 줄과 끝 줄 찾기
start_line=$(grep -n "^Host $host$" "$config_file" | cut -d: -f1)

if [ -z "$start_line" ]; then
  echo "해당 Host를 찾을 수 없습니다."
  exit 1
fi

# 다음 Host 줄의 줄 번호
end_line=$(tail -n +$((start_line + 1)) "$config_file" | grep -n "^Host " | head -n1 | cut -d: -f1)

if [ -z "$end_line" ]; then
  # 마지막 호스트일 경우
  sed -i '' "${start_line},\$d" "$config_file"
else
  actual_end=$((start_line + end_line - 1))
  sed -i '' "${start_line},${actual_end}d" "$config_file"
fi

echo "✅ 삭제 완료: $host"

