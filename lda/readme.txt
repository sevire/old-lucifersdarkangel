This file explains how the website for lucifersdarkangel.co.uk is built and how to maintain it.

This file comprises the following sections:

1. Overview of Approach Taken
2. Site Structure
3. Text Pages
4. Galleries


===============
= 1. OVERVIEW =
===============

The site is made up of two types of page; text pages and galleries.

All pages are created automatically by the script xxxxx.pl.  The important thing to remember is just to ensure that folders and files are set up correctly so that the site is built as intended.  The following is a list of what the script uses to build the site from.

Pages:
------

Every page which exists on the site must have a file entitled "PAGE-NN-pagename.txt" in the content/pages folder.

The name of the page will be "pagename", i.e. taken from the name of the file.

The number of the page will be used to determine the order in which the page appears in the linkbar (see later).  If the page is not to appear in the linkbar (i.e it may be a page linked to from within one of the other pages) then the number should be 00.

The text within the text file will appear on the page, and can be formatted using the simple rules of Markdown.  See xxxx for details of how to use Markdown to format the text in a web page.

Galleries:
----------

Some of the pages can be set to be a gallery page.  In order to make a page into a gallery page, it is simply necessary to create a folder, under the content/galleries folder, with the same name as the page - that is the 'pagename' used in the name of the text file described above.

The folder for each gallery must contain the images which should appear on that gallery page.  The images will appear in alphabetical order so by naming the files appropriately it is easy to change the order of the files.

Thumbnails will be created automatically during the creation of the website so these do not need to becreated beforehand.

Linkbar:
--------

The website has a flat structure, so a single link bar is created containing each of the pages (including galleries) and this linkbar will appear on all pages.

Artwork:
--------

The website includes a number of images which are designed to vary from page to page. In particular the left and right images on a page vary.  When the site is created these images will be allocated randomly to each page.

==============================
= 2. HOW IT WORKS - OVERVIEW =
==============================

The intention of the design is that the website is created offline and then uploaded to the website domain. It would be possible to execute the scripts in place and create the website in a single step that way, but this risks overwriting files before testing that the script has worked, and also the script has not been tested with this in mind, so take this path at your own risk.

The website, once created is static.  No elements of the page are created on the fly.  This is because when the scripts were written the ability to control the use of cgi scripts was not available.

However Server Side Includes (SSI) are employed, mainly to allow common content to appear in multiple pages.  The main use for these has been the link bar which appears on all pages in the site.  This is created as part of the script but is then referenced from the page templates and included by the web server as part of the serving of each page.

When a gallery page is created, the images in the gallery folder will appear on the page in alphabetical order of the name of the image file.  This allows control of the placement of pages by use of naming conventions for the images.

Thumbnails will automatically be created for each image and placed in the thumbnails folder under the gallery folder for that gallery.

==================
= 3. PAGE LAYOUT =
==================

Templates are used to determine the page layout.  A template is effectively a full html page file, with placeholdes for page dependent text.  There are two templates, xxxxx.html and xxxxxx.html, which are used to generate text pages and gallery pages respectively.  The templates will be used by the script to generate the pages and are in a format recognised by the Perl html template module, which includes placeholders for variable content.

The scripts have been designed to accept the following variable content:

- Left image
- Right image
- Text
- Gallery images (for gallery pages)

During page creation by the script, the left and right images will be selected at random from the image files available.  The text for the page will be taken from the text file with the same name and passed to the template.

Text is held in a text file in the content/pages folder.  The name of the text file will be used as the title of the page created.  The text should be formatted according to the 'Markdown' system, which allows easily formatted text which can be used by a non html expert.  However html can also be used if required.

=====================
= 4. MAKING CHANGES =
=====================

It isn't necessary to re-generate the whole site if a small change is made to individual pages.  Only if a change is made which impacts every page might it be necessary to re-generate the whole site, and not always then.

Changes which impact the content of individual pages can be effected by using the update_page script from the main folder of the development area.  The command to execute the script is:

update_page [--transmit] <pagename1>[, <pagename2> ...]

This will take each page specified and recreate the page, taking any chages to the text file or the images into account.

If the page specified is a new page, then the script will additionally update the SSI file which contains the linkbar, so that the new page will appear in the linkbar on every page.

if the --transmit option is selected, once the script has created or modified the html files and any other files affected, it will then ftp them straight to the live site.  This therefore allows small changes to the site to be made quickly and put live immediately.

====================
= 5. GENERAL NOTES =
====================

This section provides a number of notes, hints and tips for using the scripts.

- Creating pages in advance of making them live.

If you want to develop the text of a page over a period of several sessions but don't want the page to be generated until you have finished, you simply need to create a text file with a name which won't be picked up by the script.  If you omit the PAGE_ prefix from the name of the file then the file won't be picked up.

It may be helpful to adopt a naming convention for text files in development so they can easily be identified and distinguished from live files.  One suggested convention is to name these files DEV-pagename.txt.  Once the text is completed and you want the page to go live you can rename it to PAGE-NN-pagename.txt.

- Creating a gallery in advance of making it live.

There are two approaches which could be used to work on a gallery in advance of generating a live page from it.

Firstly, using the approach described above for text pages, if a text file for a page does not exist with the appropriate naming convention then the page won't be created, and that is still true if the page is to be a gallery.  So the gallery folder can be created with the right name and as soon as the text file for the page is renamed, then the gallery will be created once the site is generated (or the update_page script is used)

Alternatively, if the intention is to change an existing page into a gallery, then work can be done in advance by creating a gallery folder with a name which doesn't correspond to a live page.  Then when the gallery folder is ready (i.e. all the images are in place with the right names to reflect the order they wil be displayed) the name of the folder can be renamed to the pagename and once that pages is generated the gallery images will be detected and the page will be generated as a gallery page.

===========================================
= 6. List of Components / Files / Scripts =
===========================================

This section explains everything which should be present in order to use this system to generate the website.

- Folder Structure.  This is described below:

(Main Folder)
- content
-- galleries
--- (Folder for each gallery with the name pagename).  Must correspond to a text file to be detected.
-- pages
- images
- css

- Scripts

update_site.pl : Updates or builds all pages based on the content, templates and images which are present.
update_page.pl : Updates a single page based on content etc which is present
transmit_site.pl : Sends all files required to drive the site to the live environment
transmit_page.pl : Sends all files required for a particular page to the live environment