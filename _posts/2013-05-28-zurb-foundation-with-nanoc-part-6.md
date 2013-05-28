---
layout: post
title: Zurb Foundation &amp; nanoc&#58; Layout Tweaks
abstract: Adding a Foundation Orbit slideshow to the homepage, and adding an active class to the navigation links
published: true
---

To follow on from the last post, the final requirement before handing over is to change the homepage from a staging header to something that might be the minimum infrastructure required (at a stretch) for a production website. 

But first...

### Fixing the Mobile View

I made a minor fur cup in the default layout so far&#151;it's only because I recently tried the site out on my mobile that I noticed. I was missing one crucial line:

{% highlight haml %}
    %meta{:name => "viewport", :content => "width=device-width" }
{% endhighlight %}

According to Zurb: _this is used to make sure smaller devices use the device width as the viewport width_. And this solves the problem of the non-mobile-view mobile view!

### An Orbital Index

Once we have some pictures to show our products off, we'll be wanting the pick of them to be the first thing a visitor sees. To that end, I'm going to make our index page include an image slideshow, with a header. Foundation provides us with the [Orbit](http://foundation.zurb.com/old-docs/f3/orbit.php) javascript to make this a doddle. To use it, we have to include the orbit javascript in our `nanoc.yaml`:

{% highlight bash %}
vintageinvite$ subl nanoc.yaml
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.5/nanoc.yaml">nanoc.yaml</a></div>
{% highlight yaml %}
javascripts:
  compile:
    - modernizr.foundation
    - jquery
    - jquery.foundation.topbar
    - jquery.foundation.orbit
{% endhighlight %}

We can now build the homepage layout. Since I don't have any useable images yet, I'm going to use [placehold.it](http://placehold.it) to provide some placeholder images of the right size. Here is our layout:

{% highlight bash %}
vintageinvite$ subl content/index.haml
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.5/content/index.haml">content/index.haml</a></div>
{% highlight haml %}
---
title: Home
---
.row
  .twelve.columns
    #main-orbit
      %img{:src => "http://placehold.it/1500x500&text=Slide%201"}
      %img{:src => "http://placehold.it/1500x500&text=Slide%202"}
      %img{:src => "http://placehold.it/1500x500&text=Slide%203"}
.row
  .twelve.columns
    %h2.text-center An impressive title goes here
    %h4.text-center.subheader And an equally impressive subtitle should go here
.row
  .twelve.columns
    %h4.text-center
      Take a look at
      %a{:href => "/blog/"} our blog
{% endhighlight %}

An 'orbit' simply requires you have a `div` element with an identifier to contain your images. 

We still need to activate the orbit, which means adding a javascript function call at the end of the document, _after_ the inclusion of our main `app.js`. A simple, generic way to do this, is to add some metadata to the page (identifying the orbit) and then add a generic activator in the default layout:

{% highlight bash %}
vintageinvite$ subl content/index.haml
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.5/content/index.haml">content/index.haml</a></div>
{% highlight haml %}
---
title: Home
orbit: main-orbit
---
{% endhighlight %}

{% highlight bash %}
vintageinvite$ subl layouts/default.haml
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.5/layouts/default.haml">layouts/default.haml</a></div>
{% highlight haml %}
    %script{:src => "/assets/app.js" }
    - if item[:orbit]
      :javascript
        $(window).load(function() {
          $("##{item[:orbit]}").orbit({ animation: 'fade', timer: false, bullets: true});
        });
{% endhighlight %}

As well as activating the orbit, this call is setting the animation to fade, switching off the automatic start of the slideshow, and adding bullets underneath.

I also want the navigation to only appear on hover, so I'm adding the css for this recommended by Zurb:

{% highlight bash %}
vintageinvite$ subl content/assets/stylesheets/app.scss
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.5/content/assets/stylesheets/app.scss">content/assets/stylesheets/app.scss</a></div>
{% highlight scss %}
.orbit-wrapper {
  .slider-nav span { @include opacity(0); @include single-transition(opacity, 400ms); }
  &:hover .slider-nav span { @include opacity(1); }
}
{% endhighlight %}

### Styling the Navigation Links

With the homepage sorted, there's one last navigation tweak I want to add, and that is highlighting of the currently active page. The `active` style already exists, so all we need to do in theory is to add the `active` class to the currently active link. One way to achieve this is to check the current item's identifier, and apply the class accordingly. 

Rather than repeating this check for every navigation link, we can embed a simple ruby function to do the work for us:

{% highlight bash %}
vintageinvite$ subl layouts/default.haml
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.5/layouts/default.haml">layouts/default.haml</a></div>
{% highlight haml %}
:ruby
  def nav_li(s)
    if item.identifier == "/#{s}/"
      haml_tag('li', s.capitalize, :class => 'active')
    else
      haml_tag('li') do
        haml_tag('a', s.capitalize, :href => "/#{s}/")
      end
    end
  end

!!! 5
%html
  %head
    %meta{:charset => "utf-8"}
    %meta{:name => "viewport", :content => "width=device-width" }

    %title
      The Vintage Invite Company -
      = item[:title]
    %link{:rel => "stylesheet", :href => "/assets/app.css" }
    %script{:src => "/assets/modernizr.foundation.js" }
  %body
    .row
      .vic-topbar
        .four.columns
          %a{:href => "/"}
            %img{:src => "/assets/logo.svg", :title => "The Vintage Invite Company"}
        .eight.columns
          %ul.right
            - nav_li('blog')
            - nav_li('about')
            - nav_li('contact')
{% endhighlight %}

This uses haml's `:ruby` filter to embed a function: `nav_li`, which checks the current item's identifier against the given parameter. If it matches, then we create a text-only list element with a class of `active`, otherwise we create the usual `li` with the link inside.

Note that I've also added a `contact` and `about` page (with some filler text for now), which has changed the navigation. Here is what the homepage looks like on a desktop:

![Desktop View of Homepage](/asset/image/2013-05-28/zurb-nanoc-orbit-desktop.png "Desktop View of Homepage")

and on mobile:

![Mobile View of Homepage](/asset/image/2013-05-28/zurb-nanoc-orbit-mobile.png "Mobile View of Homepage")

Next time we will talk about minor compatibility improvements, and still to come is adding in real content and deploying to the live site.


