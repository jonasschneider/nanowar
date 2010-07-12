root=Dir.pwd
puts ">>> Serving: #{root} + Sass"

require 'sass/plugin/rack'


Sass::Plugin.options[:css_location] = "." 
Sass::Plugin.options[:template_location] = "."


use Sass::Plugin::Rack

run Rack::Directory.new(root)