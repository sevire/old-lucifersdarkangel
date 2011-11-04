#!/usr/bin/perl -w
package WebGenHelper;
use WebGenConfig;

use strict;
use warnings;
use feature ':5.10';
use Data::Dumper;

my %config = WebGenConfig::get_config_data;
my @text_file_list; # Stores file listing to avoid having to re-execute for each page

sub is_gallery {
    # Works out whether there is a sub-folder for a gallery with the same
    # name as supplied page.  Is so then the page is a gallery page.
    
    my $page_name = shift;
    my $candidate_gallery_path = $config{root} . $config{ds} . $config{content_rel_path} .
        $config{ds} . $config{gallery_folder_rel_path} . $config{ds} . $page_name;
    
    say sprintf("Looking for gallery folder <%s>\n", $candidate_gallery_path);
    if (-e $candidate_gallery_path && -d $candidate_gallery_path) {
        return 1;
    } else {
        return 0;
    }
}

sub get_text_file_list {
    if (!@text_file_list) { # Tests size so implicitly whether dir listing has been done
        my $dir_path = $config{root} . $config{ds} . $config{content_rel_path} . $config{ds} . $config{text_file_rel_path};
        say "Reading directory $dir_path";
        opendir(my $handle, $dir_path);
        my @list =  readdir($handle);
        printf("Files from read dir...\n");
        say Dumper(@list);
        
        # Filter out dirs and files which don't correspond to filename pattern
        
        while (scalar(@list) > 0) {
            my $file = shift(@list);
            printf("Checking <%s>\n", $file);
            if (!(-d $file) && $file =~ $config{text_file_pattern}) {
                printf("Is valid file, adding to list\n");
                push(@text_file_list, $file);
            }
        }
    }
    say "Num files is: " . scalar(@text_file_list);
    return @text_file_list;
}

sub get_textfile_for_page {
    my $page = shift;
    printf("Finding text file for page <%s>\n", $page);
    get_text_file_list;
    foreach my $file (@text_file_list) {
        if ($file =~ $config{text_file_pattern} && $2 eq $page) {
            return $file;
        }
    }
    return undef;
}

sub generate_page {
    
}

sub generate_gallery {
    
}

sub page_exists {
    # Checks whether there is a text content page for the given page name
    
    my $page_name = shift;
    
    say sprintf("Checking existence of <%s>...\n", $page_name);
    
    get_text_file_list;
    
    foreach my $file (@text_file_list) {
        if ($file =~ $config{text_file_pattern} && $2 eq $page_name) {
            return 1; # Matches and right page number so return true;
        }
    }
    return 0; # Not found so return false;
}

sub get_image_data {
    # Takes the pathname of a directory (or looks in current directory) and creates a list of all image
    # files in the directory together with the height and width of each image.
    
    # Handle parameter(s)
    my $path = shift;
    if (!defined $path) {
        $path = ".";
    }
       
    # Use Mac OSX sips command to get required data about images in supplied path
    my $image_data = `cd $path;sips -g pixelWidth -g pixelHeight *.jpg *.JPG`;
    
    my $line;
    
    my @image_array;
    my $file_name;
    my @single_image_properties;
    my $sips_string;
    my $handle;
    
    open $handle, '<', \$image_data;
    while (defined ($line = <$handle>)) {
        # Lines will appear in threes because of the way the sips command is constructed :
        # - pathname
        # - width
        # - height

        chomp $line;
        
        if ($line =~ m/^\/.+\/(.+\.(jpg|jpeg|JPG|JPEG))/) {
            
            # This line is the file name
            @single_image_properties = ();
            $file_name = $1;
            $single_image_properties[0] = $file_name;
            
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
    my $dir_path = $config{root} . "/" . $config{text_rel_path};
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
            if ($file =~ $config{text_file_pattern}) {
                $gallery_candidate_path = $config{root} . "/" . $config{gallery_rel_path} . "/" . $2;
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

1;