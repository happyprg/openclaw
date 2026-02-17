# Gemini를 이용한 Docker 이미지 CI/CD 파이프라인

이 문서는 GitHub Actions를 사용하여 Docker 이미지를 자동으로 빌드하고 Docker Hub에 푸시하는 CI/CD(지속적 통합/지속적 배포) 파이프라인을 설정하고 사용하는 방법을 설명합니다.

## 개요

이 파이프라인은 `main` 브랜치에 코드가 푸시될 때마다 `Dockerfile`을 기반으로 새로운 Docker 이미지를 빌드합니다. 그리고 빌드된 이미지를 Docker Hub의 공개 저장소에 `latest` 태그로 푸시합니다. 이를 통해 항상 최신 버전의 커스텀 이미지를 사용할 수 있습니다.

## 초기 설정

파이프라인이 정상적으로 작동하려면 몇 가지 초기 설정이 필요합니다.

### 1. Docker Hub 저장소 생성

Docker Hub에 로그인하여 이미지를 저장할 **공개(Public) 리포지토리**를 생성합니다. 예를 들어, 사용자명이 `my-user`이고 `custom-openclaw`라는 리포지토리를 만들 수 있습니다.

### 2. Docker Hub 인증 정보 설정

GitHub 저장소에 Docker Hub 계정 정보를 안전하게 저장해야 합니다.

1.  GitHub 저장소에서 **Settings > Secrets and variables > Actions** 메뉴로 이동합니다.
2.  **New repository secret** 버튼을 클릭하여 다음 두 개의 Secret을 생성합니다.
    *   **Name**: `DOCKERHUB_USERNAME`
        *   **Value**: Docker Hub 사용자명을 입력합니다.
    *   **Name**: `DOCKERHUB_TOKEN`
        *   **Value**: Docker Hub에서 생성한 [Access Token](https://hub.docker.com/settings/security)을 입력합니다. (비밀번호보다 Access Token 사용을 권장합니다.)

### 3. 워크플로우 파일 수정

`.github/workflows/docker-publish.yml` 파일을 열어 `tags` 부분을 실제 Docker Hub 사용자명과 리포지토리 이름으로 수정해야 합니다.

```yaml
# .github/workflows/docker-publish.yml

# ... (생략) ...
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          # ... (생략) ...
          # TODO: 아래 부분을 실제 정보로 수정하세요.
          # 예: tags: my-user/custom-openclaw:latest
          tags: your-dockerhub-username/your-repo-name:latest
```

## 파이프라인 사용법

### 이미지 빌드 및 푸시

위의 설정을 완료한 후, 로컬 변경사항을 `main` 브랜치로 푸시하면 GitHub Actions가 자동으로 실행됩니다.

```bash
git add .
git commit -m "Setup Docker CI/CD pipeline"
git push origin main
```

GitHub 저장소의 **Actions** 탭에서 워크플로우 실행 과정을 실시간으로 확인할 수 있습니다.

### 빌드된 이미지 사용하기

워크플로우가 성공적으로 완료되면 Docker Hub에서 이미지를 가져와 사용할 수 있습니다.

**1. 이미지 가져오기 (Pull)**

```bash
# 'your-dockerhub-username/your-repo-name'을 실제 이미지 주소로 변경하세요.
docker pull your-dockerhub-username/your-repo-name:latest
```

**2. 컨테이너 실행**

```bash
# 'your-dockerhub-username/your-repo-name'을 실제 이미지 주소로 변경하세요.
docker run -d --name my-app your-dockerhub-username/your-repo-name:latest
```

**3. 다른 Dockerfile에서 기반 이미지로 사용**

새로운 프로젝트의 `Dockerfile`에서 이 이미지를 기반으로 추가 작업을 수행할 수 있습니다.

```dockerfile
# 'your-dockerhub-username/your-repo-name'을 실제 이미지 주소로 변경하세요.
FROM your-dockerhub-username/your-repo-name:latest

# 여기에 추가적인 커스텀 설정을 추가합니다.
# 예: COPY ./my-app /app
# CMD ["node", "/app/index.js"]
```

## 기반 이미지 업데이트

현재 `Dockerfile`은 `alpine/openclaw:latest`를 기반으로 합니다. 만약 `alpine/openclaw` 이미지가 업데이트되어 최신 변경사항을 반영하고 싶다면, GitHub Actions 워크플로우를 다시 실행하기만 하면 됩니다.

**방법:**

1.  **수동 실행**: GitHub 저장소의 **Actions** 탭으로 이동하여 'Docker Build and Push to Docker Hub' 워크플로우를 선택하고, **Run workflow** 버튼을 클릭합니다.
2.  **코드 변경 후 푸시**: 코드에 의미 있는 변경사항(예: `README.md` 수정)을 적용하고 `main` 브랜치에 푸시하면 워크플로우가 자동으로 실행됩니다.

워크플로우가 실행되면, `docker build` 과정에서 `alpine/openclaw:latest`의 최신 버전을 자동으로 가져와 이미지를 다시 빌드하고 Docker Hub에 푸시합니다.
