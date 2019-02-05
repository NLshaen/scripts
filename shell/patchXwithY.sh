#!/bin/bash

usage="
patchXwithY.sh -r <repository to update> -p <packages to add> [-o <output repository>] [-s <list of relative paths to any files requiring a sed update in the repository>]\n
Sample use : sudo ./patchXwithY.sh -r /tmp/GCN_LMD_SERVER_V1.03_P1/stdos/ -p /tmp/NMS_ATH_1.04_Updates/Packages/ -o /tmp/GCN_LMD_SERVER_V1.04/stdos -s Server/listing -s Packages/TRANS.TBL"
[[ $(whoami) != "root" ]] && echo "You must be root to run this script" >&2 && exit 1
while getopts ":r:p:s:o:" opt; do
    case $opt in
        r )
            REPOSITORY_TO_UPDATE="$OPTARG"
            ;;
        p )
            PACKAGES_TO_ADD="$OPTARG"
            ;;
        s )
            SED_FILES+=("$OPTARG")
            ;;
        o )
            OUTPUT="$OPTARG"
            ;;
        : )
            echo "$OPTARG option requires an argument"
            exit 1
            ;;
        \? )
            echo "Invalid option : $OPTARG" >&2
            echo -e "$usage" >&2
            exit 1
            ;;
        * )
            echo "Invalid option : $OPTARG" >&2
            echo -e "$usage" >&2
            exit 1
            ;;
    esac
done
[[ "$REPOSITORY_TO_UPDATE" == "" || $(/bin/ls $REPOSITORY_TO_UPDATE/Packages 2>/dev/null) == "" ]] && echo "The \"-r\" option is mandatory to indicate where the repository to update is. It must be an existing directory containing a Packages folder." >&2 && echo -e "$usage" >&2 && exit 1
[[ "$PACKAGES_TO_ADD" == "" || $(/bin/ls $PACKAGES_TO_ADD 2>/dev/null) == "" ]] && echo "The \"-p\" option is mandatory to indicate where the packages to add are. It must be an existing directory." >&2 && echo -e "$usage" >&2 && exit 1
if [[ "$OUTPUT" == "" ]]; then
    OUTPUT=$REPOSITORY_TO_UPDATE
else
    [[ $(/bin/ls $OUTPUT 2>/dev/null) != "" ]] && echo "The \"-o\" option is optional and can be used to indicate where the resulting repository will be output. It must NOT be an existing directory." >&2 && echo -e "$usage" >&2 && exit 1
fi

echo "Patching repository $REPOSITORY_TO_UPDATE with packets from $PACKAGES_TO_ADD"
if [[ "${SED_FILES[@]}" != "" ]]; then
    for SED_FILE in "${SED_FILES[@]}"; do
        echo "Updating $REPOSITORY_TO_UPDATE/$SED_FILE to $OUTPUT/$SED_FILE"
    done
fi
echo "Output will be in $OUTPUT"
echo "Yum repositories that will be updated : $OUTPUT and $OUTPUT/Server"

# Building a database of existing packets in $REPOSITORY_TO_UPDATE
TMP_FILE=$(mktemp)
for PACKAGE in $(/bin/ls "$REPOSITORY_TO_UPDATE/Packages"); do
    rpm -qp --queryformat '%{NAME}:%{VERSION}:%{RELEASE}:%{ARCH}' "$REPOSITORY_TO_UPDATE/Packages/$PACKAGE" >>$TMP_FILE 2>/dev/null
    echo ":$PACKAGE" >>$TMP_FILE
done

# Creating output if necessary
[[ $(/bin/ls $OUTPUT 2>/dev/null) == "" ]] && mkdir -p $OUTPUT && cp -r $REPOSITORY_TO_UPDATE $OUTPUT/../

# For each new packet, copy it to destination and update sed files
for NEW_PACKAGE in $(/bin/ls "$PACKAGES_TO_ADD"); do
    # Extract information
    REQ=$(rpm -qp --queryformat '%{NAME}:%{VERSION}:%{RELEASE}:%{ARCH}' "$PACKAGES_TO_ADD/$NEW_PACKAGE" 2>/dev/null)
    NEW_NAME=$(echo $REQ | cut -d ":" -f 1)
    NEW_VERSION=$(echo $REQ | cut -d ":" -f 2)
    NEW_RELEASE=$(echo $REQ | cut -d ":" -f 3)
    NEW_ARCH=$(echo $REQ | cut -d ":" -f 4)
    # Search existing packets database for this packet
    MATCHED=false
    for l in $(cat $TMP_FILE); do
        OLD_NAME=$(echo $l | cut -d ":" -f 1)
        if [[ "$NEW_NAME" == "$OLD_NAME" ]]; then
            MATCHED=true
            OLD_VERSION=$(echo $l | cut -d ":" -f 2)
            OLD_RELEASE=$(echo $l | cut -d ":" -f 3)
            OLD_ARCH=$(echo $l | cut -d ":" -f 4)
            OLD_PACKAGE=$(echo $l | cut -d ":" -f 5)
            if [[ "$NEW_VERSION" != "$OLD_VERSION" || "$NEW_RELEASE" != "$OLD_RELEASE" || "$NEW_ARCH" != "$OLD_ARCH" ]]; then
                echo "Replacing $OLD_PACKAGE by $NEW_PACKAGE..."
                rm -rf $OUTPUT/Packages/$OLD_PACKAGE
                cp -f $PACKAGES_TO_ADD/$NEW_PACKAGE $OUTPUT/Packages/
                if [[ "${SED_FILES[@]}" != "" ]]; then
                    for SED_FILE in "${SED_FILES[@]}"; do
                        sed -i -e "s/$OLD_PACKAGE/$NEW_PACKAGE/g" $OUTPUT/$SED_FILE
                    done
                fi
            else
                echo "Not replacing $OLD_PACKAGE since new rpm $NEW_PACKAGE is the same version"
            fi
        fi
    done
    if [[ "$MATCHED" == false ]]; then
        echo "Adding new rpm $NEW_PACKAGE..."
        cp -f $PACKAGES_TO_ADD/$NEW_PACKAGE $OUTPUT/Packages/
    fi
done

# Update repositories metadata
createrepo --update -o $OUTPUT --read-pkgs-list /var/log/pkgs-list-$(date -Iseconds).log $OUTPUT/Packages
createrepo --update -o $OUTPUT/Server --read-pkgs-list /var/log/pkgs-list-server-$(date -Iseconds).log -i $OUTPUT/Server/listing $OUTPUT/Packages

rm -rf $TMP_FILE
