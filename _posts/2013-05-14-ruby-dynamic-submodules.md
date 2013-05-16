---
layout: default
title: Dynamically Creating Submodules in Ruby
abstract: Creating a nested module if it doesn't already exist
---

Tiny post here about an issue I was having today - I'm creating a simple Ruby class to generate a report that will be used officially as part of a largerproject/framework, but also needs to be useable in a standalone context (for a sort of 'preview' of the output on the client-side, where the final output is created on the server).

It uses a few simple helper methods from the larger project, so I thought the best solution would be to define these methods only if they don't already exist. I could just redefine them in my standalone file, but this way, if the framework definitions change, at least the official output would be correct (though the client-side preview would not).

I started by doing some pointlessly complicated things like:

{% highlight ruby %}
unless Module.const_defined?(:SampleRoot)
  SampleRoot = Module.new do
    SampleChild = Module.new do
      def self.test_method
        puts "Hello"
      end
    end
  end  
end
{% endhighlight %}

But trying to call `SampleRoot::SampleChild.test_method` results in `NameError: uninitialized constant SampleRoot::SampleChild`. 

It turns out I was just being a doofus. This works:

{% highlight ruby %}
unless Module.const_defined?(:SampleRoot)
  module SampleRoot
    module SampleChild
      def self.test_method
        puts "Hello"
      end
    end
  end
end
{% endhighlight %}

Why I thought I couldn't create a module in the normal way inside a statement, I don't know.

