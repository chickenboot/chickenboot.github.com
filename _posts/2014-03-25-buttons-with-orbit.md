---
layout: post
title: Link Issues With Foundation 5 Orbit
abstract: Fixing unclickable links and buttons in the Foundation Orbit captions
published: true
---

A quick post. I'm using Foundation 5 for some of my recent projects (I will try and write about them more when I get time!) and thought I'd share something that wasn't completely obvious to fix.

I've been having a few issues with a quickly knocked together website for my friends at [Global Innovation Magazine](http://www.globalinnovationmagazine.com). I wanted to use the orbit slider as a simple marketing device to show some of the main content of the magazine, but also have a button linking to the magazine itself on each slide.

To achieve this I customised the orbit captions, adding a styled button link to them. However, this didn't quite work as I wanted. Clicking on certain links just progressed the slideshow, rather than following the link. Very annoying.

Inspecting in Chrome's developer tools showed that while I was right clicking on the caption button on slide 1, I was inspecting the image on slide 4. This is possibly because I'm using image fades rather than a slider&ndash;the images are all stacked on top of each other as far as I can tell, with the opacity being transitioned when you advance.

In order to fix this problem (that I may well be unique in having!) I tweaked the `z-index` by adding a custom css rule (_after_ the foundation css) for active and inactive slides:

{% highlight css %}
.orbit-container .orbit-slides-container.fade>* {
  z-index: -1;
}

.orbit-container .orbit-slides-container > *.active {
  z-index: 1;
}
{% endhighlight %}

This ensures that any elements inside the orbit container default to being at the back, and active elements are always in front.
