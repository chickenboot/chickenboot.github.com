Jekyll + ZURB Foundation Quickstart
===================================

A template project to quickly start a new project based on ZURB Foundation
and the Jekyll static site generator.

Unlike other projects (such as Octopress), this is a minimal skeleton
repository upon which you can build your project. You _have_ to understand
all the moving parts and how they are configured.




What's Inside
=============

## Technologies

* SASS
* Compass;
* ZURB Foundation;
* Foreman;

## Goodies

* Default page templates, suitable for a blog;
* Sensible Jekyll defaults;
* Site-wide Atom feed for all blog posts;
* Uses Foreman to orchestrate `compass watch` and Jekyll development server;




Getting Started
===============

Clone this repository and perform the automated setup procedure:

    git clone git://github.com/lvillani/quickstart-jekyll-zurb.git my-site
    cd my-site
    make setup

At this point you can start the development server by running:

    make runserver




Directory & File Layout
=======================

    .
    ├── asset/         -- Static assets (e.g.: images)
    ├── _layouts/      -- Jekyll Layouts
    ├── _posts/        -- Blog posts
    ├── _sass/         -- SASS/SCSS (processed by Compass)
    ├── _site/         -- Output directory for generated content
    ├── _config.yml    -- Jekyll Configuration file
    ├── compass.rb     -- Compass configuration file
    ├── Gemfile        -- Ruby Bundler configuration file
    ├── Makefile       -- Top level Makefile
    ├── Procfile       -- Foreman configuration file
    └── robots.txt     -- Directives for web crawlers




License
=======

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute
this software, either in source code form or as a compiled binary, for any
purpose, commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors of this
software dedicate any and all copyright interest in the software to the public
domain. We make this dedication for the benefit of the public at large and to
the detriment of our heirs and successors. We intend this dedication to be an
overt act of relinquishment in perpetuity of all present and future rights to
this software under copyright law.

Unless you really want to, do not even mention that the copied content
originates from this skeleton library. Its sole purpose is to be copied into
other projects.

The above statements apply to all content in this skeleton library, even when
the COPYING files, or the headers in the files state otherwise, they are just
common examples.
