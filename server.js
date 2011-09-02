var socketio= require('socket.io')

var server = require('./client/webserver').app
var port = process.env.PORT || 2000;

server.listen(port);

var io = socketio.listen(server);

io.configure(function(){
  io.set('transports', ['websocket']);
  //io.set('transports', ['xhr-polling']);
});

io.configure('production', function(){
  io.enable('browser client minification');  // send minified client
  io.enable('browser client etag');          // apply etag caching logic based on version number
  io.set('log level', 1);                    // reduce logging
  
  io.set('transports', ['xhr-polling']);
  io.set('polling duration', 30);
});




var nanoServer = require('./app-js/server').Server
console.log(nanoServer)




io.sockets.on('connection', function(clientSocket){
  /*var re = /(?:connect.sid\=)[\.\w\%]+/;
  var cookieId = re.exec(client.request.headers.cookie)[0].split('=')[1]
  var clientModel = clients.get(cookieId)


  if (!clientModel) {
    clientModel = new models.ClientModel({id: cookieId});
    clients.add(clientModel);
  }


  // store some useful info
  clientModel.client = client;
*/

  var handler = new nanoServer(clientSocket);

  clientSocket.on('read', function(what, fn) {
    console.log("read req for "+what)
    if(what == '/app')
      fn(handler.obj_to_send)
  })
  
  
  
  
})
  /*

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
*/
console.log("Server running at port " + port)