Fleet = require('../../app/models/Fleet').Fleet
Game = require('../../app/models/Game').Game
Cell = require('../../app/models/Cell').Cell

describe 'Fleet', ->
  it 'accepts registered Cell', ->
    game = new Game
    game.entities.add cell1 = new Cell game: game
    game.entities.add cell2 = new Cell game: game
    
    fleet = new Fleet game: game, from: cell1, to: cell2
    expect(fleet.get 'from').toBe cell1
    expect(fleet.get 'to').toBe cell2


  it 'throws on unregistered Cell', ->
    game = new Game
    cell1 = new Cell game: game
    cell2 = new Cell game: game

    expect ->
      new Fleet game: game, from: cell1, to: cell2
    .toThrow 'While instantiating Fleet: Cell is not registered in this.game.entities'


  it 'serializes', ->
    game = new Game
    game.entities.add cell1 = new Cell game: game
    game.entities.add cell2 = new Cell game: game

    fleetJson = new Fleet(game: game, from: cell1, to: cell2).toJSON()
    fleetJson.game = game
    fleet = new Fleet fleetJson

    expect(fleet.get 'from').toBe cell1
    expect(fleet.get 'to').toBe cell2