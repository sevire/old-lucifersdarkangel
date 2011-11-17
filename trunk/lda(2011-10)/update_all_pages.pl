#!/usr/bin/perl -w
use strict;
use warnings;
use feature ':5.10';
use WebGenHelper;
use WebGenConfig;

my %config = WebGenConfig::get_config_data;

my @list = WebGenHelper::get_text_file_list;
my $page;

foreach my $file (@list) {
    if ($file =~ $config{text_file_pattern}) {
        $page = $2;
        printf("Generating page <%s>...\n", $page);
        WebGenHelper::generate_page($page);
    } else {
        printf("Page <%s> isn't there!", $page);
    }
}