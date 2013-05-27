---
layout: post
title: Zurb Foundation &amp; nanoc&#58; A Homemade Top Bar
abstract: Building a simple custom top bar, using an SVG logo with a PNG version as a fallback
published: true
---

The site is now getting to a stage where it is almost ready to hand over to the more design-minded in the company, but I need to make the layout a little more respectable before I can do that.

### A New Top Bar

The Foundation top bar is a great piece of engineering. It works well with a text or text-sized logo, but sadly it's not completely compatible with our logo. We need our logo to be at least 100 pixels high, and if you force the Foundation top bar to be at least that height, it wastes a lot of space, especially when you expand the menu on a mobile. 

So, we'll be making a simple top bar of our own. Let's assume that it's there already, and update the layout accordingly:

{% highlight bash %}
vintageinvite$ subl layouts/default.haml
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.4/layouts/default.haml">layouts/default.haml</a></div>
{% highlight haml %}
  %body
    .row
      .vic-topbar
        .four.columns
          %a{:href => "/"}
            %img{:src => "/assets/logo.svg", :title => "The Vintage Invite Company"}
        .eight.columns
          %ul.right
            %li
              %a{:href => "/blog/"} Blog
            %li
              %a{:href => "#"} Contact
{% endhighlight %}

We're adding a class of `.vic-topbar` inside the first row, and separating it into four columns for the logo and eight for the list of navigation links (the Foundation responsive grid means that this will put the logo above the navigation links automatically on a mobile). We still want the navigation to be right aligned, so we leave in the `right` class.

Let's do some of this styling now&#151;starting with updating the Foundation settings file:

{% highlight bash %}
vintageinvite$ subl content/assets/stylesheets/_settings.scss
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.4/content/assets/stylesheets/_settings.scss">content/assets/stylesheets/_settings.scss</a></div>
{% highlight scss %}
// Media Queries

$screenSmall: 768px !default;
$screenMedium: 1279px !default;
$screenXlarge: 1441px !default;
{% endhighlight %}

These are just taken from the foundation gem&#151;these parameters aren't exposed in your local `_settings.scss` by default (you can find the location of this using `bundle show zurb-foundation`, and this file is in `scss/foundation/`), but we need them to make our `.vic-topbar` responsive.

Next up we make a new stylesheet called `custom.scss`:

{% highlight bash %}
vintageinvite$ subl content/assets/stylesheets/custom.scss
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.4/content/assets/stylesheets/custom.scss">content/assets/stylesheets/custom.scss</a></div>
{% highlight scss %}
@import "settings";

$vicLogoMainColor: #e966a6;
$vicLogoSecondaryColor: #9ad5c4;

.vic-topbar { min-height: 120px; margin: 15px 0 20px 0;
  @media screen and (max-width: $screenSmall - 1) { text-align: center; }
  a img { margin-top: 5px; max-height: 200px;
    @media screen and (min-width: $screenSmall) { max-width: 200px;}
  }
  ul { list-style: none; margin-top: 45px;
    @media screen and (max-width: $screenSmall - 1) {
      display: inline-block;
    }
    li { float: left; padding: 0 15px; font-size: 20px; font-weight: bold;
      a { color: $vicLogoMainColor; }
      &:hover, &.active, &:focus {
        a, & { color: $vicLogoSecondaryColor; }
      }
    }
  }
}
{% endhighlight %}

If it looks a bit funky for a stylesheet (plus it has a different extension), it's because it's using [Sass](http://sass-lang.com/). Also it's quite possibly because my css is somewhat rusty... Anyway, we're starting by including the settings file for the `$screenSmall` variable, making the colours from the logo into sass variables, and then copying some of the logic from the Foundation top bar for our use. We set up a minimum height (to ensure the logo stays proud), and then setup the unordered list so that it displays the navigation links in a row with suitable spacing, and using the colours of the logo.

The responsive part does two things: it restricts the width of the logo for desktop viewing, and it centers the navigation for mobile viewing (by using the technique in the second answer [here](http://stackoverflow.com/questions/1708054/center-ul-li-into-div)).

Finally we need to import this stylesheet into the main `app.scss`:

{% highlight bash %}
vintageinvite$ subl content/assets/stylesheets/app.scss
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.4/content/assets/stylesheets/app.scss">content/assets/stylesheets/app.scss</a></div>
{% highlight scss %}
@import "foundation";

@import "custom";
{% endhighlight %}

### Logo Assets

Before testing this, we obviously need to add the logo to our assets directory. I've decided to use a vector image format for the logo so that it scales up nicely for retina displays, and down nicely on mobiles, and `svg` is [well supported](http://caniuse.com/#feat=svg-img) across _most_ browsers. My friendly designer provided me with an svg version of our logo, which I copied into `content/assets/images` and edited (in a text editor; it is just an xml document) to remove the fixed `width` and `height` attributes whilst keeping the `viewBox` attribute to ensure the image scales correctly. We haven't yet got a route for our images in our Rules file so let's add that:

{% highlight bash %}
vintageinvite$ subl Rules
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.4/Rules">Rules</a></div>
{% highlight ruby %}
route '/assets/images/*' do
  item.identifier.sub(/\/images/,'') + '.' + item[:extension]
end
{% endhighlight %}

This is flattening the images into the `assets` folder, but maintaining the subdirectory structure (for Foundation images).

### Falling Back to PNG

In order to cope with the browsers that don't understand svg (we very sadly can't expect all of our customers to have escaped from IE8 or below), I'm borrowing a trick from [Todd Motto](http://toddmotto.com). His article on [png fallbacks](http://toddmotto.com/mastering-svg-use-for-a-retina-web-fallbacks-with-png-script/) has a very simple solution if you are using jQuery and Modernizr (which we are already, via Foundation):

{% highlight bash %}
vintageinvite$ subl content/assets/javascripts/app.js
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.4/content/assets/javascripts/app.js">content/assets/javascripts/app.js</a></div>
{% highlight js %}
if (!Modernizr.svg) {
  $('img[src*="svg"]').attr('src', function() {
    return $(this).attr('src').replace('.svg', '.png');
  });
}
{% endhighlight %}

This handily replaces our `logo.svg` with `logo.png` for non-svg compliant browsers (we're in real trouble if the browser also doesn't support javascript though, I would think). Of course, to make this work, we need to add a `logo.png`. The only reason this is interesting to write about, is that nanoc doesn't support having two files with the same name and different identifiers&#151;trying to compile the site with both a `logo.png` and `logo.svg` produces this error message:

{% highlight bash %}
RuntimeError: Found 2 content files for content/assets/images/logo; expected 0 or 1
{% endhighlight %}

There are ways around this, described in the nanoc [troubleshooting](http://nanoc.ws/docs/troubleshooting/) guide. Creating a static asset source is a bit too much effort for me, so I've gone with one of the other solutions. Some of the Foundation images contain a dash (which is used as a separator in the solution I want to use), so I'm going to just suffix the identifier with an underscore, and have the images route remove any trailing underscores:

{% highlight bash %}
vintageinvite$ mv content/assets/images/logo.png content/assets/images/logo_.png
vintageinvite$ subl Rules
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.4/Rules">Rules</a></div>
{% highlight ruby %}
route '/assets/images/*' do
  item.identifier.sub(/\/images/,'').chop.sub(/_+$/, '') + '.' + item[:extension]
end
{% endhighlight %}

Finally, if we compile and view the site now, we get the following for the homepage at desktop size:

![Desktop View of New Nav](/asset/image/2013-05-27/zurb-nanoc-nav-desktop.png "Desktop View of New Nav")

And the mobile view:

![Mobile View of New Nav](/asset/image/2013-05-27/zurb-nanoc-nav-mobile.png "Mobile View of New Nav")

Almost there! In the next post we'll look at making the homepage a little more than just a heading!
