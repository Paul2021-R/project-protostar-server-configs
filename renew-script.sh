#!/bin/bash

# 1. 스크립트가 있는 '진짜' 폴더 위치 계산 (절대 경로)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 2. Crontab용 PATH 설정
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 에러 발생 시 멈춤
set -e

echo "========================================"
echo "🚀 SSL Renewal Started at $(date)"
echo "   Target Dir: $SCRIPT_DIR"
echo "========================================"

# --- [핵심] 환경 감지 로직 (COMPOSE_PROFILES 활용) ---
# .env 파일을 읽어서 COMPOSE_PROFILES 변수에 'main'이 포함되어 있는지 확인합니다.

ENV_FILE="$SCRIPT_DIR/.env"

# .env 파일 로드 (변수 불러오기)
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

# COMPOSE_PROFILES 변수 확인 (메인 서버인지 판단)
if [[ "$COMPOSE_PROFILES" == *"main"* ]]; then
    echo ">> Detected Environment: Main Server (A5) (Profile: $COMPOSE_PROFILES)"
    CERTBOT_SVC="certbot-main"
    NGINX_SVC="nginx-main"
else
    echo ">> Detected Environment: Standard/Sub Server (Profile: ${COMPOSE_PROFILES:-none})"
    CERTBOT_SVC="certbot"
    NGINX_SVC="nginx"
fi

echo "   Target Services -> Certbot: $CERTBOT_SVC / Nginx: $NGINX_SVC"
echo "========================================"

# 3. Docker Compose 실행 (공통 변수 사용)
DC_CMD="docker compose --project-directory $SCRIPT_DIR --env-file $ENV_FILE"

echo "[Step 1] Certbot Renew..."
$DC_CMD run --rm "$CERTBOT_SVC" renew

echo "[Step 2] Nginx Reload..."
$DC_CMD exec "$NGINX_SVC" nginx -s reload

echo "========================================"
echo "✅ SSL Renewal Completed!"
echo "========================================"