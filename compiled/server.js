// Generated by CoffeeScript 1.3.3
(function() {
  var app, io, port, requirejs, server, socketio;

  socketio = require('socket.io');

  app = require('../client/webserver').app;

  port = process.env.PORT || 2000;

  server = require('http').createServer(app);

  io = socketio.listen(server);

  server.listen(port);

  try {
    requirejs = require('requirejs');
    requirejs.config({
      baseUrl: 'compiled',
      nodeRequire: require
    });
    requirejs(['nanowar/server'], function(server) {
      server.start(io);
      return console.log("Server running at port " + port);
    });
  } catch (e) {
    console.log("asdf");
    console.log(e.stack);
    console.trace();
  }

}).call(this);
