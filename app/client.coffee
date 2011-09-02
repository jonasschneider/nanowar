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
  
  socket.on 'connect', ->
    console.log 'connected to server'
    
    window.App = new Nanowar.App()
    #window.App.fetch success: ->
    #a = ->
    #  console.log "fetched the app:"
    #  console.log(window.App)
    
    window.App.bind 'publish', (e) =>
      socket.emit('update', e)
    
    gameDisplay = new Nanowar.views.GameView({model: window.App.game, el: $("#nanowar")[0]})
    
    #me = new Nanowar.Player { name: "Joonas" }
    #pc = new Nanowar.Player { name: "Fiz" }
    
    #game.players.add me
    #game.players.add pc
    
    #console.log game.cells
    
    #game.cells.add {x: 350, y: 100, size: 50}
    #game.cells.add {x: 350, y: 300, size: 50, owner: me}
    #game.cells.add {x: 100, y: 200, size: 50}
    #game.cells.add {x: 500, y: 200, size: 50}
    #game.cells.add {x: 550, y: 100, size: 10, owner: pc}
    ###
    gameDisplay.render()
    
    gameDisplay.run()###