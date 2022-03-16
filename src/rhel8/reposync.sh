#!/bin/bash
NEXUS_CRED=gpn-writer:reew8Co1fooG
REPO=$1
#REPO_DIR=rhel-8-for-x86_64-baseos-rpms
REPO_DIR=$2
#TARGET_DIR=baseos/os
TARGET_DIR=$3
#BASE_URL=https://nexus.registry.nedra.digital/repository
BASE_URL=http://localhost:8081/repository

for repo in ${REPO_LIST}
do
  echo "Download packages from ${repo}"
  reposync --download-path=${REPO_DST} --download-metadata ${REPOSYNC_OPTS} --repoid=${repo}
done

for repo in ${REPO_LIST}
do
  repo_file=$(grep -l ${repo} /etc/yum.repos.d/*.repo)
  target_dir=$(grep -A10 "^\[${repo}" ${repo_file} | sed -rn 's/baseurl\s+=\s+.*\/x86_64\/(\w+)\/?([^\/]*)\/(\w+)$/\1\2\/\3/p')
  target_url=${REPO_TARGET_BASE_URL}/${REPO_TARGET_NAME}/8/x86_64/${target_dir}
  echo "Upload packages from ${repo} to ${target_url}"

  for pkg in ${REPO_DST}/${repo}/Packages/*/*
  do
    pkg_file=$(basename ${pkg})
    pkg_litera=${pkg_file:0:1}
    pkg_llitera=${pkg_litera,,}
    pkg_dir="Packages/${pkg_llitera}"
    echo "Upload ${pkg_file}"
    curl -Ss --user "${REPO_TARGET_CRED}" --upload-file ./${pkg} ${target_url}/${pkg_dir}/${pkg_file}
  done

  for pkg in ${REPO_DST}/${repo}/repodata/*comps.xml
  do
    pkg_file=$(basename ${pkg})
    echo "Upload ${pkg_file}"
    curl -Ss --user "${NEXUS_CRED}" --upload-file ./${pkg} ${target_url}/repodata/comps.xml
  done

  for pkg in ${REPO_DST}/${repo}/repodata/*updateinfo.xml.gz
  do
    pkg_file=$(basename ${pkg})
    echo "Upload ${pkg_file}"
    curl -Ss --user "${NEXUS_CRED}" --upload-file ./${pkg} ${target_url}/repodata/updateinfo.xml.gz
  done
done
