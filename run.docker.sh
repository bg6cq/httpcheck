#!/bin/bash

#DEBUG=1
#请把SITE改为自己的缩写，会存入influxdb，建议用学校域名缩写，如ustc, pku 等
#SITE set by docker run

[ -z ${SITE} ] && echo you must set SITE env && exit

if [ -f /keys/mykey.txt ]; then
	gpg --import /keys/mykey.txt
else
	echo you must provide /keys/mykey.txt
	exit
fi

if [ $SLEEP ] ; then
	echo SLEEP=$SLEEP
else
	SLEEP=60
fi

echo SLEEP time: $SLEEP

while true; do
	date
	bash runhttpcheck.sh
	echo sleep $SLEEP
	sleep $SLEEP
	echo 
done
