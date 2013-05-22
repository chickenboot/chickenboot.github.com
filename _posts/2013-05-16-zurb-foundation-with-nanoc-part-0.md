---
layout: post
title: Building a company website with Foundation 3 and nanoc
abstract: An introduction to a series on building a company site with Zurb's Foundation and the static site generator nanoc
published: true 
---

I thought I'd start the meat of my technical blog with a long, drawn-out, potentially dull series on how I'm setting up a simple site for a company I'm part of: [The Vintage Invite Company](http://www.thevintageinvite.com). I hoped it might prove useful for any fellow non-web-specialist hackers, and also motivate me to get it done in the _right_ way (I would normally just hack it together, but being forced to try and explain things means I will have to think about it more!).

I decided to build this site using (**[Zurb Foundation](http://foundation.zurb.com/)** referred to as "Foundation" from hereon to save me typing) as a responsive front-end framework, and **[nanoc](http://nanoc.ws/)** to generate the static content. Eventually we plan to build a storefront, but to start with we just want a web presence, and a static site allows us to do that in a quick and cost effective way.

While there is already plenty of excellent material on this subject out there, a lot tend to focus on specific aspects of nanoc or Foundation&#151;I'm hoping to put together something that shows the whole process of building a site from scratch.

### Why Foundation (and not [Bootstrap](http://twitter.github.io/bootstrap/)?)

![Foundation 3](/asset/image/2013-05-16/zurb-yeti.png "Zurb zurb zurb, zurb's the word...")

The first question I guess is: why use a framework at all? Well, I'm a bad css developer. I tend to butcher away at css without looking at the bigger picture when I'm forced to start from scratch. Using a framework takes away most of the pain, has been tested far more than I would even know was possible, and makes things look good right away!

I had a long (OK, not that long) look at both frameworks for a Rails application I developed (that needed a responsive element)&#151;I started with Bootstrap because it looks great and is really easy to use, but decided to try out Zurb after having a bit of a frustrating time trying to customise the default look-and-feel, and override things. It didn't help that I only have space for one stylesheet language in my brain, and that wasn't *[LESS](http://lesscss.org/)*.

My humble opinion is that if you are a relative newbie to web development (or on the other hand, if you're an expert that can quickly figure out how to customise it) then Bootstrap is perfect. If you are like me, and a reluctant web developer (that nonetheless knows what you can achieve with just the right amount of hackery), then Foundation is ideal. It allows me to easily tweak and override many styles and colours without changing any of the actual css, and adding new stuff in the same vein is also straightforward. And it uses [Sass](http://sass-lang.com/) which is the first stylesheet language (outside of css) that I heard of, so it's obviously my favourite.

Another benefit for me was the fact it is easily managed via [RubyGems](http://rubygems.org/) (and the gem is maintained by Zurb themselves), so I can use the bundler to manage all of my dependencies, which should mean that upgrades and maintenance should be more straightforward.

### Why nanoc?

Same question first up: why a static website generator at all? How else would you do it? Manually maintaining each page on the site with the right header navigation and all the other static elements? I didn't want to create a whole dynamic web application just for a simple site, so this seemed like the best solution (I am always open to alternatives though, which is not so good for my time management).

I actually started my project using [Jekyll](https://github.com/mojombo/jekyll), which is the de-facto static site generator for blogs. It is great for blogging (hence its usage for this blog), but like with Bootstrap, I found it difficult to figure out how to do some of the more complicated things for the site that didn't just follow the blog pattern.

I then heard about nanoc (on a [Hacker News](http://news.ycombinator.com) thread), and it has so far been the perfect tool for me so far. It's not quite as easy as Jekyll to get started with, but with the right documentation and a bit of Ruby knowledge (which I thankfully possess) it has just the right amount of flexibility and simplicity.

Enough rambling. The next post will actually cover getting started.
