# Config values for WebGenHelper and associated scripts

package WebGenConfig;

sub get_config_data {
    our %data = (
        root => ".",
        target_root => ".",
        content_rel_path => "content",
        ds => "/",
        text_file_rel_path => "page_text_files",
        template_folder => "templates",
        gallery_template_filename => "gallery_template.html",
        text_template_filename => "text_template.html",
        gallery_folder_rel_path => "galleries",
        text_file_pattern => "PAGE-(\\d{2})-(.+).txt", # Match file with format PAGE-nn-Pagename
        table_column_width => 4,
        max_dimension => 130,
        table_column_width => 4,
    );
    $data{text_rel_path} = $data{content_rel_path} . $data{ds} . "pages";
    $data{gallery_rel_path} = $data{content_rel_path} . $data{ds} . "galleries"; 
    return %data;
}
1