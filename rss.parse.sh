#!/bin/sh

url="http://hackerpublicradio.org/hpr_rss.php"
item=`xml sel --net -t -v 'count(/rss/channel/item)' ${url}`

echo $item
n=1
while (($n <= $item))
do
      	wget ${url} -O - 2>/dev/null | xml sel -t -m "/rss/channel/item[$n]"  -v "title" -n -v "description"
	n=$(( n+1))
done
