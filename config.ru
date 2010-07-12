require 'sass/plugin/rack'
Sass::Plugin.options[:css_location] = "." 
Sass::Plugin.options[:template_location] = "."
use Sass::Plugin::Rack


require 'rack/coffee'
use Rack::Coffee, {
    :urls => ['/']
}


puts ">>> Serving: #{Dir.pwd}"
run Rack::Directory.new(Dir.pwd)