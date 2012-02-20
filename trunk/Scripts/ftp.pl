#!/usr/bin/perl -w

use WebGenConfig;
use strict;
use warnings;
use feature ':5.10';
use Data::Dumper;
use Net::FTP;

my %config = WebGenConfig::get_config_data;
my $ftp = Net::FTP->new($config{ftp_host}, Debug=>0)
    or die "Cannot Connect";

say "Connected";
    
$ftp->login($config{ftp_user}, $config{ftp_password})
    or die "Cannot login ", $ftp->message;
    
say "Logged On";

$ftp->cwd($config{ftp_test_rel_path});

my @list = $ftp->ls();

foreach my $list_item (@list) {
    say $list_item;
}

$ftp->quit;