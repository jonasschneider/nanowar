define (require) ->
  App     = require('./Peer')
  util    = require 'util'
  _       = require 'underscore'
  Backbone= require 'backbone'

  class NetworkedPlayer
    constructor: (socket, playerent) ->
      @socket = socket
      @playerent = playerent
      
      @socket.emit 'log', 'You are: ' + @name()
      
      pingSentAt = new Date().getTime()
      @socket.on 'pong', (pingSentAt) => 
        @latency = new Date().getTime() - pingSentAt
        @socket.emit 'log', "Your RTT is #{@latency}"
        console.log @name()+' is ready'
        @trigger 'ready', this
      @socket.emit 'ping', pingSentAt
      
      @socket.on 'update', (e) =>
        @trigger 'update', e
    
    send: ->
      clean = []
      _(arguments).each (arg) ->
        clean.push arg
      
      @socket.emit.apply(@socket, clean)
    name: ->
      @playerent.get('name')
    updateLocalPlayerId: ->
      @socket.emit 'setLocalPlayerId', @playerent.id
  
  _.extend(NetworkedPlayer.prototype, Backbone.Events)

  class Match
    constructor: ->
      @players = []
      
      @app = new App onServer: true
      @game = @app.game
      @app.bind 'publish', @distributeUpdate, this
    
    addPlayer: (clientSocket) ->
      console.log clientSocket.id + " connected"
      playerent = @game.world.spawn 'Player', name: ("Player " + (@players.length + 1))
      console.log "made player ent"
      player = new NetworkedPlayer clientSocket, playerent
      
      player.bind 'update', (e) =>
        #player.socket.broadcast.emit 'update', e # security?
        @app.trigger 'update', e
      
      player.bind 'ready', (player) =>
        @players.push player
        console.log("now #{@players.length} players ready")
        
        if @players.length == 2
          @start()
      
    distributeUpdate: (update) ->
      @sendToAll('update', update)
    
    sendToAll: ->
      clean = []
      _(arguments).each (arg) ->
        clean.push arg
        
      _(@players).each (player) -> # potential problem since we don't use @game.players
        player.send.apply player, clean
    
    start: ->
      @sendToAll 'log', 'starting soon!'
      
      
      console.log 'starting. players:'
      _(@players).each (player) =>
        console.log "- #{player.name()} (socket id #{player.socket.id})"
        
      @game.loadMap()
      snapshot = @game.world.snapshotFull()

      _(@players).each (player) ->
        player.send 'applySnapshot', snapshot
        player.updateLocalPlayerId()
      
      @game.world.enableStrictMode()
      
      @game.bind 'end', (result) =>
        console.log 'Game is over, disconnecting clients'
        result.winner.send 'log', 'You win!'
        result.winner.socket.broadcast.emit 'log', "You lose. :'("
        
        _(@players).each (player) -> # potential problem since we don't use @game.players
          player.send 'log', 'Bye.'
          player.socket.disconnect()
      
      go = =>
        @game.run()
      _(go).delay(1000)
      
      go = =>
        console.log "sending random update"
        @sendToAll 'log', 'sending random update now'
        #c1.set owner: @players[0]
        @game.tellSelf('moveCell')
      _(go).delay(3000)
      
      @onStart()

  return {
    start: (io) ->
      match = null
      fn = =>
        match = new Match
        match.onStart = fn
      
      fn()
      
      io.sockets.on 'connection', (clientSocket) ->
        console.log 'connection'
        match.addPlayer clientSocket
  }