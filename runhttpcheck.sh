#!/bin/bash
# DEBUG=1

echo SITE: $SITE

[ -z ${SITE} ] && echo you must set SITE env && exit

grep -v ^# urls.txt | while read hostname url; do 

echo hostname: $hostname
echo url: $url

rm -f $$.tmp $$.tmp.gpg
./httptest/httptest -w 2 -i www,site=${SITE},host=${hostname} ${url} > $$.tmp
[ $DEBUG ] && echo -n result:
cat $$.tmp

gpg --sign $$.tmp

if [ $DEBUG ]; then
	curl -F "debug=1" -F "report=@$$.tmp.gpg" http://ipv6.ustc.edu.cn/httpcheck/report.php 2>/dev/null
else
	curl -F "report=@$$.tmp.gpg" http://ipv6.ustc.edu.cn/httpcheck/report.php 2>/dev/null
fi

rm -f $$.tmp $$.tmp.gpg

done
