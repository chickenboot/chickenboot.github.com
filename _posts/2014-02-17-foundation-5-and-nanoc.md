---
layout: post
title: Foundation 5 and nanoc
abstract: Setting up a development environment to use Zurb Foundation 5 with nanoc
published: false
---

I've not blogged about the company website for a while, because we're still going backward and forward on designs (mainly backwards it seems, but we'll get there soon!), and also it is increasingly difficult to find time to document absolutely everything while it is going ahead. I plan to instead post shorter hints/highlights to achieve small things (whilst leaving the repo on github for anyone who wants to follow the development of the site!).

I wanted to document how I setup a new environment to develop using nanoc and the latest Foundation (5.1.0 at the time of writing). It wasn't straightforward thanks to the switch from rubygems to Bower, so I thought I'd share how I settled on it working, following similar steps to the original post about nanoc+foundation...

### Installing nanoc and Creating a Project

{% highlight bash %}

$ gem install nanoc adsf
$ nanoc create-site nanoundation5
...
$ cd nanoundation5
nanoundation5$ ls
Rules   content   layouts   lib   nanoc.yaml  output
nanoundation5$ nanoc compile
...
nanoundation5$ nanoc view
{% endhighlight %}

{% highlight bash %}
nanoundation5$ gem install bundler    
nanoundation5$ subl Gemfile
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/mrpies/vintageinvite/blob/v1.0/Gemfile">Gemfile</a></div>
{% highlight ruby %}
source :rubygems

gem 'nanoc'
gem 'adsf'
gem 'haml'
gem 'foundation'
gem 'compass'
gem 'uglifier'
{% endhighlight %}

{% highlight bash %}
nanoundation5$ bundle install
{% endhighlight %}

I'm using the same Rails-style assets folders for my images, javascripts and stylesheets:

{% highlight bash %}
nanoundation5$ mkdir -p content/assets/stylesheets
nanoundation5$ mkdir -p content/assets/javascripts
nanoundation5$ mkdir -p content/assets/images
nanoundation5$ rm content/stylesheet.css
{% endhighlight %}

### Foundation and Bower

So far so good&ndash;this is pretty much the same as before, though you'll notice the Gemfile has changed to contain a dependency on foundation instead of zurb-foundation. Now we're going to follow the very very useful post here http://foundation.zurb.com/forum/posts/292-compass--updating-gem-from-foundation-432-to-foundation-5 which shows how to migrate from foundation 4.3.2 to 5+. 

Installing bower requires the node package manager, which you can download from http://nodejs.org.

{% highlight bash %}
nanoundation5$ sudo npm install -g bower
nanoundation5$ subl bower.json
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/mrpies/vintageinvite/blob/v1.0/Gemfile">bower.json</a></div>
{% highlight json %}
{
  "name": "nanoundation5",
  "dependencies": {
    "jquery": "2.1.0",
    "foundation": "5.1.1"
  }
}
{% endhighlight %}

{% highlight bash %}
nanoundation5$ bower install
{% endhighlight %}

Hopefully this has all gone through without a hitch (drop me a note in the comments if you encounter issues and I'll do my best to help!), and you now have a `bower_components` directory.

### Compass Configuration and CSS

We need to create a compass configuration that is similar to that created for earlier versions of Foundation, but we need to refer to the new location of the stylesheets, within the bower_components directory.

{% highlight bash %}
nanoundation5$ subl config.rb
{% endhighlight %}

{% highlight ruby %}
add_import_path "bower_components/foundation/scss"

# -----------------------------------------------
# Paths
# -----------------------------------------------

http_path = "/"
css_dir = "output/assets"
images_dir = "content/assets/images"
javascripts_dir = "content/assets/javascripts"
sass_dir = "content/assets/stylesheets"

# -----------------------------------------------
# Output
# -----------------------------------------------

output_style = :compressed
preferred_syntax = :scss
relative_assets = true

{% endhighlight %}

Finally, we need to copy the _settings.scss template for any settings we want to change, and create an app.scss to include the foundation styles:

{% highlight bash %}
nanoundation5$ cp bower_components/foundation/scss/foundation/_settings.scss content/assets/stylesheets/
{% endhighlight %}

{% highlight sass %}
@import "settings";
@import "foundation";
{% endhighlight %}

### 

I'm going to reuse the Rules file from the previous Foundation 3 blogs:

