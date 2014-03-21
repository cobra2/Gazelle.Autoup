#!/usr/bin/perl -w
# Gazelle Auto Upload 0.2 - An AutoUpload script for Gazelle RC1 trackers #
#                     Based upon BTNautoUP - BTN <3                       #

#########################################################
##################BEGIN CONFIGURATION####################
#########################################################

###################Full Anounce URL######################
#Ex. http://tracker.com:34000/PASSKEY/announce
my $announce = "";

######################Login Info########################
my $username = "";
my $password = "";

###############Output Folder For Media###################
#Ex. /home/lul/data/music
my $output_folder = "/root/ul";

###############Output Folder For Info####################
#This Directory Is Used To Backup Scene .nfos
#Ex. /home/lul/nfobackup/
my $nfo_folder = "/root/nfo";

###############Output Folder For Torrents################
#DO NOT USE YOUR CLIENT'S WATCH DIRECTORY FOR THIS
#THIS IS IMPORTANT AS SOME CLIENTS DO NOT LEAVE THE
#TORRENT FILE IN THE WATCH DIRECTORY (DELUGE) AND WE NEED
#THE FILE IN ORDER TO FILL OUT THE UPLOAD FORM
#Ex. /root/torrentfilesbackup
my $torrent_output = "/root/tb";

###############Client Watch Directory####################
#Once The .torrent File Is Created It Will Be Copied
#To Your Client's Watch Folder
#Ex. /home/lul/watch
my $client_watch = "/home/rtor/watch";

#########################################################
##################END OF CONFIGURATION###################
#########################################################

use strict;
use warnings;
use WWW::Mechanize;


###################Check Variables#######################


if (!$announce) {
	print "No Announce URL In Configuration, Please Fix This\n";
	exit 0;
}
if (!$username) {
	print "No Username In Configuration, Please Fix This\n";
	exit 0;
}
if (!$password) {
	print "No Password In Configuration, Please Fix This\n";
	exit 0;
}
if (!$output_folder) {
	print "No Output Directory In Configuration, Please Fix This\n";
	exit 0;
}
if (!$nfo_folder) {
	print "No Info Directory In Configuration, Please Fix This\n";
	exit 0;
}
if (!$torrent_output) {
	print "No Torrent Output Directory In Configuration, Please Fix This\n";
	exit 0;
}
if (!$client_watch) {
	print "No Client Watch Directory In Configuration, Please Fix This\n";
	exit 0;
}
if ($torrent_output eq $client_watch) {
	print "Torrent Output Directory And Client Watch Directory Cannot Be The Same, Please Fix This\n";
	exit 0;
}

###################GLOBAL VARIABLES######################
my $artist = "artist name";
my $album = "album name";
my $format = "MP3";
my $bitrate = "212";
my $genretags = "mix, auto.up";

#########################################################
###################File Preperation######################
#########################################################

###################Get Directory Name####################
my $numArgs = $#ARGV; #Retrieves Directory From User Input
my $show_dir = ''; #Declares Directory Name
if ($numArgs == -1) { #If No Directory Is Supplied, Warns User And Quit Script
	print "Syntax:\n";
	print "perl gazelle_upl.pl /path/to/directory/\n";
	exit 0;
}
foreach $numArgs ($#ARGV) { #If Multiple Directories Were Supplied, Only Use Last One
	$show_dir = $ARGV[$numArgs];
}

###################Remove Trailing Slashes From Directory Variables####################
$show_dir =~ s/\/$//;
$output_folder =~ s/\/$//;
$torrent_output =~ s/\/$//;
$client_watch =~ s/\/$//;
$nfo_folder =~ s/\/$//;

###################Get Release Name From Directory####################
my $release_name = "$show_dir"; #Declares Release Name
if ($show_dir =~ /.*\/(.*)/) { #Removes Path Up To Last Directory To Retrieve Release Name
        $release_name = $1; #Sets Release Name To Regex Output
}

#test bit
opendir(DIR, $show_dir); #Opens The Directory
my @tempfiles = grep(/\.rar$/,readdir(DIR)); #Scans for files ending in .rar

###################Find The NFO File####################
opendir(DIR, $show_dir); #Opens The Directory
@tempfiles = grep(/\.nfo$/,readdir(DIR)); #Scans for files ending in .nfo
closedir(DIR); #Closes The Directory
my $nfo_name = $tempfiles[0]; #Chooses First .nfo File Found
my $nfo_file = "$show_dir\/$nfo_name"; #Adds Full Path To Rar File Name

###################Backup The NFO File####################
print "[INFO] Backing Up $nfo_name, Please Wait.\n"; #Alerts The User That We Are Going To Backup The Scene NFO File
`cp -f \"$nfo_file\" \"$nfo_folder\/$nfo_name\"`; #Copies The NFO File To The Backup Directory

###################Some funky shit########################
my $output_file = `ls | egrep '\.flac$|\.mp3$'`; #Retrieves Name Of File
$output_file = "$output_folder\/$output_file"; #Adds Full Path To Output File

###################Make The Torrent File####################
my $torrent_name = "$release_name.[Gazelle].torrent"; #Sets Name For Torrent File
my $torrent_file = "$torrent_output\/$torrent_name"; #Sets Full Path For Torrent File
my $torrent_command = "mktorrent -p -a \"$announce\" -o \"$torrent_file\" \"$output_file\""; #Creates The Command Used To Create A Torrent
print "[INFO] Making $torrent_name, Please Wait.\n"; #Alerts The User That We Are Going To Make A Torrent
`$torrent_command`; #Creates The .torrent File

###################Adding Torrent To Client####################
my $client_file = "$client_watch\/$torrent_name"; #Sets Full Path For Client File
print "[INFO] Adding $torrent_name To Client, Please Wait.\n"; #Alerts The User That We Are Going To Add The Torrent To The Client
`cp -f \"$torrent_file\" \"$client_file\"`; #Copies The Torrent File To The Client Directory

#########################################################
####################Torrent Upload#######################
#########################################################

###################Login##########################
my $mech = WWW::Mechanize->new( autocheck => 1 ); #Initializes WWW::Mechanize
$mech->get("https://invalid.site.edit.me.k.thx"); #Retrieves The Login Page
print "[INFO] Logging in, please wait.\n"; #Alerts The User
$mech->submit_form( #Logs Us In
	form_number => 0,
		fields => {
			username => "$username",
			password => "$password",
		}
	);
###################Upload form##################
$mech->get("https://invalid.site.edit.me.k.thx");
print "[INFO] Entering torrent details to upload page.\n";
print "[DEBUG] Torrent is at $torrent_file\n";
$mech->form_id('upload_table'); 
$mech->field('file_input', $torrent_file);
$mech->field('artist', $artist); # adds artist name based on id3tag variable
$mech->field('title', $album); #album title/torrent title
#$mech->click_button(value => 'autofill'); # this is breaking shit for some fucked up
$mech->field('year', '2011');
my $form = $mech->current_form(); 
$form->find_input('scene')->check();
$mech->select('format', $format); # format from id3tag variable
$mech->select('bitrate', 'Other'); # makes sure its other so we can handle it in other_bitrate
$mech->field('other_bitrate', $bitrate); # enters bitrate of song
my $form = $mech->current_form(); 
$form->find_input('vbr')->check();
$mech->select('media', 'Radio'); # radio, might fix this later to auto detect
$mech->field('tags', $genretags); # genre from id3tag
$mech->field('album_desc', 'AutoUp, feel free to edit and add data.'); #!adds NFO file from torrent to this area! 2nd version
$mech->click();

###################Logout##################
$mech->get("https://invalid.site.edit.me.k.thx"); 
print "[INFO] Logging Out, Please Wait.\n";
$mech->follow_link(url_regex => qr/logout\.php/); 

print "[INFO] All Finished!\n"; #Alerts The User
