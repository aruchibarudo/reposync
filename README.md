reposync
===
## build
```sh
# For rhel7
docker build -t ubi7 --build-arg RHEL_VERSION=7 -f ci/docker/Dockerfile .
# For rhel8
docker build -t ubi8 --build-arg RHEL_VERSION=8 -f ci/docker/Dockerfile .
```

## run
```sh
# For rhel7
docker run --rm -ti --env-file rhel7.env \
  --env REPO_TARGET_CRED=username:password \
  --volume /opt/nexus_data/blob0/rhel7/repos:/repos \
  ubi7
# For rhel8
docker run --rm -ti --env-file rhel8.env \
  --env REPO_TARGET_CRED=username:password \
  --volume /opt/nexus_data/blob0/rhel8/repos:/repos \
  ubi8
```