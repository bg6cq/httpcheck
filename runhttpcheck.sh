#!/bin/bash
# DEBUG=1

[ $DEBUG ] && echo SITE: $SITE

[ -z ${SITE} ] && echo you must set SITE env && exit

grep -v ^# urls.txt | while read hostname url; do 

[ $DEBUG ] && echo hostname: $hostname
[ $DEBUG ] && echo url: $url

rm -f $$.tmp $$.tmp.gpg
./httptest/httptest -w 2 -i www,site=${SITE},host=${hostname} ${url} > $$.tmp
[ $DEBUG ] && echo -n result:
[ $DEBUG ] && cat $$.tmp

gpg --sign $$.tmp

if [ $DEBUG ]; then
	curl -F "debug=1" -F "report=@$$.tmp.gpg" http://ipv6.ustc.edu.cn/httpcheck/report.php
else
	curl -F "report=@$$.tmp.gpg" http://ipv6.ustc.edu.cn/httpcheck/report.php
fi

rm -f $$.tmp $$.tmp.gpg

done
