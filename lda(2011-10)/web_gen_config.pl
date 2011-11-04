#!/usr/bin/perl -w
package WebsiteGen;

use strict;
use warnings;
use feature ':5.10';

sub initialise {
    # Used to set driver values for the website
    
    our $root = ".";
    our @image_types = ("jpg", "png");
    our $gallery_rel_path = "content/galleries";
    our $text_rel_path = "content/pages";
    our $template_rel_path = "templates";
}



