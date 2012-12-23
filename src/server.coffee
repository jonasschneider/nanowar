socketio = require('socket.io')
app = require('../client/webserver').app
port = process.env.PORT || 2000

server = require('http').createServer(app)

io = socketio.listen(server)

server.listen(port)

#io.configure ->
#  io.set 'transports', ['websocket', 'xhr-polling']

#io.configure 'production', ->
#  io.enable('browser client minification')  # send minified client
#  io.enable('browser client etag')          ## apply etag caching logic based on version number
#  io.set('log level', 1)                    ## reduce logging
#  
#  io.set('transports', ['xhr-polling'])
#  io.set('polling duration', 30)

requirejs = require('requirejs');

requirejs.config
  baseUrl: 'compiled'
  nodeRequire: require

requirejs(['dyz/server'], (server) ->
  server.start(io)
#
  console.log("Server running at port " + port)
)