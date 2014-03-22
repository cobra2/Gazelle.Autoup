#!/bin/sh
# skeleton script built around HPR's feed
# this script will output a file with the episode as the filename
# then it will dump the <title> and <description> fields into the file
# the goal is to use the file as input with the torrent upload script
# to provide info for various fields on upload.php. Eventually this 
# will get combined directly into the upload script.... I hope. 


#url variable needs to take a list as input -- i.e. look at mashpodder
url="http://hackerpublicradio.org/hpr_rss.php"

#count how many items are in the list
item=`xml sel --net -t -v 'count(/rss/channel/item)' ${url}`
#echo $item

# create upload directory
mkdir -p /dev/shm/upload/
upload="/dev/shm/upload/"

# grab the rss feed and give it a nice easy variable to remember
wget  -O - ${url} > /dev/shm/upload/temp.rss
feed='/dev/shm/upload/temp.rss'


n=1
while (($n <= $item))
do
	# grab the episode name
	filename=`xml sel -t -m "/rss/channel/item[$n]"  -v "title" -n $feed | cut -b 1-7`
	touch $upload$filename
	# dump the title and description of the podcast into the file
	xml sel  -t -m "/rss/channel/item[$n]" -v "title" -n -v "author" -n -v "description" -n $feed > $upload$filename
	#little debug for me
	echo $filename

	n=$(( n+1))
done
