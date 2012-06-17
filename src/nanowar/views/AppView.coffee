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
          @model.trigger 'update', e
        
        socket.on 'log', (e) ->
          console.log e
        
        socket.on 'ping', (timestamp) =>
          socket.emit 'pong', timestamp

        socket.on 'runTellQueue', =>
          @model.game.runTellQueue()
          alert("tell queue ran")
        
        socket.on 'setLocalPlayer',  (player) =>
          console.log player, @model.game.entities
          alert(player)

          player = @model.game.entities.get(player)
          alert(@model.game.entities.models.toString())
          alert(player)
          @localPlayer = player
          @trigger 'change:localPlayer', player
          
          console.log 'localPlayer set: ' + JSON.stringify(player)
        
        socket.on 'connect', =>
          console.log 'connected to server'
          
          @model.bind 'publish', (e) =>
            socket.emit('update', e)