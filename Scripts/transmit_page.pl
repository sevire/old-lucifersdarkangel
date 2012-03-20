#!/usr/bin/perl -w
################################################################################
# This script sends a page to the live server via ftp.
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
    WebGenHelper::ftp_transmit_page($page_name);
}
if (process_command_line) {
    main;
}


