#!/bin/bash

# 1. 스크립트가 있는 '진짜' 폴더 위치 계산 (절대 경로)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 2. Crontab용 PATH 설정 (docker 명령어를 찾기 위해 필수)
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 에러 발생 시 멈춤
set -e

echo "========================================"
echo "🚀 SSL Renewal Started at $(date)"
echo "   Target Dir: $SCRIPT_DIR"
echo "========================================"

# 3. Docker Compose 실행 (옵션 설명)
# --project-directory: docker-compose.yml이 있는 폴더 위치 강제 지정
# --env-file: .env 파일 위치 강제 지정
# 이렇게 하면 cd를 안 해도 되고, source 에러도 안 납니다.

echo "[Step 1] Certbot Renew..."
docker compose \
  --project-directory "$SCRIPT_DIR" \
  --env-file "$SCRIPT_DIR/.env" \
  run --rm certbot renew

echo "[Step 2] Nginx Reload..."
docker compose \
  --project-directory "$SCRIPT_DIR" \
  --env-file "$SCRIPT_DIR/.env" \
  exec nginx nginx -s reload

echo "========================================"
echo "✅ SSL Renewal Completed!"
echo "========================================"