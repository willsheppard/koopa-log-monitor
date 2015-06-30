#!/bin/bash

# Fetch all the latest live and test logs, parse them for patterns and load results into the database.
# Test logs could be generated several times a day, but we just need one per day to track a general trend.
# All output should be piped into a log via the cron command.

# Setup
TODAY=$(date +"%Y%m%d")
YESTERDAY=$(date -d 'yesterday' +"%Y%m%d")
BASEDIR="/var/www/scripts/koopa"
TESTDATADIR="$BASEDIR/data/test/$TODAY"
LIVEDATADIR="$BASEDIR/data/live/$TODAY"
PROCESSDIR="$BASEDIR/data/process"

PERLBIN="/usr/bin/perl"
PARSESCRIPT="$BASEDIR/scripts/parse_logs.pl"
SCRIPTLIBDIR="$BASEDIR/lib"

USERNAME="USERNAME_GOES_HERE"
LIVELOGSSERVER="livelogs.dave"
LIVELOGSPATH="/var/log/nap"

SSHKEYFILE="/home/user/.ssh/livelogs/id_rsa"
APP_LOG="$BASEDIR/logs/process.start.log"

echo `date` "Started to process" >> $APP_LOG

echo "Fetch today's live logs"
mkdir -p $LIVEDATADIR
# App1
for job in acdc1 acdc2
do
    JOBDIR=$LIVEDATADIR/job.$job
    mkdir $JOBDIR
    scp -i $SSHKEYFILE $USERNAME@$LIVELOGSSERVER:$LIVELOGSPATH/$job/app1-$YESTERDAY.log.gz $JOBDIR
done
# App2
mkdir $LIVEDATADIR/job.app2.full
scp -vvv -o PreferredAuthentications=publickey -i $SSHKEYFILE $USERNAME@$LIVELOGSSERVER:$LIVELOGSPATH/app2/app2_app.log.1.gz $LIVEDATADIR/job.app2.full

echo "Fetch today's test logs"
mkdir -p $TESTDATADIR
# Jenkins
for job in \
    app2_master                 \
    app1_master_env_dc1         \
    app1_master_env_dc2         \
    app1_master_env_dc3         \
    app1_master_units_dc1       \
    app1_master_units_dc2       \
    app1_master_units_dc3       \
    app1_master_func_cancan_dc1  \
    app1_master_func_cancan_dc2  \
    app1_master_func_cancan_dc3  \
    app1_master_func_who_dc1    \
    app1_master_func_who_dc2    \
    app1_master_func_who_dc3    \
    app1_master_func_other_dc1  \
    app1_master_func_other_dc2  \
    app1_master_func_other_dc3  \
    app1_master_external_dc1    \
    app1_master_external_dc2    \
    app1_master_external_dc3
do
    wget -nv "http://build01.wtf:8181/job/$job/lastCompletedBuild/consoleText" -O $TESTDATADIR/$job.log
#    sleep 1
done

echo "Clearing out processing directory before"
if [[ ! -d "$PROCESSDIR" ]]; then mkdir $PROCESSDIR; fi
rm -rf $PROCESSDIR/*.log # test logs
rm -rf $PROCESSDIR/job.* # live logs

echo "Copying test logs into processing directory"
cp $TESTDATADIR/*.log $PROCESSDIR
cp -r $LIVEDATADIR/job.* $PROCESSDIR
gunzip $PROCESSDIR/job.*/*.gz

#echo "DISABLED... UNTIL CODE IS FIXED FOR YYYYMMDD filename format"
# TODO: Process live logs filenames correctly (date in filename)
echo "Parse logs and load into DB"
$PERLBIN -I $SCRIPTLIBDIR $PARSESCRIPT

echo "Clearing up processing directory afterwards"
rm $PROCESSDIR/*.log # test logs
rm -r $PROCESSDIR/job.* # live logs

exit 0
