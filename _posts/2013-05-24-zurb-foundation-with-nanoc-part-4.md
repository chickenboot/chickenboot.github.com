---
layout: post
title: Zurb Foundation &amp; nanoc&#58; Blog Refinement
abstract: Creating a blog landing page, and building tag handling helpers to refine the blog
published: true
---

Last time we got the basic blog infrastructure in place, but we still need to create a blog landing page, and add support for tags.

### Haml Everywhere

Before we attack the blog, we'll look at our index page. It is currently the default html page shipped with nanoc; let's replace that with a basic holding page in haml until we address the content and layout for the rest of the site. We're going to write the blog landing page in haml too, which means we can change the `Rules` file to reflect that we only need support for haml:

{% highlight bash %}
vintageinvite$ subl Rules
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.3/Rules">Rules</a></div>
{% highlight ruby %}
compile '*' do
  if item.binary?
    # don’t filter binary items
  else
    filter :haml
    layout 'default'
  end
end
{% endhighlight %}

This is just a simple replacement of the `:erb` filter with the `:haml` filter: I know I'm currently not using `:erb` outside of the javascript directory, which has its own compilation rules. 

I've then changed the index page to remove the default copy, and replaced it with a simple header:

{% highlight bash %}
vintageinvite$ mv content/index.html content/index.haml 
vintageinvite$ subl content/index.haml 
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.3/content/index.haml">content/index.haml</a></div>
{% highlight haml %}
---
title: Home
---

%h3 Staging Header
{% endhighlight %}

### Blog Homepage

So back to the blog. It needs its own homepage. The design and layout will be addressed in detail later on, but content-wise it should have the latest posts (or a summary/snippet of them), as well as a list of tags (with links) at the minimum.

All that needs some extra infrastructure work, so to start with I've put together a page with all the stuff I want to be there, to be replaced with real content later:

{% highlight bash %}
vintageinvite$ subl content/blog.haml 
{% endhighlight %}

{% highlight haml %}
---
title: Blog
---

%h2 The Vintage Invite Company Blog

.row
  .ten.columns
    - sorted_articles.each do |article|
      %h3
        = attribute_to_time(article[:created_at]).strftime('%d %B %Y')
        &raquo;
        = link_to article[:title], article.path
      = article.compiled_content
      %hr
  .two.columns
    %h5 Tags
    %ul.no-bullet
      %li Tag 1
      %li Tag 2
      %li Tag 3
{% endhighlight %}

*Note: instead of creating a `blog/index.haml`, I've created a `blog.haml`&#151;because of the way the nanoc routes are set up, the address for both of these will be the same: `/blog/index.html` or just `/blog/`, which is exactly what I want.*

We're using the [Foundation grid](http://foundation.zurb.com/old-docs/f3/grid.php) to create a ten column section for posts and a two column section for the links (nothing special, the real design and layout will happen later). In the main section, each article from the `sorted_articles` collection (which is from [`Nanoc::Helpers::Blogging`](http://nanoc.ws/docs/api/Nanoc/Helpers/Blogging.html)) is being rendered with the date and title as the header, and the full content of the article below.

The navigation on the right hand side is just a placeholder for the tags section that will need more work. And obviously when we have numerous posts, we don't want to display them all&#151;it's also unlikely we'll want to display the full content for each one. But one bit at a time!

### Minor Tweaks

As mentioned in the last article, the `post` template is taking care of the header for each blog post, so before testing out this new page it would be better to tidy up our only post by removing the "Welcome" header:

{% highlight bash %}
vintageinvite$ subl content/blog/posts/2013-05-22-welcome-to-the-blog.md
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.3/content/blog/posts/2013-05-22-welcome-to-the-blog.md">content/blog/posts/2013-05-22-welcome-to-the-blog.md</a></div>
{% highlight haml %}
---
title: "Welcome to the Blog"
created_at: 2013-05-22 09:00:00 +0000
kind: article
tags: [ 'welcome', 'nonsensical' ]
---

I will be replaced by a sensical post long before I get published to the web!
{% endhighlight %}

I've added some (nonsense) tags to the post&#151;notice the syntax, which is that of a Ruby [Array](http://www.ruby-doc.org/core-1.9.3/Array.html) of strings.

We also need a link in our top bar navigation so the blog can be accessed from the home page:

{% highlight bash %}
vintageinvite$ subl layouts/default.haml
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.3/layouts/default.haml">layouts/default.haml</a></div>
{% highlight haml %}
  %section
    %ul.right
      %li
        %a{:href => "/blog/"} Blog
{% endhighlight %}

### Blogging Helpers

The nanoc helpers we're already using are very useful, but aren't extensive enough for us to implement everything we want in the blog landing page. So we're going to add some of our own helper functions to a new file `blog.rb` in the `lib` directory. I've taken inspiration from another excellent resource, Mario Gutierrez's [nanoc3_blog](https://github.com/mgutz/nanoc3_blog) example. 

Let's start by creating a helper function to return all of the tags for a set of pages&#151;to save time/code, this function will also take care of a simple ranking/item count, returning the tags as a `Hash` or array of pairs of tag and item count:

{% highlight bash %}
vintageinvite$ subl lib/blog.rb
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.3/lib/blog.rb">lib/blog.rb</a></div>
{% highlight ruby %}
def all_tags(items = nil, sort = false)
  items ||= @items # default to all items if no items passed
  tags = {}
  items.each do |i|
    (i[:tags] || []).each{|t| tags[t] ||= 0; tags[t] += 1 }
  end
  # if sort is true, sort by item count descending
  sort ? tags.sort {|tl, tr| tr[1] <=> tl[1]} : tags
end
{% endhighlight %}

This function goes through each item, collecting the number of occurrences of each tag into a `Hash`, and then sorts the results (ranking the most common tags highest) if requested.

The more complicated task is to create a landing page for each tag. In a dynamic web application, this would be done on-the-fly, but we need to build all the required pages upfront. Thankfully, this is well supported in nanoc using the preprocessor, which runs before compilation, but after the site data (items, layouts, etc.) has loaded. We're creating a new item for each tag in this section:

{% highlight bash %}
vintageinvite$ subl Rules
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.3/Rules">Rules</a></div>
{% highlight ruby %}
preprocess do
  build_tag_pages(items)
end
{% endhighlight %}

Rather than sully the `Rules` file with the logic to build these pages, we're calling a helper function `build_tag_pages`. Let's look at how that function is defined:

{% highlight bash %}
vintageinvite$ subl lib/blog.rb
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.3/lib/blog.rb">lib/blog.rb</a></div>
{% highlight ruby %}
def build_tag_pages(items)
  all_tags(items).each do |tag,count|
    items << Nanoc3::Item.new(
      "= render('_blog_page', :tag => '#{tag}', :page_title => 'Tag: #{tag}')",
      { :title => "Tag: #{tag}" }, "/blog/tags/#{tag}/", :binary => false )
  end
end
{% endhighlight %}

There's a few things happening in this function&#151;we're calling our helper function `all_tags` and for each tag we're creating a new nanoc item. This item is being defined as a single string, which is calling `render` (from `Nanoc::Helpers::Rendering`) to render a 'partial' page (that we haven't defined yet) called `_blog_page`, passing in the current tag and a title for the page. Note that we're also passing a `Hash` of metadata (with the `:title`) and the route (`/blog/tags/tagname`) to the `Item` initializer.

### The Blog Page Partial

The last thing we need to do is create this `_blog_page` view&#151;for now I want the tag page to look the same as the blog landing page, just with a different title (and obviously only the posts with the given tag shown), so to not repeat ourselves, we can strip out the code from the `blog.haml` above and put that with a few modifications into `_blog_page.haml`:

{% highlight bash %}
vintageinvite$ subl layouts/_blog_page.haml
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.3/layouts/_blog_page.haml">layouts/_blog_page.haml</a></div>
{% highlight haml %}
- posts = defined?(tag) ? items_with_tag(tag) : sorted_articles

%h2= page_title
.row
  .ten.columns
    - posts.each do |article|
      %h3
        = attribute_to_time(article[:created_at]).strftime('%d %B %Y')
        &raquo;
        = link_to article[:title], article.path
      = article.compiled_content
      %hr
  .two.columns
    %h5 Tags
    %ul.no-bullet
      - all_tags(nil, true).each do |t,v|
        %li= link_for_tag(t, '/blog/tags/')
{% endhighlight %}

You'll notice the main changes that have been made: rather than using `sorted_articles` by default, we're using the `Nanoc::Blogging::Tags` helper `items_with_tag` if the local variable `tag` is defined, and the Tags section now has our sorted list of tags as links (using the helper `link_for_tag` helper, where we specify the same base route that we used for building the tag pages).

Finally, we want to replace the code in `blog.haml` with a `render` call to this new view.

{% highlight bash %}
vintageinvite$ subl content/blog.haml
{% endhighlight %}

<div class="code-link">File: <a href="https://github.com/chickenboot/vintageinvite/blob/v1.3/content/blog.haml">content/blog.haml</a></div>
{% highlight haml %}
---
title: Blog
---
= render '_blog_page', :page_title => 'The Vintage Invite Company Blog'
{% endhighlight %}

We aren't passing a `:tag` to this render call, which means that instead of using a tag it will use the `sorted_articles` which is exactly what we want on the landing page.

Finally compiling and viewing this final site gives us:

![Blog Layout](/asset/image/2013-05-24/zurb-nanoc-blog-3.png "Blog Layout")

And clicking on a tag link:

![Clicking a Tag](/asset/image/2013-05-24/zurb-nanoc-blog-4.png "Clicking a Tag")

Not altogether exciting right now, but at least it's working as expected!
