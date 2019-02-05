#!/bin/bash

#./qgis-delivery.sh -n qgis -v 2.14.17 -r "rpmrecompile,rpmthirdparty,centos7.1" -s qgis

exec 3<&1
exec >/dev/null

set -e

#-- Help function
function HELP {
  echo -e \\n"-n Archive name"\\n >&3
  echo -e "-v Archive version"\\n >&3
  echo -e "-r Enable repository"\\n >&3
  echo -e "-s Server rpms"\\n >&3
  echo -e "-h Help"\\n >&3
  exit 1
}

#-- Check the number of arguments. If none are passed, print help and exit.
NUMARGS=$#
if [ $NUMARGS -lt 4 ]; then
  HELP
fi


#-- Traps for safety
tempdir=$(mktemp -d)
tempfiles+=( "${tempdir}" )
cleanup() {
  echo -n "Cleaning..." >&3
  rm -rf "${tempfiles[@]}"
  echo "OK" >&3
}
trap cleanup 0

error() {
  local parent_lineno="$1"
  local message="$2"
  local code="${3:-1}"
  if [[ -n "$message" ]] ; then
    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}" >&3
  else
    echo "Error on or near line ${parent_lineno}; exiting with status ${code}" >&3
  fi
  exit "${code}"
}
trap 'error ${LINENO}' ERR

ARCHIVE_NAME="archive"
ARCHIVE_VERSION="0.0.0"
ENABLEREPO="*"
RPMS=""

while getopts :n:v:r:c:s:h FLAG; do
  case $FLAG in
    n)
      ARCHIVE_NAME=$OPTARG
      ;;
    v)
      ARCHIVE_VERSION=$OPTARG
      ;;
    r)
      ENABLEREPO=$OPTARG
      ;;
    s)
      SERVERRPMS=$OPTARG
      ;;
    h)
      HELP
      ;;
    \?)
      echo -e \\n"Option $OPTARG not allowed." >&3
      HELP
      ;;
  esac
done
shift $((OPTIND-1))


DISABLEREPO="*"
LIST_FORMAT="%{nvra}\n"
ARCHIVE_FOLDER="${ARCHIVE_NAME}"
ARCHIVE_NAME="${ARCHIVE_NAME}-${ARCHIVE_VERSION}.tgz"
INSTALLROOT="${tempdir}/installroot"
DOWNLOADDIR="${tempdir}/downloaddir"
VERSION_FILE="${ARCHIVE_FOLDER}/VERSION_${ARCHIVE_VERSION}.txt"
RPM_FOLDER="${ARCHIVE_FOLDER}/rpms"

obtain_rpms() {
        local suffix=$1; shift;
        local listfile=$1; shift;
        local downloaddir="${DOWNLOADDIR}$suffix"
        local installroot="${INSTALLROOT}$suffix"
        local rpms=$@

        rm -fr ${downloaddir};   mkdir -p ${downloaddir}
        rm -fr ${installroot};   mkdir -p ${installroot}

        yum clean all

        #-- Download required RPMs
        echo -n "Downloading required ${suffix} rpms..." >&3
        yum install --disablerepo="${DISABLEREPO}" \
                --enablerepo="${ENABLEREPO}" \
                --installroot="${installroot}" \
                --downloadonly \
                --downloaddir "${downloaddir}" \
                ${rpms}
        echo "OK" >&3

        #-- Pruning list
        echo -n "Pruning downloaded ${suffix} rpms..." >&3
        rm -f ${downloaddir}/bsr_*rpm
        echo "OK" >&3

        #-- Generate packages list
        echo -n "Writing ${suffix} rpms list..." >&3
        find ${downloaddir} -type f -iname "*\.rpm" -exec rpm -q --qf="${LIST_FORMAT}" -p {} \; 2>/dev/null >> ${listfile}
        echo "OK" >&3
}


serverinstallfile=${tempdir}/srv_list.txt
obtain_rpms "server" ${serverinstallfile} "${SERVERRPMS}"


#-- Package the whole thing
echo -n "Packaging the whole thing..."
mkdir -p ${RPM_FOLDER} ${ARCHIVE_FOLDER}
find ${DOWNLOADDIR}* -type f -iname "*rpm" -exec mv {} ${RPM_FOLDER} \;
tar cvzf ${ARCHIVE_NAME} ${ARCHIVE_FOLDER}
mv ${ARCHIVE_NAME} ${ARCHIVE_FOLDER}
echo "OK"


#-- Create version file
echo -n "Creating ${VERSION_FILE}..." >&3
cat <<EOF > ${VERSION_FILE}
${ARCHIVE_NAME}
VERSION : ${ARCHIVE_VERSION}
Date : $(date)

==== MD5SUM ====
$(md5sum ${ARCHIVE_FOLDER}/${ARCHIVE_NAME})

==== REQUIRED BSR DEPENDENCIES ====
$(find ${ARCHIVE_FOLDER}/rpms/ -type f -iname "*\.rpm" -exec rpm -qp {} --requires \; 2>/dev/null | grep -E "^bsr_.*" | sort -u)

==== GIT TAG URL ====

==== DELIVERED PACKAGES LIST ====
$(cat $serverinstallfile | sort -u)

==== SERVER PACKAGES ====
$(cat $serverinstallfile | sort -u)

EOF
echo "OK" >&3
