#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.AppView extends Backbone.View
  initialize: ->
    @gameDisplay = new Nanowar.views.GameView({model: @model.game, appView: this})
    
    console.log("connecting..")
    socket = io.connect('http://'+location.hostname)
    
    socket.on 'update', (e) =>
      @model.trigger 'update', e
    
    socket.on 'log', (e) ->
      console.log e
    
    socket.on 'ping', (timestamp) =>
      socket.emit 'pong', timestamp
    
    socket.on 'setLocalPlayer',  (player) =>
      player = @model.game.players.get(player)
      @localPlayer = player
      @trigger 'change:localPlayer', player
      
      console.log 'localPlayer set: ' + JSON.stringify(player)
    
    socket.on 'connect', =>
      console.log 'connected to server'
      
      @model.bind 'publish', (e) =>
        socket.emit('update', e)