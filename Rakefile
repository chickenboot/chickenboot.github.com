require 'uglifier'
require 'rake/clean'

CLEAN.include('_layouts/*.html', 'index.html', '_site', 'asset/js/app.js', 'asset/css/app.css')

LAYOUT_SRC = FileList.new('_layouts/*.haml', 'index.haml')
COFFEE_SRC = FileList.new('_js/*.coffee')
FOUNDATION = 
[ 
#    'modernizr.foundation', 
    'jquery', 
#    'jquery.foundation.forms',
#    'jquery.foundation.reveal',
#    'jquery.foundation.orbit',
#    'jquery.foundation.navigation',
#    'jquery.foundation.buttons',
#    'jquery.foundation.tabs',
#    'jquery.foundation.tooltips',
#    'jquery.foundation.accordion',
#    'jquery.placeholder',
#    'jquery.foundation.alerts',
    'jquery.foundation.topbar',
#    'jquery.foundation.joyride',
#    'jquery.foundation.clearing',
#    'jquery.foundation.magellan',
#    'jquery.cookie',
#    'jquery.offcanvas',
#    'jquery.event.move',
#    'jquery.event.swipe',
#    'jquery.foundation.mediaQueryToggle'
]

JS = FileList.new(FOUNDATION.collect {|f| "_js/foundation/#{f}.js"}, '_js/*.js')
LAYOUT_HTML = LAYOUT_SRC.ext('html')
LAYOUT = LAYOUT_HTML + COFFEE_SRC
POSTS = FileList.new('_posts/*.md')

rule '.html' => ['.haml'] do |t|
  sh %{ haml -E utf-8 #{t.source} #{t.name.sub(/_haml\./,'.')} }
end

rule '.coffee' => ['.coffee'] do |t|
  sh %{ coffee -c #{t.source} }
end

def concatenate_files(input_files)
  input_files.collect{ |s| IO.read(s) }.join("\n")
end

def minify_js(js_data, output_filename)
  File.open(output_filename, "w") {|out| out.puts Uglifier.compile(js_data) }
end

def pass_through(js_data, output_filename)
  File.open(output_filename, "w") {|out| out.puts js_data }
end

task :build => LAYOUT do
end

task :js => 'asset/js' do
  minify_js(concatenate_files(JS), 'asset/js/app.js')
  #pass_through(concatenate_files(JS), 'asset/js/app.js')
  sh %{ cp _js/foundation/modernizr.foundation.js asset/js }
end

task :css => 'asset/css' do
  sh %{ compass compile -c compass.rb }
end

task :compile do
  system "jekyll --pygments --no-lsi --safe"
end 

task :server do
  system "jekyll --pygments --no-lsi --safe --server --auto"
end

task :default => [:build, :js, :css, :compile]