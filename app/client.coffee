#= require_tree models
#= require_tree views
#= require_tree helpers

$(document).ready ->
  socket = io.connect('http://'+location.hostname)

  Backbone.sync = (method, model, options) ->
    socket.emit method, model.url(), (data) ->
      options.success(data)
  
  socket.on 'update', (e) ->
    window.App.trigger 'update', e
  
  socket.on 'log', (e) ->
    console.log e
    
  socket.on 'connect', ->
    console.log 'connected to server'
    
    window.App = new Nanowar.App()
    App.bind 'publish', (e) =>
      socket.emit('update', e)
    
    gameDisplay = new Nanowar.views.GameView({model: window.App.game, el: $("#nanowar")[0]})
    