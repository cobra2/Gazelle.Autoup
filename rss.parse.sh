#!/bin/sh
# skeleton script built around HPR's feed
# this script will output a file with the episode as the filename
# then it will dump the <title> and <description> fields into the file
# the goal is to use the file as input with the torrent upload script
# to provide info for various fields on upload.php. Eventually this 
# will get combined directly into the upload script.... I hope. 
#
# DEPENDS:
# libxml2
#
# intergrate getopts
#usage()
#{
#	cat << EOF
#	usage: $0 options
#	
#	Use this to dump the title and descrition of an rss feed into individual files
#
#	-h  Show this message
#	-u  URL of feed
#	-d  Path to folder where files will be stored
#EOF
#}
#URL=
#FOLDER=
#while getopts "hu:d" OPTION
#do 
#	case $OPTION in
#		h)
#			usage
#			exit 1
#			;;
#		u)
#			URL=$OPTARG
#			;;
#		d)
#			FOLDER=$OPTARG
#			;;
#	esac
#done

# url variable needs to take a list as input -- i.e. look at mashpodder
url="http://hackerpublicradio.org/hpr_total_rss.php"
# Base command
#cmd="xml sel -t -m '/rss/channel/item[$n]' "



# create upload directory
mkdir -p /dev/shm/upload/
upload="/dev/shm/upload/"

# grab the rss feed and give it a nice easy variable to remember
wget  -O - ${url} > /dev/shm/upload/temp.rss
feed='/dev/shm/upload/temp.rss'

# count items in the feed
item=`xml sel -t -v 'count(/rss/channel/item)' $feed`

n=1
while (($n <= $item))
do
	# grab the episode name
	cmd="xml sel -t -m '/rss/channel/item[$n]' "
	filename=`xml sel -t -m "/rss/channel/item[$n]" -v "title" -n $feed | cut -b 1-7`
	#echo $filename
	touch $upload$filename
	xml sel -t  -m "/rss/channel/item[$n]" -v "title" -n -v "description" -n $feed > $upload$filename
	# store the 'title' 'author' 'description' as variables
#	title=`xml sel -t -m "/rss/channel/item[$n]" -v "title" -n $file`
#	author=`xml sel -t -m "/rss/channel/item[$n]" -v "author" -n $file`
#	description=`xml sel -t -m "/rss/channel/item[$n]" -v "description" -n $file`
	# dump the title and description of the podcast into the file
#	echo $title  > $upload$filename
	#little debug for me
#	echo $filename

	n=$(( n+1))
done
rm $feed
