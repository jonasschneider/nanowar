socketio= require('socket.io')

server = require('./client/webserver').app
port = process.env.PORT || 2000

server.listen(port)

io = socketio.listen(server)

io.configure ->
  io.set 'transports', ['websocket', 'xhr-polling']

io.configure 'production', ->
  io.enable('browser client minification')  # send minified client
  io.enable('browser client etag')          ## apply etag caching logic based on version number
  io.set('log level', 1)                    ## reduce logging
  
  io.set('transports', ['xhr-polling'])
  io.set('polling duration', 30)

server = require('./app/server').start(io)

console.log("Server running at port " + port)