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

our $root;
our $page_name;
our $debug = 1;
my %config;

sub process_command_line {
    GetOptions('rootpath=s' => \$root);

    if (!(defined $root)) {
        $root = ".";
    };

    $page_name = shift(@ARGV);
    if (!(defined $page_name)) {
        printf "Page name not specified\n";
    } elsif ($debug) {
        printf("Page name is : <%s>\n", $page_name);
    }
    
    do 'WebGenConfig.pl';
    %config = WebGenConfig::get_config_data();
    

    if ($debug) {
        printf("Rootpath is  : <%s>\n", $root);
    }
    
    say Dumper(%config);
}

sub main {
    if (!WebGenHelper::page_exists($page_name)) {
        die sprintf("Page <%s> does not exist\n", $page_name);
    } else {
        if (WebGenHelper::is_gallery($page_name)) {
            say sprintf("<%s> is a gallery\n", $page_name);
            # Creating a gallery so need to generate thumbnails / gallery HTML
            
        } else {
            say sprintf("<%s> is not a gallery\n", $page_name);

            # Make up page from text content and template
            
            my $template_name = $config{root} . $config{ds} . $config{template_folder} .
                $config{ds} . $config{text_template_filename};
            my $text_file_name = $config{root} . $config{ds} . $config{content_rel_path} . $config{ds} . $config{text_file_rel_path} .
                $config{ds} . WebGenHelper::get_textfile_for_page($page_name);
            my $target_fullpath = $config{target_root} . $config{ds} . $page_name . ".shtml";
            
            # Read in contents of text file
            
            my $text_file = WebGenHelper::get_textfile_for_page($page_name);
            
            my $handle;
            my $holdTerminator = $/;
            my $page_text;

            undef $/;
            
            open($handle, $text_file_name) or die sprintf("Couldn't read text file <%s> for page <%s>", $text_file_name, $page_name);
            $page_text = <$handle>; # Should slurp the file (read all contents in one go)
            $/ = $holdTerminator;
            print $page_text;
            print "\n";
            
            # Pass template and text into Template to create complete page
            
            printf("Writing page <%s> to file <%s>\n", $page_name, $target_fullpath);
            open my $file, '>', $target_fullpath;
            my $template = HTML::Template->new(filename => $template_name);
            $template->param('MAIN_CONTENT' => $page_text);
            print $file $template->output;
            close $file;

        }
    }
}
process_command_line;
main;


