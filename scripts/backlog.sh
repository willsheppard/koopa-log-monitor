#!/bin/bash

# Re-process all the past logs, e.g. after adding a new pattern to config

# Setup
BASEDIR="/var/www/scripts/koopa"
TESTDATADIR="$BASEDIR/data/test"
LIVEDATADIR="$BASEDIR/data/live"
PROCESSDIR="$BASEDIR/data/process"
# All output is piped into the log via the cron command
#LOGFILE="$BASEDIR/logs/process.log"
SCRIPT="$BASEDIR/scripts/parse_logs.pl"
TODAY=$(date +"%Y%m%d")
USERNAME="USERNAME_GOES_HERE"
LIVELOGSSERVER="livelogs.dave"
LIVELOGSPATH="/var/log/app"
APP_LOG="$BASEDIR/logs/backlog.log"

function process_backlog() {
    YEAR=$1
    MONTH=$2
    DAY=$3

    # Add leading zero
      DAY=$(NUM=$DAY   perl -e'printf("%02d", $ENV{NUM})')
    MONTH=$(NUM=$MONTH perl -e'printf("%02d", $ENV{NUM})')

    echo Processing $1 $2 $3

    echo "Clear main processing directories (may already be empty)"
    # Test
    rm -f $PROCESSDIR/*.log &> /dev/null
    # Live
    rm -rf $PROCESSDIR/job.* &> /dev/null

    echo "Copy out a set of logs"
    # Test
    cp $TESTDATADIR/$YEAR$MONTH$DAY/*.log $PROCESSDIR
    # Live
    cp -rp $LIVEDATADIR/$YEAR$MONTH$DAY/job.* $PROCESSDIR
    gunzip $PROCESSDIR/job.*/*.gz

    echo "Parse the logs"
    /usr/bin/perl $SCRIPT $YEAR $MONTH $DAY &> $APP_LOG

    echo "Clear main processing directories again"
    rm $TESTDATADIR/*.log
    rm -r $LIVEDATADIR/job.*
}

# Main

for k in 17 24 27 30 31
do
    process_backlog "2014" "01" $k
done

for k in 01 02 03 04
do
    process_backlog "2014" "02" $k
done
