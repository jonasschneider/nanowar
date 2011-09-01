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


app.helpers({
  global_scripts: function() {
    if(process.env.NODE_ENV == 'production')
      return ['code/bundle.js']
    else {
      var script_paths = []
      yoke.processFile('client/src/application.coffee', null, null, {dryRun: true}).forEach(function(dirty) {
        script_paths.push(dirty.replace('client/src', 'code').replace('.coffee', '.js'))
      });
      return script_paths;
    }
  }
});

app.set('views', path.join(__dirname, 'views'))
app.set('view options', {
  layout: false
});

app.get('/code/bundle.js', function(req, res){
  res.contentType('bundle.js');
  
  if(process.env.NODE_ENV == 'production')
    res.send(coffee.compile(yoke.processFile('client/src/application.coffee')))
  else
    res.send('alert("nope")')
});

app.get('/code/:file', function(req, res) {
  if(process.env.ENVIRONMENT != 'production') {
    res.contentType('bundle.js');
    var coffeeFile = req.params.file.replace('.js', '.coffee')
    
    fs.readFile('client/src/'+coffeeFile, function (err, data) { // SECURITY HOLE!!
      if (err) throw err;
      res.send(coffee.compile(data.toString()))
    });
  }
});

app.get('/', function(req, res) {
  res.render('index.haml');
});