# Project Protostar Infrastructure

Docker Compose 기반의 온프레미스 AI 서비스 인프라 설정 저장소입니다.
이 저장소는 **Main Server (A5)**와 **Sub Server (Centre)** 두 개의 물리적 서버로 구성된 인프라를 관리합니다.

## 🏗 Server Architecture

### 1. Main Server (A5) - Service Zone
주로 고성능 연산이 필요한 AI 서비스 및 데이터베이스가 위치합니다.
- **Nginx (Main):** 메인 도메인 라우팅 및 SSL 종료
- **PostgreSQL (pgvector):** 벡터 연산 지원 데이터베이스 (Port: 5432)
- **Redis:** 캐시 및 메시지 브로커 (Port: 6379)
- **Monitoring:** Node Exporter, cAdvisor, Promtail (로그 수집)

### 2. Sub Server (Centre) - Management Zone
CI/CD, 모니터링, 스토리지 등 관리 및 보조 서비스가 위치합니다.
- **Nginx (Sub):** 서브 도메인 라우팅 및 SSL 종료
- **Jenkins:** CI/CD 파이프라인 (Port: 8080)
- **MinIO:** S3 호환 오브젝트 스토리지 (Console: 9001, API: 9000)
- **Monitoring Stack:**
    - **Prometheus:** 메트릭 수집 (Port: 9090)
    - **Grafana:** 대시보드 시각화 (Port: 3000)
    - **Loki:** 로그 집계 (Port: 3100)
    - **Node Exporter, cAdvisor:** 서버 리소스 모니터링

---

## 🚀 Deployment Guide

### 1. 사전 준비 (Prerequisites)

#### 환경 변수 설정 (.env)
각 서버 디렉토리(`main-server`, `sub-server`) 내에 `.env` 파일이 존재해야 합니다.
`docker-compose.yml`에서 참조하는 주요 변수:
- `DOMAIN`: 서비스 도메인 접두사 (예: main, sub)
- `DB_USER`, `DB_PASS`: PostgreSQL 인증 정보
- `REDIS_PASS`: Redis 비밀번호
- `MINIO_ROOT_USER`, `MINIO_ROOT_PASSWORD`: MinIO 관리자 계정

#### Docker Network 생성
각 서버 환경에 맞는 Docker Network를 미리 생성해야 합니다.

```bash
# Main Server (A5) 에서 실행 시
docker network create main-protostar

# Sub Server (Centre) 에서 실행 시
docker network create sub-protostar
```

### 2. 서비스 실행 (Start Services)

Docker Compose Profiles를 사용하여 필요한 서비스 그룹만 실행할 수 있습니다.

#### Main Server (A5) 배포
```bash
# 프로젝트 루트에서 실행
docker compose --profile main up -d
```

#### Sub Server (Centre) 배포
```bash
# 프로젝트 루트에서 실행
docker compose --profile sub up -d
```

### 3. SSL 인증서 갱신 (SSL Renewal)
Let's Encrypt 인증서 갱신을 위한 스크립트가 포함되어 있습니다.
이 스크립트는 `certbot renew` 명령을 실행하고 Nginx를 리로드합니다.

```bash
# 실행 권한 부여 (최초 1회)
chmod +x renew-script.sh

# 스크립트 실행
./renew-script.sh
```
*참고: 이 스크립트는 Crontab에 등록하여 주기적으로 실행하는 것을 권장합니다.*

### 4. 주의사항 (Precautions)
- **리소스 제한:** 각 컨테이너(특히 모니터링 도구)에는 CPU 및 메모리 제한(`deploy.resources.limits`)이 걸려 있습니다. 서버 부하 발생 시 이 값을 조정해야 할 수 있습니다.
- **볼륨 데이터:** 데이터베이스(PostgreSQL, Redis)와 스토리지(MinIO), 모니터링 데이터(Prometheus, Grafana, Loki)는 Docker Volume으로 영구 저장됩니다. 중요 데이터는 별도 백업이 필요할 수 있습니다.
- **Jenkins DooD:** Jenkins는 Docker-out-of-Docker(DooD) 방식을 사용하여 호스트의 Docker 데몬을 제어합니다. 권한 문제 발생 시 `/var/run/docker.sock` 권한을 확인하세요.
- **버전 주의:** Docker 버전 혹은 이미지의 버전에 따라 호환성 문제가 발생할 수 있습니다. monitoring 스택들은 에러 발생시 버전 정보를 반드시 점검하십시오.
