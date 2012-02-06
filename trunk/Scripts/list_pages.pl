#!/usr/bin/perl -w
package WebsiteGen;

use Getopt::Long;
use strict;
use warnings;
use feature ':5.10';
use WebGenHelper;
use Data::Dumper;

my @page_lists = WebGenHelper::calculate_page_lists();
my $text_list;

#say Dumper(@page_lists);
#my $pages_ref = $page_lists[0];
#my @pages_array = @$pages_ref;
my $count = 0;
my $prefix = "";

foreach $text_list (@page_lists) {
    if ($count == 0) {
        $prefix = "   Text";
    } else {
        $prefix = "Gallery"
    }
    $count++;
    my @list = @$text_list;
    foreach my $item (@list) {
        #say Dumper(@list);
        printf("%s:[%s][%s]\n", $prefix, @$item[1], @$item[0]);
    }
}


#foreach $page_list (@page_lists) {
#    my @list = $page_list;
#    printf("page %s\n", $list[0][0]);
#    printf("Num %d\n", $list[0][1]);
#}

