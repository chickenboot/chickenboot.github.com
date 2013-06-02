---
layout: post
title: Zurb Foundation &amp; nanoc&#58; HTML conditional classes in haml
abstract: Adding conditional classes to the html tag (despite also using Modernizr)
published: true
---

Small post for a change&#151;having had the opportunity to deploy (manually, I'll get onto deployment later) to Amazon's S3, I was able to test the site on a Windows PC with IE8 installed and I noticed it wasn't rendering completely correctly.

### HTML Conditional Comments in Haml

Although we are using Modernizr, which decorates the `html` tag with classes representing the features the current browser supports, the Foundation team still also use the technique blogged about by [Paul Irish]() about [conditional classes](paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/) in their [example markup](http://foundation.zurb.com/old-docs/f3/index.php), so we need to add these to our default template.

{% highlight bash %}
vintageinvite$ subl layouts/default.haml
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.6/layouts/default.haml">layouts/default.haml</a></div>
{% highlight haml %}
!!! 5
/ paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/
/[if lt IE 7 ] <html class="no-js lt-ie9 lt-ie8 lt-ie7" lang="en">
/[if IE 7 ] <html class="no-js lt-ie9 lt-ie8" lang="en">
/[if IE 8 ] <html class="no-js lt-ie9" lang="en">
/[if (gt IE 8)|!(IE)]><! --> <html class="no-js" lang="en"> <!--
%head
...
:plain
  </html>
{% endhighlight %}

We've replaced the `%html` tag with a series of haml commented if statements&#151;haml deals quite elegantly with these conditionals, but we do need to do a tiny tweak for the final conditional. Because we need the final markup to look like the foundation example markup:

{% highlight html %}
<!--[if IE 8]>    <html class="no-js lt-ie9" lang="en"> <![endif]-->
<!--[if gt IE 8]><!--> <html class="no-js" lang="en"> <!--<![endif]-->

{% endhighlight %} 

The haml engine will close the comments and if statements for us automatically, so in order to get the final line looking like the correct markup, we close the comment manually, and reopen it just before the end of the line. Notice that we've added conditionals for browsers older than IE8 too&#151;it's unlikely that these will work out of the box, but we will need to add support for them later, so it's worth adding in while we're there.

Testing this on IE8 shows a big improvement (though it is noticeable that the SVG logo renders poorly in IE8, we will address this later on).
