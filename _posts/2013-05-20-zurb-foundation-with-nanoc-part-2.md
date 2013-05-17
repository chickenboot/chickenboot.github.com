---
layout: post
title: Using Zurb Foundation 3 and Nanoc - Part 2
abstract: Adding javascripts for a responsive top bar
published: false
---

The final vintage invite company site should be rich and responsive (meaning it plays nicely across many devices). To start the ball rolling, we will look at the steps required to make the top/menu bar nav responsive, using the foundation javascripts.

### Concatenating and Minifying

We first need to tell nanoc (in `nanoc.yaml`) to allow a `.` in an identifier, because many of the foundation javascripts are named `jquery.foundation.$function` (otherwise it will `fixme`).

While we're in the config file, I'm going to create a new config variable to indicate which javascripts should be 'compiled' (concatenated), and which should be just passed through to the output directory:

{% highlight bash %}
vintageinvite$ subl nanoc.yaml
{% endhighlight %}

{% highlight yaml %}
allow_periods_in_identifiers: true

javascripts:
  compile:
    - jquery
    - jquery.foundation.topbar
  passthrough:
    - modernizr.foundation
    - app
{% endhighlight %}

We're just including jquery and the Foundation topbar for now, and passing through `modernizr.foundation` so we can include that separately in the `<head>`. We're also passing through `app` - which doesn't exist yet, but is going to be the placeholder file where the concatenated javascript will live. 

In order to combine the necessary javascript, we're going to create a Ruby function which takes a list of filenames and returns a string of the combined data. This will live in the `lib` directory - all files in here are picked up by nanoc before compilation:

{% highlight bash %}
vintageinvite$ subl lib/concat_files.rb
{% endhighlight %}

{% highlight ruby %}
def concat_files(files)
  files.collect do |f|
    item = @items.find {|i| i.identifier =~ /#{f}\/$/}
    if item
      item.compiled_content
    else
      puts "WARNING: couldn't find file #{f}"
    end
  end.compact.join("\n")
end
{% endhighlight %}

Now that we have this function, we can use an erb template for our `app.js` file:

{% highlight bash %}
vintageinvite$ subl content/assets/javascripts/app.js
{% endhighlight %}

{% highlight erb %}
<%= concat_files(@config[:javascripts][:compile]) %>

$(document).ready(function () {
    $(document).foundationTopBar();
})

{% endhighlight %}

The erb at the top will be replaced with all the concatenated javascript, and then we finally enable the top bar when the document is ready (I have forgotten this before and spent far too long figuring out what I've done wrong...).

In order to minify the combined javascript, we're going to use the _uglifier_ gem, so we'll add that to our `Gemfile`:

{% highlight bash %}
vintageinvite$ subl Gemfile
{% endhighlight %}

{% highlight ruby %}
gem 'uglifier'
{% endhighlight %}

And now we just need to put it all together in the Rules file:

{% highlight bash %}
vintageinvite$ subl Rules
{% endhighlight bash %}

{% highlight ruby %}
compile '/assets/javascripts/*' do
  filter :erb
  filter :uglify_js if @config[:javascripts][:passthrough].include?(File.basename(item.identifier))
end

route '/assets/javascripts/*' do
  filename = File.basename(item.identifier)
  '/assets/' + filename + '.js' if @config[:javascripts][:passthrough].include?(filename)
end

{% endhighlight %}

Now if we compile and view the site, we should get a lovely responsive top bar.
