#!/bin/bash
# Fly.io에 Slack RTM Server 배포 스크립트

set -e  # 에러 발생 시 즉시 종료

APP_NAME="slack-rtm-server"
WORKDIR="server/slack"
ENV_FILE="../../scripts/.env"

# 1. 작업 디렉토리 이동
cd "$WORKDIR" || { echo "❌ Directory not found: $WORKDIR"; exit 1; }

# 2. Fly 앱 초기화 (이미 존재하면 무시됨)
if ! flyctl apps list | grep -q "$APP_NAME"; then
  echo "🚀 Initializing Fly app: $APP_NAME"
  flyctl launch --name "$APP_NAME" --region ord --no-deploy
fi

# 3. .env 파일로 secrets 등록
echo "🔐 Setting secrets from $ENV_FILE..."
while IFS='=' read -r key value || [ -n "$key" ]; do
  # skip comments and empty lines
  [[ "$key" =~ ^#.*$ ]] && continue
  [[ -z "$key" ]] && continue

  echo "  ↪️ Setting $key : $value"
  flyctl secrets set "$key"="$value" >/dev/null
done < "$ENV_FILE"

# 4. 앱 배포
echo "🚚 Deploying to Fly.io..."
flyctl deploy --app "$APP_NAME" --strategy immediate