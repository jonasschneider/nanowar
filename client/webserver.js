var coffee  = require('coffee-script'),
    express = require('express'),
    fs      = require('fs'),
    path    = require('path'),
    haml    = require('hamljs'),
    
    yoke    = require('../lib/yoke.js')

exports.app = app = express.createServer();

app.register('.haml', haml);

console.log(__dirname)

app.use(express.static(__dirname + '/public'));

yoke.options.directories = ['app']

function yokeCoffeescript(filename, options) {

  options || (options = {});
  options.bodyProcessor = function(lines) {
    return coffee.compile(lines);
  }
  return yoke.processFile(filename, null, null, options);
}


app.helpers({
  global_scripts: function() {
    if(process.env.NODE_ENV == 'production')
      return ['/app/client.js']
    else {
      var script_paths = []
      yoke.processFile('app/client.coffee', null, null, {dryRun: true}).forEach(function(dirty) {
        script_paths.push(dirty.replace('.coffee', '.js'))
      });
      return script_paths;
    }
  }
});

app.set('views', path.join(__dirname, 'views'))
app.set('view options', {
  layout: false
});

app.get(/(\/app\/.*)/, function(req, res){
  if(req.params[0].indexOf('..') == -1) {
    res.contentType('client.js');
    var jsFile = req.params[0].substring(1)
    
    if(path.existsSync(jsFile)&& fs.statSync(jsFile).isFile()) {
      fs.readFile(jsFile, function (err, data) {
        if (err) throw err;
        res.send(data)
      });
    } else {
      var coffeeFile = jsFile.replace('.js', '.coffee')
      
      if(process.env.NODE_ENV == 'production')
        res.send(yokeCoffeescript(coffeeFile))
      else {
        if (path.existsSync(coffeeFile) && fs.statSync(coffeeFile).isFile()) {
          fs.readFile(coffeeFile, function (err, data) {
            if (err) throw err;
            res.send(coffee.compile(data.toString()))
          });
        } else
          res.send("file not found", 404)
      }
    }
  } else
    res.send("no.")
});


app.get('/', function(req, res) {
  res.render('index.haml');
});