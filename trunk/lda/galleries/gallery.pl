#!/usr/bin/perl -w
use strict;
use warnings;
use feature ':5.10';

# Formatting parameters
my $table_column_width = 4;
my $max_dimension = 130;

# Start of html page
my $preamble = <<END;
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
    <meta name="generator" content="HTML Tidy for Mac OS X (vers 11 August 2008), see www.w3.org"><!-- #BeginEditable "doctitle" -->
    
    <title>Lucifer's Dark Angel</title><!-- #EndEditable -->
    <meta http-equiv="Content-Type" content="text/html; charset=us-ascii">
    <style type="text/css">
        body {
            margin: 0;
        }
        
        table.gallery {
            margin-left: auto;
            margin-right: auto;
        }
        
        table.gallery td {
            height: 150px;
            width: 150px;
            background: red;
        }
        
        table.gallery td a {
            margin-left: auto;
            margin-right : auto;
            display: block;
        }
        
        table.gallery td a img {
            display: block;
        }
    </style>
  
</head>

<body bgcolor="#000000" text="#FFFFFF" link="#FFFFFF" vlink="#FFFFFF" alink="#FFFFFF">

END

my $postamble = <<END;
</body>
</html>
END

# Tags used to construct HTML - table related
my $tag_table_left = "<table class='gallery'>";
my $tag_table_right = "</table>";
my $tag_tr_left = "<tr>";
my $tag_tr_right ="</tr>";
my $tag_td_left = "<td>";
my $tag_td_right = "</td>";

# Tags for links and images
my $tag_anchor_left = "<a>";
my $tag_anchor_right = "</a>";
my $tag_img_left = "<img>";
my $tag_img_right = "</img>";

# HTML working strings
my $tag_image;
my $href;
my $html_line;
my $size_string;

# Data used to construct HTML
my $image_name;
my $thumbnail_name;
my $image_width;
my $image_height;

my $line;

my $line_count = 0;
my $output_lines = 0;
my $output_text;
my $process_flag;

# If there is a parameter it will be the path to the folder where the images are

my $image_path;
if (defined $ARGV[0]) {
    $image_path = $ARGV[0];
} else {
    $image_path = ".";
}

# Get list of image files with width and height.  This will probably only work on Mac or Unix/Linux platform
# Replace with standard Perl library in future.
my $sips_command = "sips -g pixelWidth -g pixelHeight *.jpg";
my $image_data = `$sips_command`;

# Open file to write HTML snippet to
open my $handle, '<', \$image_data;
open my $write, '>', "gallery.html";

# Process output from sips command.  For every thumbnail, create the html line but check whether main image file
# exists first.  Output list of files where there is a thumbnail but the main file doesn't exist.
$process_flag = 0;
while (defined ($line = <$handle>)) {
    $line_count++;
    chomp $line;
    if ($line =~ m/^\/.+\/(.+\.(jpg|jpeg|JPG|JPEG))/) {
        
        # This line represents a file, so check whether we want to process it.
        # Only process if this is a thumbnail (as there is nothing to display on the link otherwise)
        
        $thumbnail_name = $1;
        if ($thumbnail_name =~ m/TN_(.+)/) {

            # This is a thumbnail - check whether main file exists and skip if not.
            if (!-e $1) {
                $process_flag = 0;
                say "No file ($1) for thumbnail $thumbnail_name";
            } else {
                $process_flag = 1;
                $image_name = $1;
                $href = "href='$image_path/$image_name'";
            }
        } else {
            # Not a thumbnail so skip
            $process_flag = 0;
        }
    } elsif ($line =~ m/^  pixelWidth: (\d+)/) {
        
        # This line is for the image width, so check we are processing the file and extract width and create html snippet.
        if ($process_flag) {
            $image_width = $1;
        }
    } elsif ($line =~ m/^  pixelHeight: (\d+)/) {
        
        # This line is for the image height, so check we are processing the file and extract height and create html snippet.
        if ($process_flag) {
            $image_height = $1;
            
            # We have processed all the lines for the file so can process the data
            # We need to work out which is the longer side and that is the one we constrain.  The other will be
            # sized proportionally.
            
            if ($image_height >= $image_width) {
                $size_string = "height='" . $max_dimension . "'";
            } else {
                $size_string = "width='" . $max_dimension . "'";
            }

            $tag_image = "<img " . " src='$image_path/$thumbnail_name' $size_string" . " />";
            $html_line = $tag_td_left . "<a " . $href . ">" . $tag_image . $tag_anchor_right . $tag_td_right;
            if ($output_lines == 0) {
                print $write $preamble;
                print $write $tag_table_left . "\n"
            }
            if ($output_lines % $table_column_width == 0) {
                if ($output_lines != 0) {
                    print $write $tag_tr_right . "\n";
                }
                print $write $tag_tr_left . "\n";
            }
            print $write $html_line . "\n";
            $output_lines++;
        }
    } else {
        say "Unrecognised line $line, ignoring";
    }
}
print $write ($tag_td_left . $tag_td_right . "\n") x ($table_column_width - ($output_lines % $table_column_width));
print $write $tag_tr_right;
print $write $tag_table_right;
print $write $postamble;
close $write;

