---
layout: post
title: Zurb Foundation and nanoc&#58; Building a Blog
abstract: Building a basic blog infrastructure in nanoc, using Markdown
published: true
---

The first thing we're going to get up and running on the site is a blog&#151;because of the incremental way we're starting the business, first and foremost we want to talk about ourselves! 

I've used an excellent resource for [building a static blog with nanoc](http://clarkdave.net/2012/02/building-a-static-blog-with-nanoc/) by [Dave Clark](http://clarkdave.net) to get me started, so I'll be borrowing heavily from his post here.

### Directories and Helpers

We're using a slightly different structure to Dave as our site isn't just a blog&#151;it's just one part of our company site. As such, we're making a subdirectory, imaginatively entitled `blog`, to contain all the blog related files.

{% highlight bash %}
vintageinvite$ mkdir -p content/blog/posts
{% endhighlight %}

Because a blog is a fairly common usage of a static site generator, nanoc ships with some helpers. To use these, we need to add some includes to the `lib` directory. Rather than adding to `default.rb` (as Dave does above), I've gone with creating a new file, `includes.rb`:

{% highlight bash %}
vintageinvite$ subl lib/includes.rb
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.2/lib/includes.rb">lib/includes.rb</a></div>
{% highlight ruby %}
include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::Tagging
include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::LinkTo
{% endhighlight %}

Dave Clark helpfully explains these in his tutorial:

> The `Blogging` helper extends nanoc content items with a few fields such as `title` and `created_at`, and also provides some helper methods to our layouts we can use to list posts.

> The `Tagging` helper lets us add tags to content items and query them.

> The `Rendering` helper lets us use view partials, which allows us to nest layouts (this’ll let us built sub-layouts for posts)

> The `LinkTo` helper lets us construct URLs for other items

`LinkTo` and `Rendering` include helpers that will be familiar to a Rails developer - `link_to` and `render` are frequently used in Rails views.

### Markdown

We still need to add a bit more configuration. The plan for the blog is to allow any of the team to write their own posts&#151;writing in html or haml would be a bit of an ask for the non-technically-minded members (and would still be a pain for the rest of us!). That's why someone invented the *"lightweight markup language"* (or "clever text-to-html converter" as I prefer), and pretty much the de-facto language is [Markdown](http://daringfireball.net/projects/markdown/), so let's add support for that. 

First we add the [kramdown](http://kramdown.rubyforge.org/) gem, which is a library that does the conversion:

{% highlight bash %}
vintageinvite$ subl Gemfile
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.2/Gemfile">Gemfile</a></div>
{% highlight ruby %}
gem 'kramdown'
gem 'listen'
{% endhighlight %}

{% highlight bash %}
vintageinvite$ bundle install
{% endhighlight %}

You'll notice I've also added the *listen* gem, so that I can use the `nanoc watch` command (which keeps an eye on changed files, and compiles them on the fly, so you don't need to continuously `compile` and `view`).

Then we need to tell nanoc that our blog posts should be converted by this library, by adding a compilation rule:

{% highlight bash %}
vintageinvite$ subl Rules
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.2/Rules">Rules</a></div>
{% highlight ruby %}
compile '/blog/posts/*' do
  filter :kramdown
  layout 'default'
end
{% endhighlight %}

Now we can create a post to test it all:

{% highlight bash %}
subl content/blog/posts/2013-05-22-welcome-to-the-blog.md
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.2/content/blog/posts/2013-05-22-welcome-to-the-blog.md">content/blog/posts/2013-05-22-welcome-to-the-blog.md</a></div>
{% highlight haml %}
---
title: "Welcome to the Blog"
created_at: 2013-05-22 09:00:00 +0000
kind: article
---

### Welcome

I will be replaced by a sensical post long before I get published to the web!
{% endhighlight %}

The post starts with the metadata (between the two `---` lines) which we'll be using later (it isn't rendered)&#151;we need the `kind: article` line to tell the nanoc blogging helper that this item should be handled as a blog post.

Now we can compile and view the site, and access our blog post at `/blog/posts/2013-05-22-welcome-to-the-blog/`, and see this:

![Blog Post](/asset/image/2013-05-22/zurb-nanoc-blog-1.png "Blog Post")

### Routes and a Post Template

We can borrow a few more tricks from Dave Clark's tutorial to improve the routes for our blog posts:

{% highlight bash %}
vintageinvite$ subl Rules
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.2/Rules">Rules</a></div>
{% highlight ruby %}
route '/blog/posts/*' do
  y,m,d,slug = /([0-9]+)\-([0-9]+)\-([0-9]+)\-([^\/]+)/.match(item.identifier).captures

  "/blog/#{y}/#{m}/#{slug}/index.html"
end
{% endhighlight %}

This changes the url above (using a [regular expression](http://en.wikipedia.org/wiki/Regular_expression)) to `/blog/posts/2013/05/welcome-to-the-blog/` which is much nicer.

Next on Dave's agenda: we can create a new layout specifically for our blog posts, by creating a new file in the layouts folder.

{% highlight bash %}
vintageinvite$ subl layouts/post.haml
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.2/layouts/post.haml">layouts/post.haml</a></div>
{% highlight haml %}
= render 'default' do
  .post
    %h3= item[:title]
    %aside= "Posted on #{attribute_to_time(item[:created_at]).strftime('%A, %B %-d %Y')}"
    %article= yield
{% endhighlight %}

We're using the default layout (by using the `Nanoc::Helpers::Rendering` helper), and in the content for that, we're putting the title from the metadata in as a header (with `item[:title]`), adding the creation date (processed through the `Nanoc::Helpers::Blogging` method `attribute_to_time`, and pretty-printed using [`strftime`](http://apidock.com/ruby/DateTime/strftime)) and finally yielding the content wrapped in an `article` tag.

All we need to do to use this new layout, is to switch it in the `Rules` file:

{% highlight bash %}
vintageinvite$ subl Rules
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.2/Rules">Rules</a></div>
{% highlight ruby %}
compile '/blog/posts/*' do
  filter :kramdown
  layout 'post'
end
{% endhighlight %}

If you compile and view the blog post now (or are using `nanoc watch`), you'll notice that there are two headers&#151;this is because our post template uses the title as a header, but we still have a header in the post. We'll fix this later when we add some styling and create the blog homepage.