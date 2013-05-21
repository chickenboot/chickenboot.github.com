---
layout: post
title: Using Zurb Foundation 3 and nanoc (4)
abstract: Foundation and nanoc Part 4&#58; More Blogging
published: false
---

Last time we got the basic blog infrastructure in place, but we still need to create a blog landing page, and add some basic styling to the blog posts.

### Haml Everywhere

Our index page is still the default html page shipped with nanoc. I'm going to replace that with a simple holding page in haml until we address the content for the site's root, and there's going to be a new blog landing page in haml too.

In order to get these pages to compile correctly, the `Rules` file needs a minor tweak:

{% highlight bash %}
vintageinvite$ subl Rules
{% endhighlight %}

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

I've just replaced the `:erb` filter with the `:haml` filter, as I know I'm currently not using `:erb` outside of the javascript directory which has its own compilation rules. 

I've then changed the index page:

{% highlight bash %}
vintageinvite$ mv content/index.html content/index.haml 
vintageinvite$ subl content/index.haml 
{% endhighlight %}

{% highlight haml %}
---
title: Home
---

%h3 Staging Header
{% endhighlight %}

### Blog Homepage

The blog needs its own homepage. The design and layout will be addressed in detail later on, but content-wise it should have the latest posts (or a summary/snippet of them), as well as a list of tag links, and date categories.

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

Because of the way the nanoc `Rules` file is routing, the address for this file will be `/blog/index.html` or just `/blog/`, which is exactly where we want it.

We're using the [Foundation grid](http://foundation.zurb.com/old-docs/f3/grid.php) to create a ten column section for posts and a two column section for the links. In the main section, each article from the `sorted_articles` collection (which is a function in the nanoc [Blogging](http://nanoc.ws/docs/api/Nanoc/Helpers/Blogging.html) helper) is being rendered with the date and title as the header, and the full content of the article below.

The navigation on the right hand side is just a placeholder for the tags section that will need more work.

### Minor Tweaks

As mentioned in the last post, the `post` template is taking care of the header for each blog post, so before testing out this new page it would be better to tidy up our only post by removing the "Welcome" header:

{% highlight haml %}
---
title: "Welcome to the Blog"
created_at: 2013-05-22 09:00:00 +0000
kind: article
---

I will be replaced by a sensical post long before I get published to the web!
{% endhighlight %}

We also need a link in our top bar navigation so the blog can be accessed from the home page:

{% highlight haml %}
  %section
    %ul.right
      %li
        %a{:href => "/blog/"} Blog
{% endhighlight %}

### Blogging Helpers

The nanoc helpers we're already using are great, but aren't extensive enough for us to implement the blog landing page. So we're going to add some helper functions to a new file `blog.rb` in the `lib` directory. For this, I've taken inspiration from another excellent resource, Mario Gutierrez's (nanoc3_blog)[https://github.com/mgutz/nanoc3_blog] example. 

Let's start by creating a helper function to return all of the tags for a set of pages - to save time, this function will also take care of a simple ranking/item count, returning the tags as a `Hash` of `tag => item_count`:

{% highlight ruby %}
def all_tags(items = nil, sort = false)
  items ||= @items
  tags = {}
  items.each do |i|
    (i[:tags] || []).each{|t| tags[t] ||= 0; tags[t] += 1 }
  end
  sort ? tags.sort {|tl, tr| tl[1] <=> tr[1]} : tags
end
{% endhighlight %}

This function goes through each item (either the passed in items, or the global all items) collecting the number of occurrences of each tag into a Hash.

The next thing we need to do is create a landing page for each tag, so that when a user clicks a tag link, they get a list of all items with that tag. Because these landing pages will be similar to the blog homepage, I'm going to make a partial from the homepage template:

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

We've just taken the `blog.haml` file from earlier, and changed the source of the posts from `sorted_articles` to the nanoc helper function `items_with_tag` if there's a tag passed in, otherwise we default to all the articles as before. The other variable used is `page_title`, which the partial expects to have passed in. I've also filled in the Tags section with a list of sorted tag links.

We can remove this duplicate code from `blog.haml` now, and replace it with:

{% highlight haml %}
---
title: Blog
---
= render '_blog_page', :page_title => 'The Vintage Invite Company Blog'

{% endhighlight %}

The final step is to generate these tag pages. We can do this in the nanoc preprocessort