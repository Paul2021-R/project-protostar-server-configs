# Project Protostar Infrastructure

Docker Compose 기반의 온프레미스 AI 서비스 인프라 설정 저장소.

## 🏗 Architecture
- **Main Server (A5):** Service Zone (NestJS, FastAPI, PG, Redis)
- **Sub Server (Centre):** Management Zone (Jenkins, Monitoring, Gateway)

## 🚀 Deployment
이 레포지토리는 Jenkins 파이프라인과 연동되어 있습니다.
- `.env` 설정 필요.

- docker network 를 별도로 설정할 것 
```shell
# Sub 서버(Centre)에서 실행할 때
docker network create sub-protostar

# Main 서버(A5)에서 실행할 때
docker network create main-protostar
```

- docker compose profile 사용
```shell
# Main 서버(A5)에서 실행할 때
docker compose --profile main up -d

# Sub 서버(Centre)에서 실행할 때
docker compose --profile sub up -d

# 전체 다 켜고 싶을 때 (잘 안 쓰겠지만)
docker compose --profile main --profile sub up -d
```

