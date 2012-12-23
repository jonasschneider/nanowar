Backbone = require 'backbone'
GameView = require './GameView'
io       = require 'socket.io'

module.exports = class AppView extends Backbone.View
  initialize: ->
    @gameDisplay = new GameView({model: @model.game, appView: this})
    
    @gameDisplay.bind 'ready', =>
      console.log("connecting..")
      socket = io.connect('http://'+location.hostname)
      
      socket.on 'update', (e) =>
        @model.trigger 'update', e
      
      socket.on 'log', (e) ->
        console.log e
      
      socket.on 'ping', (timestamp) =>
        socket.emit 'pong', timestamp

      socket.on 'applySnapshot', (snapshot) =>
        console.log snapshot
        @model.game.world.applyFullSnapshot(snapshot)
      
      socket.on 'setLocalPlayerId',  (player) =>
        @localPlayerId = player
        @trigger 'change:localPlayerId', player
        
        console.log 'localPlayerId set: ' + player
      
      socket.on 'connect', =>
        console.log 'connected to server'
        
        @model.bind 'publish', (e) =>
          socket.emit('update', e)