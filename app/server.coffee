App     = require('./models/App').App
Player  = require('./models/Player').Player
Cell    = require('./models/Cell').Cell
util    = require 'util'
_       = require 'underscore'

class exports.ClientHandler
  constructor: (clientSocket) ->
    console.log "making new server"
    
    
    app = new App
    
    game = app.game
    
    app.bind 'publish', (e) =>
      clientSocket.emit('update', e)
    
    me = new Player name: "Joonas"
    pc = new Player name: "Fiz"
    
    game.players.add [ me, pc ]
    
    cells = [
      new Cell {x: 350, y: 100, size: 50, game: game}
      new Cell {x: 350, y: 300, size: 50, owner: me, game: game}
      new Cell {x: 100, y: 200, size: 50, game: game}
      new Cell {x: 500, y: 200, size: 50, game: game}
      new Cell {x: 550, y: 100, size: 10, owner: pc, game: game}
    ]
   # knownCells.add cells
    game.cells.add cells
    
    console.log "Game has #{game.cells.size()} cells"
    go = ->
      game.run()
    _(go).delay(400)
    
    
    clientSocket.on 'update', (e) ->
      app.trigger 'update', e
    
    #console.log(util.inspect(JSON.stringify(game.toJSON()), true, 3))