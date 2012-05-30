define (require) ->
  Backbone = require 'backbone'
  GameView = require './GameView'
  io       = require 'socket.io'

  return class AppView extends Backbone.View
    initialize: ->
      @gameDisplay = new GameView({model: @model.game, appView: this})
      
      @gameDisplay.bind 'ready', =>
        console.log("connecting..")
        socket = io.connect('http://'+location.hostname)
        
        socket.on 'update', (e) =>
          fn = =>
            @model.trigger 'update', e
          #_(fn).delay 200
          fn()
        
        socket.on 'log', (e) ->
          console.log e
        
        socket.on 'ping', (timestamp) =>
          socket.emit 'pong', timestamp
        
        socket.on 'setLocalPlayer',  (player) =>
          fn = =>
            player = @model.game.entities.get(player)
            @localPlayer = player
            @trigger 'change:localPlayer', player
            
            console.log 'localPlayer set: ' + JSON.stringify(player)
          #_(fn).delay 200 
          fn()
        
        socket.on 'connect', =>
          console.log 'connected to server'
          
          @model.bind 'publish', (e) =>
            socket.emit('update', e)