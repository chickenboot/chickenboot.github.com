LAYOUT_SRC = FileList.new('_layouts/*.haml', 'index.haml')
COFFEE_SRC = FileList.new('_js/*.coffee')
JS = FileList.new('_js/*.js', '_js/foundation/*.js')
LAYOUT_HTML = LAYOUT_SRC.ext('html')
LAYOUT = LAYOUT_HTML + COFFEE_SRC
POSTS = FileList.new('_posts/*.md')

rule '.html' => ['.haml'] do |t|
  sh %{ haml -E utf-8 #{t.source} #{t.name.sub(/_haml\./,'.')} }
end

rule '.coffee' => ['.coffee'] do |t|
  sh %{ coffee -c #{t.source} }
end

def concatenate_files(output_filename, input_files)
  File.open(output_filename, "a+") do |out|
    out.puts input_files.map{ |s| IO.read(s)}
  end
end

task :build => LAYOUT do
end

task :js => 'asset/js' do
  concatenate_files('asset/js/app.js', JS)
end

task :css => 'asset/css' do
  sh %{ compass compile -c compass.rb }
end

task :default => [:build, :js, :css]