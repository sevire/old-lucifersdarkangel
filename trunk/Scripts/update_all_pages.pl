#!/usr/bin/perl -w
package WebGenHelper;
use strict;
use warnings;
use feature ':5.10';
use WebGenHelper;
use WebGenConfig;

my %config = WebGenConfig::get_config_data;
our @text_file_list;

WebGenHelper::get_text_file_list;
my $page;

foreach my $file (@text_file_list) {
    if ($file =~ $config{text_file_pattern}) {
        $page = $2;
        printf("Generating page <%s>...\n", $page);
        WebGenHelper::generate_page($page);
    } else {
        printf("File <%s> isn't there!", $file);
    }
}