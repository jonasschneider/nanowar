var express = require('express'),
    fs      = require('fs'),
    path    = require('path'),
    haml    = require('haml'),
    coffee  = require('coffee-script')

exports.app = app = express.createServer();

app.use(express.static(__dirname + '/public'));

app.set('views', path.join(__dirname, 'views'))
app.set('view options', {
  layout: false
});

app.get(/(\/src\/.*)/, function(req, res){
  reqpath = req.params[0].replace('src', 'compiled')
  if(reqpath.indexOf('..') == -1) {
    res.contentType('client.js');
    var jsFile = reqpath.substring(1)
    
    if(path.existsSync(jsFile)&& fs.statSync(jsFile).isFile()) {
      fs.readFile(jsFile, function (err, data) {
        if (err) throw err;
        res.send(data)
      });
    } else {
      res.send("file not found", 404)
    }
  } else
    res.send("no.")
});



app.get('/', function(req, res) {
  res.send(haml(fs.readFileSync('client/views/index.haml', 'utf8'))())
});



app.get('/specs.html', function(req, res) {
  var util = require('util'),
    exec = require('child_process').exec,
    child;

  child = exec('find spec/ -type f |grep .spec.coffee',
    function (error, stdout, stderr) {
      console.log('stdout: ' + stdout);
      console.log('stderr: ' + stderr);
      specs = stdout.split("\n")
      res.send(haml(fs.readFileSync('client/views/specs.haml', 'utf8'), {specs: specs})())
  });
  
});

app.get(/(\/lib\/.*)/, function(req, res){
  reqpath = req.params[0]
  if(reqpath.indexOf('..') == -1) {
    var jsFile = reqpath.substring(1)
    res.contentType(jsFile);
    
    if(path.existsSync(jsFile)&& fs.statSync(jsFile).isFile()) {
      fs.readFile(jsFile, function (err, data) {
        if (err) throw err;
        res.send(data)
      });
    } else {
      res.send("file not found", 404)
    }
  } else
    res.send("no.")
});

app.get(/(\/spec\/.*)/, function(req, res){
  reqpath = req.params[0]
  if(reqpath.indexOf('..') == -1) {
    var elems = reqpath.split('/')
    res.contentType(elems[elems.length-1]);
    var jsFile = reqpath.substring(1).replace('.js', '.coffee')
    
    
    if(path.existsSync(jsFile)&& fs.statSync(jsFile).isFile()) {
      fs.readFile(jsFile, function (err, data) {
        if (err) throw err;
        res.send(coffee.compile(data.toString()))
      });
    } else {
      res.send("file not found", 404)
    }
  } else
    res.send("no.")
});