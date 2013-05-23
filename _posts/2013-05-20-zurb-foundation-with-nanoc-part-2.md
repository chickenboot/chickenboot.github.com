---
layout: post
title: Zurb Foundation &amp; nanoc&#58; Foundation Javascripts
abstract: Installing Foundation javascripts, concatenating and minifying and activating the responsive top bar
published: true
---

The plan for the final company site is that it should be rich and responsive (meaning it plays nicely across many devices). To start that big old ball rolling, we will look at the steps required to make the top/menu bar nav responsive, using the foundation javascripts. This should get the infrastructure in place for any other javascript we want to add later on.

### Concatenating and Minifying

We first need to tell nanoc (in `nanoc.yaml`) to allow a `.` in an identifier, because many of the foundation javascripts are named `jquery.foundation.$function` (otherwise it will create all sorts of crazy directories).

While we're in the config file, I'm going to create a new config variable to indicate which javascripts should be 'compiled' (concatenated), and which should be just passed through to the output directory:

{% highlight bash %}
vintageinvite$ subl nanoc.yaml
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.1/nanoc.yaml">nanoc.yaml</a></div>
{% highlight yaml %}
allow_periods_in_identifiers: true

javascripts:
  compile:
    - jquery
    - jquery.foundation.topbar
  passthrough:
    - modernizr.foundation
    - app
{% endhighlight %}

We're just including jquery and the Foundation topbar for now, and passing through `modernizr.foundation` so we can include that separately in the `<head>` (Modernizr detects all the features of the current device, so it makes sense to get it in as early as possible). We're also passing through `app`, which doesn't exist yet, but is going to be the placeholder file where the concatenated javascript will live. 

In order to combine the necessary javascript, we're going to create a Ruby function which takes a list of filenames and returns a string of the combined data. This will live in the `lib` directory - all files in here are picked up by nanoc before compilation:

{% highlight bash %}
vintageinvite$ subl lib/concat_files.rb
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.1/lib/concat_files.rb">lib/concat_files.rb</a></div>
{% highlight ruby %}
def concat_files(files)
  files.collect do |f|
    item = @items.find {|i| i.identifier =~ /#{f}\/$/}
    if item
      item.compiled_content
    else
      puts "WARNING: couldn't find file #{f}"
    end
  end.compact.join("\n")
end
{% endhighlight %}

Now that we have this function, we can use an erb (embedded Ruby) template for our `app.js` file:

{% highlight bash %}
vintageinvite$ subl content/assets/javascripts/app.js
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.1/content/assets/javascripts/app.js">content/assets/javascripts/app.js</a></div>
{% highlight erb %}
<%= concat_files(@config[:javascripts][:compile]) %>

$(document).ready(function () {
    $(document).foundationTopBar();
})
{% endhighlight %}

The embedded Ruby at the top will be replaced with all the concatenated javascript, and then at the bottom of the file, a function call to enable the top bar when the document is ready (I have forgotten this before and spent far too long figuring out what I've done wrong...).

In order to minify the combined javascript, we're going to use the _uglifier_ gem, so we'll add that to our `Gemfile`:

{% highlight bash %}
vintageinvite$ subl Gemfile
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.1/Gemfile">Gemfile</a></div>
{% highlight ruby %}
gem 'uglifier'
{% endhighlight %}

### Rules and Layout

Now we just need to put it all together in the `Rules` file:

{% highlight bash %}
vintageinvite$ subl Rules
{% endhighlight bash %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.1/Rules">Rules</a></div>
{% highlight ruby %}
compile '/assets/javascripts/*' do
  filter :erb
  filter :uglify_js if @config[:javascripts][:passthrough].include?(File.basename(item.identifier))
end

route '/assets/javascripts/*' do
  filename = File.basename(item.identifier)
  '/assets/' + filename + '.js' if @config[:javascripts][:passthrough].include?(filename)
end
{% endhighlight %}

The last thing to do is include the javascript in our default layout - we'll load `modernizr` in the head as discussed above, and the main `app.js` file at the foot (to ensure the site is rendered before loading up the javascript).

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.1/layouts/default.haml">layouts/default.haml</a></div>
{% highlight haml %}
!!! 5
%html
  %head
    %meta{:charset => "utf-8"}
    %title
      A Brand new nanoc site -
      = item[:title]
    %link{:rel => "stylesheet", :href => "/assets/app.css" }
    %script{:src => "/assets/modernizr.foundation.js" }
  %body
    .contain-to-grid
      %nav.top-bar
        %ul
          %li.name
            %a{:href => "/"} the vintage invite co
          %li.toggle-topbar
            %a{:href => "#"}
        %section
          %ul.right
            %li
              %a{:href => "#"} Contact
    .row
      .twelve.columns
        = yield

    %script{:src => "/assets/app.js" }
{% endhighlight %}

Now if we compile and view the site, we should get a lovely responsive top bar&#151;I've tested it below by shrinking the width of the Chrome window, and clicking on the arrow when it appears:

![Responsive Top Bar](/asset/image/2013-05-20/zurb-nanoc-responsive.png "Responsive Top Bar")
