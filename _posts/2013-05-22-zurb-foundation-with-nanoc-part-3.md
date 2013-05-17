---
layout: post
title: Using Zurb Foundation 3 and Nanoc - Part 3
abstract: Building a simple blog
published: false
---

The first thing we're going to get up and running on the site is a blog - because of the incremental way we're starting the business, first and foremost we want to talk about ourselves! 

I've used an excellent resource for [building a static blog with nanoc](http://clarkdave.net/2012/02/building-a-static-blog-with-nanoc/) by [Dave Clark](http://clarkdave.net) to get me started, so I'll be borrowing heavily from his post here.

We're using a slightly different structure as our site will eventually be a full on company site - the blog is only one part. So, we're making a subdirectory, imaginitively entitled `blog` (which will eventually get the `blog` subdomain redirected to it).

{% highlight bash %}
vintaginvite$ mkdir -p content/blog/posts
{% endhighlight %}

We want to reuse the existing nanoc blogging helpers, so we'll add some includes to the `lib` directory - rather than putting it in `default.rb`, I've gone with creating a new file, `includes.rb`:

{% highlight bash %}
vintaginvite$ subl lib/includes.rb
{% endhighlight %}

{% highlight ruby %}
include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::Tagging
include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::LinkTo
{% endhighlight %}

Dave Clark helpfully explains these in his tutorial:

> Thre `Blogging` helper extends nanoc content items with a few fields such as `title` and `created_at`, and also provides some helper methods to our layouts we can use to list posts.

> The `Tagging` helper lets us add tags to content items and query them.

> The `Rendering` helper lets us use view partials, which allows us to nest layouts (this’ll let us built sub-layouts for posts)

> The `LinkTo` helper lets us construct URLs for other items (we’ll use this in our index item to link to multiple posts)

We also need to add a bit more configuration - the plan for this blog is to allow any of the team to write their own posts, which means writing in html or haml would be a bit of an ask for the non-technically-minded members, and also would still be a pain for the rest of us! That's why someone invented the "lightweight markup language" (or "clever text-to-html converter" as I prefer), and pretty much the de-facto standard language is [Markdown](http://daringfireball.net/projects/markdown/), so let's add support for that. First we add the [kramdown](http://kramdown.rubyforge.org/) gem, which is a library that does the conversion:

{% highlight bash %}
vintaginvite$ subl Gemfile
{% endhighlight %}

{% highlight ruby %}
gem 'kramdown'
{% endhighlight %}

{% highlight bash %}
vintaginvite$ bundle install
{% endhighlight %}

Then we need to tell nanoc that our blog posts should be converted by this library:

{% highlight bash %}
vintaginvite$ subl Rules
{% endhighlight %}

{% highlight ruby %}
compile '/blog/posts/*' do
  filter :kramdown
  layout 'default'
end
{% endhighlight %}

Now we can create a post to test it all:

subl content/blog/posts/2013-04-23-welcome-to-the-blog.md

{% highlight ruby %}
---
title: "Welcome to the Blog"
created_at: 2013-04-23 09:00:00 +0000
kind: article
---

### Welcome

I will be replaced by a sensical post long before I get published to the web!
{% endhighlight %}

The post starts with the metadata (between the two `---` lines) which we'll be using later (it isn't rendered automatically) - we need the `kind: article` line to tell the blogging helper that this item should be handled as a blog post.

Now we can compile and view the site, and access our blog post at /blog/posts/2013-04-23-welcome-to-the-blog/.

We can borrow a few more tricks from Dave Clark's tutorial to first improve the routes for our blog posts:

{% highlight bash %}
vintageinvite$ subl Rules
{% endhighlight %}

{% highlight ruby %}
route '/blog/posts/*' do
  y,m,d,slug = /([0-9]+)\-([0-9]+)\-([0-9]+)\-([^\/]+)/.match(item.identifier).captures

  "/blog/#{y}/#{m}/#{slug}/index.html"
end
{% endhighlight %}

This changes the url we used above to /blog/posts/2013/04/welcome-to-the-blog/ which is much nicer.

Now we can also create a separate post layout specifically for blog posts:

{% highlight bash %}
vintageinvite$ subl layouts/post.haml
{% endhighlight %}

{% highlight haml %}
= render 'default' do
  .post
    %h3= item[:title]
    %aside= "Posted on #{attribute_to_time(item[:created_at]).strftime('%A, %B %-d %Y')}"
    %article= yield
{% endhighlight %}

