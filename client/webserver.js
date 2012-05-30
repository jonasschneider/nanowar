var express = require('express'),
    fs      = require('fs'),
    path    = require('path'),
    haml    = require('haml')

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

var main = haml(fs.readFileSync('client/views/index.haml', 'utf8'));

app.get('/', function(req, res) {
  res.send(main());
});