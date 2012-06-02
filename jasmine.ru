require 'sinatra'
require 'coffee-script'

set :public_folder, File.dirname(__FILE__)

get '/' do
  erb :index
end

get "/*.js" do
  content_type "text/javascript"
  coffee File.read(request.path[1..-1].gsub('.js', '.coffee'))
end


run Sinatra::Application

__END__

@@ index

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
  "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title>Jasmine Spec Runner</title>

  <link rel="shortcut icon" type="image/png" href="lib/jasmine-1.2.0/jasmine_favicon.png">
  <link rel="stylesheet" type="text/css" href="lib/jasmine-1.2.0/jasmine.css">
  <script type="text/javascript" src="lib/jasmine-1.2.0/jasmine.js"></script>
  <script type="text/javascript" src="lib/jasmine-1.2.0/jasmine-html.js"></script>

  <!-- include source files here... -->
  <script type="text/javascript" data-main="src/require.js" src="src/require.js"></script>

  <script>
    requirejs.config({
      //By default load any module IDs from js/lib
      baseUrl: 'src',
      
      paths: {
          "jquery": "http://ajax.googleapis.com/ajax/libs/jquery/1.7.0/jquery.min"
      }
    })

  </script>
  
  <!-- include spec files here... -->
  <% `find spec/ -type f |grep .spec.coffee`.lines.each do |s| %>
    <script type="text/javascript" src="<%= s.strip.gsub('.coffee', '.js') %>"></script>
  <% end %>
  
  <script type="text/javascript">
    (function() {
      var jasmineEnv = jasmine.getEnv();
      jasmineEnv.updateInterval = 1000;

      var htmlReporter = new jasmine.HtmlReporter();

      jasmineEnv.addReporter(htmlReporter);

      jasmineEnv.specFilter = function(spec) {
        return htmlReporter.specFilter(spec);
      };

      var currentWindowOnload = window.onload;

      window.onload = function() {
        if (currentWindowOnload) {
          currentWindowOnload();
        }
        execJasmine();
      };

      function execJasmine() {
        jasmineEnv.execute();
      }

    })();
  </script>

</head>

<body>
</body>
</html>
