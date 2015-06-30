#!/bin/bash

##############################################
exit; # disabled. Not intended to run here. WS
##############################################

# Script to copy production logs to a DAVE box
# http://stash.wtf/projects/TOS/repos/puppet/browse/modules/core/logtransf/files/logtransf.sh
#
# 05-Jun-2013

LOGFILE=/tmp/logtransf.log
LOCKFILE=/tmp/logtransf.lock
SERVER=logtransf@livelogs.dave
SSHKEY=/root/.ssh/logtransf
MAXFILESIZE=262144000   #250MB

DIR=$1
DESTINATION=$2

die() {
    if [ -f ${LOCKFILE} ]
        then rm -f ${LOCKFILE}
    fi
    exit 1
}

usage() {
    echo
    echo "   Usage: $(basename $0) <logfolder> <destination>"
    echo
    die
}


# All good, create lockfile
if [ -f ${LOCKFILE} ]
then
    if [ $(find $LOCKFILE -type f -cmin +60 | wc -l) -eq 1 ]
    then
            echo "LOCKFILE $LOCKFILE is older than 60 minutes. Maybe the script crashed"
    else
            echo "SCRIPT already running (PID $(cat ${LOCKFILE}))"
    fi
    exit 1
else
    echo $$ > ${LOCKFILE}
fi

# Read arguments
if [ $# -ne 2 ]
    then usage
fi

# Test argument is a directory
if ! [ -d $DIR ]
    then usage
fi

# Find files
FILES=$(find ${DIR} -type f -size +0 -mtime -1)

for FILE in $(echo ${FILES})
do
    SHORTNAME=$(basename ${FILE})
    FILESIZE=$(stat -c '%s' ${FILE})
    ISGZIP=$(echo ${FILE} | egrep '.*\.gz$' | wc -l)
    if [ "${ISGZIP}" -eq 1 ]
        then
            nice rsync -a -e "ssh -i ${SSHKEY}" ${FILE} ${SERVER}:/var/log/app/${DESTINATION}/
        else 
            nice tail -c ${MAXFILESIZE} ${FILE} | nice gzip --fast | ssh -i ${SSHKEY} ${SERVER} dd of=/var/log/app/${DESTINATION}/${SHORTNAME}.gz >& /dev/null
            if [ $? -ne 0 ]; then echo "${HOSTNAME}: logtransf.sh FAILED to transfer ${FILE} to ${SERVER}"; fi 
    fi
done

rm -f ${LOCKFILE}
