var static = require("node-static"), http = require("http");
var clientFiles = new static.Server('./client');

var httpServer = http.createServer(function(request, response) {
    request.addListener('end', function () {
        clientFiles.serve(request, response);
    });
});

var port = process.env.PORT || 2000;
httpServer.listen(port);

var io = require('socket.io').listen(httpServer);

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