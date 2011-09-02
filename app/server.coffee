App     = require('./models/App').App
Player  = require('./models/Player').Player
Cell    = require('./models/Cell').Cell
util    = require 'util'
_       = require 'underscore'

class exports.Server
  constructor: (clientSocket) ->
    console.log "making new server"
    app = new App
    
    game = app.game
    
    app.bind 'publish', (e) =>
      console.log('publishing: ' + util.inspect(e))
      clientSocket.emit('update', e)
    
    me = new Player name: "Joonas"
    pc = new Player name: "Fiz"
    
    game.players.add me
    game.players.add pc
    
    game.cells.add new Cell {x: 350, y: 100, size: 50}
    game.cells.add new Cell {x: 350, y: 300, size: 50, owner: me}
    game.cells.add new Cell {x: 100, y: 200, size: 50}
    game.cells.add new Cell {x: 500, y: 200, size: 50}
    game.cells.add new Cell {x: 550, y: 100, size: 10, owner: pc}
    
    go = ->
      game.run()
    _(go).delay(400)
    @obj_to_send = app
    #console.log(util.inspect(JSON.stringify(game.toJSON()), true, 3))