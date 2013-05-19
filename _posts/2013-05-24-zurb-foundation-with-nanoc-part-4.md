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
    %h5 Archives
    %ul.no-bullet
      %li May 2013
{% endhighlight %}

Because of the way the nanoc `Rules` file is routing, the address for this file will be `/blog/index.html` or just `/blog/`, which is exactly where we want it.

We're using the [Foundation grid](http://foundation.zurb.com/old-docs/f3/grid.php) to create a ten column section for posts and a two column section for the links. In the main section, each article from the `sorted_articles` collection (which is a function in the nanoc [Blogging](http://nanoc.ws/docs/api/Nanoc/Helpers/Blogging.html) helper) is being rendered with the date and title as the header, and the full content of the article below.

The navigation on the right hand side is just a placeholder for the tags and archive sections that will need more work.

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


