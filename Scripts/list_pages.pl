#!/usr/bin/perl -w
package WebsiteGen;

use Getopt::Long;
use strict;
use warnings;
use feature ':5.10';
use WebGenHelper;

my @page_list = WebGenHelper::calculate_page_lists();
my @text_list = $page_list[0];

