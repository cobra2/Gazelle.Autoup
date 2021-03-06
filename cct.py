#!/usr/bin/python
#######################################################
# AutoUp-BTN v0.1
#######################################################
# Requires:
# Python2
# Python Mechanize (http://wwwsearch.sourceforge.net/mechanize/)
# Mktorrent (http://mktorrent.sourceforge.net/)
#######################################################

# Login info
username = ""
password = ""
passkey = ""

# Announce
announce_url = "http://sandbox.cctracker.org:35000/'passkey'/announce"

# Fast torrent. 1 = on, 0 = off
#fast_torrent = 0

# Torrent output folder / client watch directory
torrent_output_folder = "/mnt/home/someone/rtorrent/watch/cctracker/"  # Leave trailing slash

# Confirmations. 1 = on, 0 = off
confirmations = 1
#######################################################
# DO NOT EDIT BELOW THIS LINE
#######################################################

# Imports
import sys
import os
import re
import subprocess
import mechanize
sys.argv.remove(sys.argv[0])

######################################################
# Log into BTN
######################################################
print "Logging into CCT..."
br = mechanize.Browser()
# Set some headers
br.set_handle_robots(False)
br.addheaders = [('User-agent', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.11 (KHTML, like Gecko) \
       	        Chrome/17.0.963.56 Safari/535.11')]
# Open the login page
br.open("https://sandbox.cctracker.org/login.php")

# Select form & input user info
br.select_form(name="loginform")
br.form["username"] = username
br.form["password"] = password
br.submit()

#######################################################
# Collect information
#######################################################

for show in sys.argv:
	# Input file
	input_file_full = show
	input_file = os.path.basename(input_file_full)
	
	# Get release name
	release_name = os.path.splitext(input_file)[0]
	
	# Output file information
	print "\nFilename:", os.path.basename(input_file)
	print "Release name:", release_name
	print
	
	# Regex to separate series name / season number / episode number
	regex = re.match("(.*?)\.S?(\d{1,2})E?(\d{2})\.(.*)", release_name)
	
	# Assign variables from regex
	series_name = regex.group(1)
	season_number = regex.group(2)
	episode_number = regex.group(3)
	
	# Output episode info
	print "Series Name:", series_name
	print "Season Number:", season_number
	print "Episode Number:", episode_number

	# Make sure info is correct, quit if not
	if confirmations == 1:
	    correct = raw_input("\nIs this correct? y/n \n")
	    if correct != "y":
	        sys.exit("\nInformation incorrect, quitting.")

	# Get mediainfo of file
	print "\nGetting MediaInfo..."
	p = subprocess.Popen(["mediainfo", input_file_full], stdout=subprocess.PIPE)
	mediainfo, err = p.communicate()
	
	#######################################################
	# Make torrent
	#######################################################
	
	# Make torrent file
	print "Making torrent file..."
	torrent_output_file = torrent_output_folder + input_file + ".torrent"
	subprocess.Popen(["mktorrent", "-p", "-a", announce_url, input_file_full, "-o", torrent_output_file],
	                 stdout=subprocess.PIPE).communicate()

	#######################################################
	# Upload to BTN
	#######################################################

	# Initialise
	# Open upload page
	br.open("http://sandbox.cctracker.org/upload.php")

	# Select form and fill in autofill
	print "Uploading torrent..."
	br.select_form(nr=6)
	br.form["autofill"] = release_name
	br.submit(label="Get Info")

	# Check data
	br.select_form(nr=6)
	if br.form["artist"] == "AutoFill Fail" or br.form["title"] == "AutoFill Fail":
	    sys.exit("Autofill failed, please upload manually.")

	# Add torrent file
	br.form.add_file(open(torrent_output_file), "", torrent_output_file, name="file_input")

	# Add mediainfo
	br.form["release_desc"] = mediainfo

	# Set fast torrent
	#if fast_torrent == 1:
	#    br.find_control("fasttorrent").items[0].selected = True

	# Submit form & upload
	br.submit(label="Upload torrent")
	
	#######################################################
	# Logout & finish
	#######################################################

print "Logging out of BTN..."
br.follow_link(url_regex=r"logout.php")
print "Success!"
