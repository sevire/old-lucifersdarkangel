#!/usr/bin/perl -w
################################################################################
# This script creates a particular page given its name.
#
# The script will work out whether the page is valid (i.e. there is text
# for it), whether it is a simple text page or a gallery page, and then create
# the following:
#
# - shtml file for the page, including a table of thumbnails if a gallery
# - thumbnail directory under the image folder if the page is a gallery
# - thumbnails for the images if the file is a gallery
#
# Usage:
#
# update_page [-rootpath <path>] [pagename]
#
# [pagename] : The name of the page to be created.  Used to derive the file
#              name for text pages and the name of the folder where images are
#              stored for gallery pages.
#
# -rootpath <path> : full or relative pathname where the root of the website is.
#                    This is where shtml files will be placed and where the
#                    content folder will be expected for text files and gallery
#                    images.
################################################################################
package WebsiteGen;

use Getopt::Long;
use strict;
use warnings;
use feature ':5.10';
use HTML::Template;
use File::Basename;
use Getopt::Long;
use Data::Dumper;
use WebGenConfig;
use WebGenHelper;
#use WebGenHelper;

my $root;
my $page_name;
my $debug = 1;
my %config;

sub process_command_line {
    my $success = 0;
    GetOptions('rootpath=s' => \$root);

    if (!(defined $root)) {
        $root = ".";
    };

    $page_name = shift(@ARGV);
    if (!(defined $page_name)) {
        printf "Page name not specified\n";
    } elsif ($debug) {
        printf("Page name is : <%s>\n", $page_name);
        $success = 1;
    }
    
    do 'WebGenConfig.pl';
    %config = WebGenConfig::get_config_data();
    

    if ($debug) {
        printf("Rootpath is  : <%s>\n", $root);
    }
    
    # say Dumper(%config);
    return $success;
}

sub main {
    WebGenHelper::generate_page($page_name);
}
if (process_command_line) {
    main;
}


