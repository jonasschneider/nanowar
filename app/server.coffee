App     = require('./models/App').App
Player  = require('./models/Player').Player
Cell    = require('./models/Cell').Cell
util    = require 'util'
_       = require 'underscore'

class Match
  constructor: ->
    @app = new App
    @game = @app.game
    
    @app.bind 'publish', @distributeUpdate, this
    
    @players = []
    
  addPlayer: (clientSocket) ->
    player = new Player name: ("Player " + (@players.length + 1))
    player.socket = clientSocket
    @players.push player
    @game.players.add player, silent: true # for id & color
    clientSocket.emit 'log', 'You are: ' + JSON.stringify(player)
    
    clientSocket.on 'update', (e) =>
      player.socket.broadcast.emit 'update', e # security?
      @app.trigger 'update', e
    
    if @players.length == 2
      @start()
  
  distributeUpdate: (update) ->
    @sendToAll('update', update)
  
  sendToAll: ->
    clean = []
    _(arguments).each (arg) ->
      clean.push arg
    
    _(@players).each (player) -> # potential problem since we don't use @game.players
      player.socket.emit.apply(player.socket, clean)
  
  start: ->
    console.log 'starting.'
    @sendToAll 'log', 'starting soon!'
    @game.players.reset [], silent: true
    @game.players.add @players # publish player list
    
    cells = [
      new Cell {x: 350, y: 100, size: 50, game: @game}
      new Cell {x: 350, y: 300, size: 50, game: @game, owner: @game.players.first()}
      new Cell {x: 100, y: 200, size: 50, game: @game}
      new Cell {x: 500, y: 200, size: 50, game: @game}
      new Cell {x: 550, y: 100, size: 10, game: @game, owner: @game.players.last()}
    ]
    
    @game.bind 'end', (result) =>
      result.winner.socket.emit 'log', 'You win!'
      result.winner.socket.broadcast.emit 'log', "You lose. :'("
      
      _(@players).each (player) -> # potential problem since we don't use @game.players
        player.socket.emit 'log', 'Bye.'
        player.socket.disconnect()
    
    @game.cells.add cells
    
    go = =>
      @game.run()
    _(go).delay(1000)
    
    @onStart()

exports.start = (io) ->
  match = new Match
  
  fn = =>
    match = new Match
    match.onStart = fn
  
  fn()
  
  io.sockets.on 'connection', (clientSocket) ->
    match.addPlayer clientSocket