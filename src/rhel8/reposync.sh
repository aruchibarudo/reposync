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
  COUNT=0
  TOTAL=$(ls -1 ${REPO_DST}/${repo}/Packages/*/*| wc -l)
  UPLOADED=0
  SKIPPED=0
  repo_file=$(grep -l ${repo} /etc/yum.repos.d/*.repo)
  target_dir=$(grep -A10 "^\[${repo}" ${repo_file} | sed -rn 's/baseurl\s+=\s+.*\/x86_64\/(\w+)\/?([^\/]*)\/(\w+)$/\1\2\/\3/p')
  [ -z ${target_dir} ] && target_dir=$(grep -A10 "^\[${repo}" ${repo_file} | sed -rn 's/baseurl\s+=\s+.*\/x86_64\/(\w+)/base\/\1/p')
  target_url=${REPO_TARGET_BASE_URL}/${REPO_TARGET_NAME}/8/x86_64/${target_dir}
  echo "Upload packages from ${repo} to ${target_url}"

  for pkg in ${REPO_DST}/${repo}/Packages/*/*
  do
    (( COUNT++ ))
    pkg_file=$(basename ${pkg})
    pkg_litera=${pkg_file:0:1}
    pkg_llitera=${pkg_litera,,}
    pkg_dir="Packages/${pkg_llitera}"
    #echo "Upload ${pkg_file}"
    printf "\r\e[0K%3d.%1d%% %s" $(( $COUNT * 100 / $TOTAL )) $(( ($COUNT * 1000 / $TOTAL) % 10 )) $pkg_file
    curl -sLf --user "${NEXUS_CRED}" --head ${target_url}/${pkg_dir}/${pkg_file} > /dev/null
    RC=$?

    if [[ ${RC} != 0 ]]
    then
      curl -Ssf --user "${REPO_TARGET_CRED}" --upload-file ./${pkg} ${target_url}/${pkg_dir}/${pkg_file}
      (( UPLOADED++ ))
    else
      (( SKIPPED++ ))
    fi

  done

  echo
  echo "Uploaded pkgs: ${UPLOADED}"
  echo "Skipped pkgs: ${SKIPPED}"

  for pkg in ${REPO_DST}/${repo}/repodata/*comps.xml
  do
    pkg_file=$(basename ${pkg})
    echo -n "Upload ${pkg_file}... "
    curl -Ss --user "${NEXUS_CRED}" --upload-file ./${pkg} ${target_url}/repodata/comps.xml
    echo "Done!"
  done

  for pkg in ${REPO_DST}/${repo}/repodata/*updateinfo.xml.gz
  do
    pkg_file=$(basename ${pkg})
    echo -n "Upload ${pkg_file}... "
    curl -Ss --user "${NEXUS_CRED}" --upload-file ./${pkg} ${target_url}/repodata/updateinfo.xml.gz
    echo "Done!"
  done
done
