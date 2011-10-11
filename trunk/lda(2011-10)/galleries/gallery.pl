#!/usr/bin/perl -w
use strict;
use warnings;
use feature ':5.10';
use HTML::Template;

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
    my @single_image_properties;
    
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
            $single_image_properties[0] = $1;
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
        my ($name, $height, $width) = @$image_data;
        
        say "Current name is $name";
        
        $thumbnail_path = $image_path . "/thumbnails/" . $name;
        if ($height >= $width) {
            $size_string = "height='" . $max_dimension . "'";
        } else {
            $size_string = "width='" . $max_dimension . "'";
        }

        $tag_image = "<img " . " src='$image_path/$name' $size_string" . " />";
        $html_line = "<td>" . "<a " . "href='$thumbnail_path'" . ">" . $tag_image . "</a>" . "</td>";
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

# Formatting parameters
my $table_column_width = 4;
my $max_dimension = 130;
my $image_path = "gallery-01";

# Process image files in 
my @images = get_image_data($image_path);

# Create gallery table
my $page = create_table_of_images(\@images, 130, $image_path, 4, $image_path);

# Make up page from gallery and template
open my $file, '>', "gallery.shtml";
my $template = HTML::Template->new(filename => 'gallery_template.html');
$template->param('MAIN_CONTENT' => $page);
print $file $template->output;
close $file;


