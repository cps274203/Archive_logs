#!/bin/bash

TZ=UTC
export TZ

LOG_ROOT=/mnt/logs
if [ "x${1}" = "x" ] || [ "x${1}" = "xall" ] ; then
    LOG_DIRS='audio_logs,video_logs,server_logs'
else
    LOG_DIRS=$1
fi

for directory in `echo $LOG_DIRS | awk -F',' '{ l = ""; for (i = 1; i <= NF; i++) l = l $i " "; print l }'`; do
	echo "ROTATE : $directory"
	for _file in `ls $LOG_ROOT/$directory/*.gz`; do
		dirpath=`dirname $_file`
		dirname=`basename $_file | cut -d'-' -f2 | cut -d '.' -f1`
		if [ ! -d "$dirpath/$dirname" ]; then
			mkdir $dirpath/$dirname
		fi
		mv $_file $dirpath/$dirname/
		echo "ROTATE DONE : $dirpath/$dirname/$_file"
	done
	echo "ROTATE DONE : $directory"
done

# compress yesterday logs
YESTERDAY=$(date -d 'yesterday' +%Y%m%d)
logs=$(find $LOG_ROOT/server_logs/${YESTERDAY}/ -name "*.log*" |grep -v '.gzip')
echo "GZIPPING : $logs"
find $LOG_ROOT/server_logs/${YESTERDAY}/ -name "*.log*" |grep -v '.gzip' |xargs gzip -9
echo "GZIP DONE : $logs"
