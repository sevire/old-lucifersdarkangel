#!/usr/bin/perl -w
package WebsiteGen;

use strict;
use warnings;
use feature ':5.10';
use HTML::Template;
use File::Basename;

sub initialise {
    # Used to set driver values for the website
    
    our $root = ".";
    our @image_types = ("jpg", "png");
    our $gallery_rel_path = "content/galleries";
    our $text_rel_path = "content/pages";
    our $template_rel_path = "templates";
    our $gallery_template = "gallery_template";
    our $text_template = "text_template";
    our $text_file_pattern = "PAGE-(\\d{2})-(.+).txt"; # Match file with format PAGE-nn-Pagename
    our $table_column_width = 4;
}


sub get_image_data {
    # Takes the pathname of a directory (or looks in current directory) and creates a list of all image
    # files in the directory together with the height and width of each image
    
    my $path = shift;
    if (!defined $path) {
        $path = ".";
    }
        
    my $image_data = `cd $path;sips -g pixelWidth -g pixelHeight *.jpg *.JPG`;
    
    my $line;
    my $name;
    
    my @image_array;
    my $file_name;
    my @single_image_properties;
    my $sips_string;
    
    open my $handle, '<', \$image_data;
    while (defined ($line = <$handle>)) {
        # Lines will appear in threes because of the way the sips command is constructed :
        # - pathname
        # - width
        # - height
        chomp $line;
        # Initialise image propoerties so we can tell whether they have all been set later
        say $line;
        
        if ($line =~ m/^\/.+\/(.+\.(jpg|jpeg|JPG|JPEG))/) {
            @single_image_properties = ();
            $file_name = $1;
            $single_image_properties[0] = $file_name;
            $sips_string = "mkdir $path/thumbnails;cp $path/$file_name $path/thumbnails;cd $path/thumbnails; sips -Z 130 $file_name";
            say "sips string is $sips_string";
            `$sips_string`;
            say "single image properties [0] is $single_image_properties[0]";
        } elsif ($line =~ m/^  pixelWidth: (\d+)/) {
            $single_image_properties[1] = $1;
            say "single image properties [1] is $single_image_properties[1]";
        } elsif ($line =~ m/^  pixelHeight: (\d+)/) {
            $single_image_properties[2] = $1;
            say "single image properties [2] is $single_image_properties[2]";
            if ((!(exists $single_image_properties[0])) || (!(exists $single_image_properties[1]))) {
                die "Incomplete data while processing sips command, current line is $line";
            } else {
                say "length of single_image_properties is " . scalar(@single_image_properties);
                push (@image_array, [@single_image_properties]);
            }
        }
    }
    say "length of image_array is " . scalar(@image_array);
    @image_array;
}

sub create_table_of_images {
    # Takes array of image data and creates a table for use in a gallery page. Assumes
    # that thumbnails exist for each file with prefix TN_ in sub dir called thumbnails.
    # TD elements will be set by css, but images will need to be set individually to
    # get orientation and aspect ration correct.
    #
    
    my($image_array, $max_dimension, $image_path, $table_column_width) = @_;
    
    say "Number of elements in image array (in sub) is " . scalar(@$image_array);
    say "max dimension is $max_dimension";
    say "image path is $image_path";
    say "table_column_width is $table_column_width";

    my $image_data;
    my $size_string;
    my $tag_image;
    my $thumbnail_path;
    my $html_line;
    my $html;
    my $output_lines;

    $html = "";
    $output_lines = 0;
    foreach $image_data (@$image_array) {
        my ($name, $width, $height) = @$image_data;
        
        say "Current name is $name";
        
        $thumbnail_path = $image_path . "/thumbnails/" . "TN_" . $name;
        if ($height >= $width) {
            $size_string = "height='" . $max_dimension . "'";
        } else {
            $size_string = "width='" . $max_dimension . "'";
        }

        $tag_image = "<img " . " src='$thumbnail_path' $size_string" . " />";
        $html_line = "<td>" . "<a " . "href='$image_path/$name'" . ">" . $tag_image . "</a>" . "</td>";
        say "Current line is : $html_line";
        
        if ($output_lines == 0) {
            $html .= "<table class='gallery'" . "\n";
        }
        if ($output_lines % $table_column_width == 0) {
            if ($output_lines != 0) {
                $html .= "</tr>" . "\n";
            }
            $html .= "<tr>" . "\n";
        }
        $html .= $html_line . "\n";

        $output_lines++;
    }
    $html .= ("<td></td>" . "\n") x ($table_column_width - ($output_lines % $table_column_width));
    $html .= "</tr>\n</table>";
    $html;
}

sub create_gallery_page {
    my($table_column_width, $max_dimension, $image_path) = @_;
    my $gallery_name = basename( $image_path );

    # Process image files in 
    my @images = get_image_data($image_path);
    
    # Create gallery table
    my $page = create_table_of_images(\@images, 130, $image_path, 4, $image_path);
    
    # Make up page from gallery and template
    open my $file, '>', $gallery_name . ".shtml";
    my $template = HTML::Template->new(filename => 'gallery_template.html');
    $template->param('MAIN_CONTENT' => $page);
    print $file $template->output;
    close $file;
}

sub get_subdir_list {
    
    # Parameter : $root - path to look in for subdirs
    my $root = @_;
    
    my @file_list;
    my @dir_list;
    my $handle;
    my $file;
    
    opendir($handle, $root);
    @file_list= readdir($handle);
    foreach $file (@file_list) {
        if (-d $file && !($file =~ m/\..*/)) {
            push(@dir_list, $file);
        }
    }
    @dir_list;
}

sub calculate_page_lists {
    # Gets list of page text files and then work out which pages are galleries
    # Returns an array with two sub-arrays, one of pages and one of galleries
    # each sorted by page number
    
    my $handle;
    my @file_list;
    my @page_list;
    my @page_info;
    my $dir_path = $WebsiteGen::root . "/" . $WebsiteGen::text_rel_path;
    my $gallery_candidate_path;
    my $file;
    my $file_path;
    my @gallery_list;
    my @text_list;
    
    say "Reading directory $dir_path";
    opendir($handle, $dir_path);
    @file_list =  readdir($handle);
    # say "Num files is: " . scalar(@file_list);
    foreach $file (@file_list) {
        $file_path = $dir_path . "/". $file;
        # say "Checking '$file_path'";
        if (-d $file_path) {
            # say "$file_path is dir, ignoring";
        } elsif (-f $file_path) {
            say "\n";
            say "$file_path is file, checking";
            if ($file =~ $WebsiteGen::text_file_pattern) {
                $gallery_candidate_path = $WebsiteGen::root . "/" . $WebsiteGen::gallery_rel_path . "/" . $2;
                # say "Testing for existence of $gallery_candidate_path";
                if (-e $gallery_candidate_path) {
                    say "$file is gallery page for website";
                    push(@gallery_list, [$2, $1]);
                } else {
                    say "$file is text page for website";
                    push(@text_list, [$2, $1]);
                }
            }
        } else {
            say "$file_path is neither file nor directory (!!!!)";
        }
    }
    @page_list = (\@text_list, \@gallery_list);
    say "\nAll pages : @page_list\n";
    return @page_list;
}

sub main {
    my @pages = calculate_page_lists;
    
    my $pages_ref = $pages[0];
    my @pages_array = @$pages_ref;
    
    my $galleries_ref = $pages[1];
    my @galleries_array = @$galleries_ref;
    
    # Deal with text pages first
    
    say "\n\n\n--- Processing Text Pages";
    # say "pages is @pages\n";

    #say "array is @pages_array\n";
 
    foreach my $page_data_ref (@pages_array) {   
    
        say "Processing page with ref: $page_data_ref";
        my @page_data = @$page_data_ref;
        
        
        say "page name is   : $page_data[0]";
        say "page number is : $page_data[1]";
    }
}

initialise;
main;


