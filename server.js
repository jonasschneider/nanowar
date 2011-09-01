var static = require("node-static"), http = require("http"), yoke = require('./yoke.js'), coffee = require('coffee-script');

var express = require('express');

var app = express.createServer();
  
app.use(express.static(__dirname + '/client/public'));

app.get('/code/application.js', function(req, res){
  res.contentType('application.js');
  res.send(coffee.compile(yoke.processFile('client/src/application.coffee')))
});

var port = process.env.PORT || 2000;
app.listen(port);

var io = require('socket.io').listen(app);

io.sockets.on('connection', function(client) {
    console.log("new client")
    client.send('Please enter a user name ...');
    
    client.emit('ping', new Date().getTime())

    var userName;
    
    client.on('pong', function(time) {
      var ping = new Date().getTime() - time;
      client.send("Your ping is "+ping)
    })
    
    client.on('message', function(message) {
        if(!userName) {
            userName = message;
            client.broadcast.send(message + ' has entered the zone.');
            client.send(message + ' has entered the zone.');
            return;
        }

        var broadcastMessage = userName + ': ' + message;
        client.broadcast.send(broadcastMessage);
        client.send(broadcastMessage);
    });

    client.on('disconnect', function() {
        var broadcastMessage = userName + ' has left the zone.';
        client.broadcast.send(broadcastMessage);
        client.send(broadcastMessage);
    });
});

console.log("running")