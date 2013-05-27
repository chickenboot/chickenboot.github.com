---
layout: post
title: Zurb Foundation &amp; nanoc&#58; Layout Tweaks
abstract: Adding a Foundation Orbit slideshow to the homepage, and adding an active class to the navigation links
published: false
---

To follow on from the last post, the last thing required before handing over is to change the homepage from a staging header to something that might work (at a stretch) in production.

### A Better Landing Page

Once we have some pictures to show our products off, we'll be wanting them to be the first thing a visitor sees. To that end, I'm going to make our index page an image slideshow, with a header. Foundation provides us with the [Orbit](http://foundation.zurb.com/old-docs/f3/orbit.php) javascript to make this a doddle. We have to first include the orbit javascript in our `nanoc.yaml`:

{% highlight bash %}
vintageinvite$ subl nanoc.yaml
{% endhighlight %}

{% highlight yaml %}
javascripts:
  compile:
    - modernizr.foundation
    - jquery
    - jquery.foundation.topbar
    - jquery.foundation.orbit
{% endhighlight %}

We can now build the homepage layout. Since I don't have any images yet, I'm going to use [placehold.it](http://placehold.it). Here is the layout:

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

There is one final thing to do, and that is to activate the 'orbit', which requires adding a script at the end of the document, _after_ our main `app.js` inclusion. The easy way to do this, and to ensure that any other page can use an orbit easily, is to add some metadata to the page which identifies the orbit, and take care of the activation in the default layout:

{% highlight haml %}
---
title: Home
orbit: main-orbit
---
{% endhighlight %}

{% highlight haml %}
    %script{:src => "/assets/app.js" }
    - if item[:orbit]
      :javascript
        $(window).load(function() { $("##{item[:orbit]}").orbit({ animation: 'fade', timer: false, bullets: true}); });
{% endhighlight %}

I'm setting the animation to fade, switching off the automatic start of the slideshow, and adding bullets underneath.

I also want the navigation to only appear on hover, so I'm adding the css for this recommended by Zurb:

{% highlight bash %}
vintageinvite$ subl content/assets/stylesheets/app.scss
{% endhighlight %}

{% highlight scss %}
.orbit-wrapper {
  .slider-nav span { @include opacity(0); @include single-transition(opacity, 400ms); }
  &:hover .slider-nav span { @include opacity(1); }
}
{% endhighlight %}

### Styling the Navigation Links

A minor tweak I want to add, is to highlight the currently active page. All we need to do in theory, is to add a css class of `active` to the active link.
