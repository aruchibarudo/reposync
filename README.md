reposync
===
## build for DSO
```sh
git clone https://guthub.com/aruchibarudo/reposync.git
cd reposync
mkdir -p src/certs
curl -SsLf -u username:password https://nexus.registry.nedra.digital/repository/local-repo/redhat-entitlement/entitlement.pem \
  -o src/certs/entitlement.pem
curl -SsLf -u username:password https://nexus.registry.nedra.digital/repository/local-repo/redhat-entitlement/entitlement-key.pem \
  -o src/certs/entitlement-key.pem
curl -SsLf -u username:password https://nexus.registry.nedra.digital/repository/local-repo/redhat-entitlement/redhat-uep.pem \
  -o src/certs/redhat-uep.pem
# For rhel7
docker build -t ubi7 --build-arg RHEL_VERSION=7 -f ci/docker/Dockerfile .
# For rhel8
docker build -t ubi8 --build-arg RHEL_VERSION=8 -f ci/docker/Dockerfile .
```

## run for DSO
```sh
# For rhel7
docker run --rm -ti --env-file rhel7.env \
  --env REPO_TARGET_CRED=username:password \
  --env REPO_TARGET_BASE_URL=https://nexus.registry.nedra.digital/repository \
  --volume /opt/nexus_data/blob0/rhel7/repos:/repos \
  ubi7
# For rhel8
docker run --rm -ti --env-file rhel8.env \
  --env REPO_TARGET_CRED=username:password \
  --env REPO_TARGET_BASE_URL=https://nexus.registry.nedra.digital/repository \
  --volume /opt/nexus_data/blob0/rhel8/repos:/repos \
  ubi8
```

## Переменные окружения
|Переменная|По умолчанию|Описание|
|-|-|-|
|REPO_LIST||Список реп для синхронизации, разделенные пробелом|
|REPO_DST||Путь для выгрузки пакетов в контейнере, совпадает с указанным в --volume|
|REPOSYNC_OPTS||Дополнительные опции для reposync|
|REPO_TARGET_NAME||Целевой репозиторий длvfя загрузки|
|REPO_TARGET_CRED||Имя пользователя и пароль для целевого репозитория (username:password)|
|REPO_TARGET_BASE_URL||Базовый url репозитория получателя для загрузки пакетов|

### Пример файла rhel8.env
```
REPO_LIST=ansible-2-for-rhel-8-x86_64-rpms rhel-8-for-x86_64-appstream-rpms rhel-8-for-x86_64-baseos-rpms rhel-8-for-x86_64-highavailability-rpms rhel-8-for-x86_64-resilientstorage-rpms rhel-8-for-x86_64-supplementary-rpms

REPO_DST=/repos

REPOSYNC_OPTS=

REPO_TARGET_NAME=rhel8

REPO_TARGET_CRED=
REPO_TARGET_BASE_URL=http://localhost:8081/repository
```
