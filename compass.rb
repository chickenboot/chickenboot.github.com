require "zurb-foundation"

# -----------------------------------------------
# Paths
# -----------------------------------------------

http_path = "/"
css_dir = "asset/css"
images_dir = "asset/image"
javascripts_dir = "asset/js"
sass_dir = "_sass"

# -----------------------------------------------
# Output
# -----------------------------------------------

output_style = :compressed
preferred_syntax = :sass
relative_assets = true

# -----------------------------------------------
# haml watcher
# -----------------------------------------------
watch "#{File.dirname(__FILE__)}/**/haml/*.haml" do |project_dir, relative_path|
  if File.exists?(File.join(project_dir, relative_path))    
    target = File.join(project_dir, relative_path.gsub('haml/','').gsub('.haml', '.html'))
    source = File.join(project_dir, relative_path)
    puts "Generating #{target} from #{source}"
    `bundle exec haml #{File.join(project_dir, relative_path)} #{target}`
  end
end
