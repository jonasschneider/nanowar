define (require) ->
  App     = require('./models/App')
  Player  = require('./models/Player')
  Cell    = require('./models/Cell')
  EnhancerNode    = require('./models/EnhancerNode')
  util    = require 'util'
  _       = require 'underscore'

  class NetworkedPlayer extends Player
    anonymousSubclass: true
    
    initialize: ->
      @socket = @get('socket')
      @unset 'socket'
      
      @socket.emit 'log', 'You are: ' + JSON.stringify(this)
      
      pingSentAt = new Date().getTime()
      @socket.on 'pong', (pingSentAt) => 
        @latency = new Date().getTime() - pingSentAt
        @socket.emit 'log', "Your RTT is #{@latency}"
        console.log @get('name')+' is ready'
        @trigger 'ready', this
      @socket.emit 'ping', pingSentAt
      
      @socket.on 'update', (e) =>
        @trigger 'update', e
    
    send: ->
      clean = []
      _(arguments).each (arg) ->
        clean.push arg
      
      @socket.emit.apply(@socket, clean)
      
    updateLocalPlayerId: ->
      @socket.emit 'setLocalPlayerId', this.id

  class Match
    constructor: ->
      @players = []
      
      @app = new App onServer: true
      @game = @app.game
      @app.bind 'publish', @distributeUpdate, this
      
    addPlayer: (clientSocket) ->
      console.log clientSocket.id + " connected"
      player = new NetworkedPlayer socket: clientSocket, name: ("Player " + (@players.length + 1)), game: @game
      
      player.bind 'update', (e) =>
        #player.socket.broadcast.emit 'update', e # security?
        @app.trigger 'update', e
      
      player.bind 'ready', (player) =>
        @players.push player
        console.log("now #{JSON.stringify(@players)} ready")
        
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
        @game.tellSelf 'addPlayer', player
        console.log "- #{player.get('name')} (#{player.socket.id})"
        
      
      @game.tellSelf 'loadMap'

      #@game.runTellQueue()

      @game.updateAndPublish()

      p.updateLocalPlayerId() for p in @players
      
      #@sendToAll 'runTellQueue' # hackish, to get the player entities to the clients so we can updateLocalPlayer()

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
      match = new Match
      
      fn = =>
        match = new Match
        match.onStart = fn
      
      fn()
      
      io.sockets.on 'connection', (clientSocket) ->
        console.log 'connection'
        match.addPlayer clientSocket
  }