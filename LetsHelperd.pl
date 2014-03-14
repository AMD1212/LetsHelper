#!/usr/bin/perl -w

use strict;
use XML::Simple;
use Data::Dumper;
use File::Basename;
use File::Copy;
use DBI;
use Switch;

# Variables
our $Sleeptime="10";
our $Watchdir="/tmp/LetsHelper/XMLIN";
our $Donedir="/tmp/LetsHelper/XMLDONE";
our $DBconnection = DBI->connect("dbi:Pg:dbname=letshelper") or die "Cannot establish database connection";

while() {
	# Searching for new files in watchdir
	my @Workfiles=<$Watchdir/*.xml>;
	my $File;
	foreach $File (@Workfiles) {
		# Reading all xml files
		print "Reading $File\n";

		my $xml = new XML::Simple;
		my $data = $xml->XMLin("$File");

		print Dumper($data);
		switch ($data->{type}) {
			case "project" {
				print "Project\n";
				finish_xml($File);
			}
			case "episode" {
				print "Episode\n";
			}
			else {
				print "Not a valid xml type";
			}
		}

}
	print "Sleeping $Sleeptime Seconds\n";
	sleep($Sleeptime);
}


## Functions
sub finish_xml {
	# Moving processed xml to donedir
	my $File=$_[0];
	my $Filename=basename($File);
	print "Done parsing $Filename, moving to done folder\n";
	my $Donetime = time;
	my $Donefile="$Donedir/$Donetime\_$Filename";
	move($File,$Donefile) or die "The move operation failed: $!";

	# Sleep 1 second to avoid moving another file over the current processed
	sleep(1);
}
