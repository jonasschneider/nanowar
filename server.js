var coffee  = require('coffee-script'),
    express = require('express'),
    io      = require('socket.io'),
    
    yoke    = require('./lib/yoke.js')


var app = express.createServer();

app.use(express.static(__dirname + '/client/public'));

app.get('/code/application.js', function(req, res){
  res.contentType('application.js');
  res.send(coffee.compile(yoke.processFile('client/src/application.coffee')))
});

var port = process.env.PORT || 2000;
app.listen(port);



io.listen(app);

io.sockets.on('connection', function(client) {
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