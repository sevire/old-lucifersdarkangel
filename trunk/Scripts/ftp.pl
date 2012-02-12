#!/usr/bin/perl -w
use strict;
use warnings;
use feature ':5.10';
use Data::Dumper;
use Net::FTP;

my $ftp = Net::FTP->new('notnet.co.uk', Debug=>0)
    or die "Cannot Connect";

say "Connected";
    
$ftp->login('panlucina', 'turatti')
    or die "Cannot login ", $ftp->message;
    
say "Logged On";

$ftp->cwd('web');

my @list = $ftp->ls();

foreach my $list_item (@list) {
    say $list_item;
}

$ftp->quit;