FROM alpine/openclaw:latest

USER root

# alpine/openclaw:latest 이미지의 패키지 매니저는 apt가 아닌 apk입니다.
# python3와 pip를 설치합니다.
RUN apk add --no-cache python3 py3-pip vim

# pip를 이용해 Google API 관련 라이브러리를 설치합니다.
RUN pip3 install --no-cache-dir google-api-python-client google-auth-oauthlib google-auth-httplib2

# 최종 사용자를 node로 변경합니다.
USER node
