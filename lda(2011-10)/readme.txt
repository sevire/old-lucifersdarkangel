This file explains how the website for lucifersdarkangel.co.uk is built and how to maintain it.

This file comprises the following sections:

1. Overview of Approach Taken
2. Site Structure
3. Text Pages
4. Galleries

1. OVERVIEW

The site is made up of two types of page; text pages and galleries.

All pages are created automatically by the script xxxxx.pl.  The intention of the design is that the website is created offline and then uploaded to the website domain.

Although Server Side Includes are used by some of the templates/pages to reference common page elements, there is no dynamic page creation.  This site has been built on the assumption that no cgi capability exists (because this was the case when the website was built).

The pages which exist within the website are defined by text files within the content/pages folder.  These files should be named 'PAGE-pagename.txt'.  One page will be created for each such file, and the name of the page will be the name of the file.

This naming convention, using the 'PAGE' prefix, allows pages to be put in place but not live, and the file can then be renamed to make the page live.

If a folder exists within the content/galleries folder with the same name as one of the pages in the website, then that page will be created as a gallery page with the images from that folder.

If a gallery folder exists without a corresponding text file, no gallery page will be created for the images in that folder.  This allows folders to be created in advance and activated by creating (or renaming) the appropriate text file.

Text pages are created by using a page template compatible with the perl HTML:TEMPLATE module.  A single template is used to drive all text pages.  There are three variable components within a page:

- Left image
- Right image
- Text

Text is held in a text file in the content/pages folder.  The name of the text file will be used as the title of the page created.  The text should be formatted according to the 'Markdown' system, which allows easily formatted text which can be used by a non html expert.  However html can also be used if required.

When a gallery page is created, the images in the gallery folder will appear on the page in alphabetical order of the name of the image file.  This allows control of the placement of pages by use of naming conventions for the images.

Thumbnails will automatically be created for each image and placed in the thumbnails folder under the gallery folder.