Cell = require('../../app/models/Cell').Cell
Game = require('../../app/models/Game').Game
Player = require('../../app/models/Player').Player

describe 'Cell', ->
  it 'accepts registered Player as owner', ->
    game = new Game
    player = new Player game: game
    
    game.entities.add player
    x = new Cell game: game, owner: player

    expect(x.get('owner')).toBe player


  it 'throws on player attributes as owner', ->
    game = new Game
    player = new Player game: game

    expect ->
      new Cell game: new Game, owner: player.attributes
    .toThrow('While instantiating Cell: Expected an instance of Player, not {"name":"anonymous coward","type":"Player"}')


  it "throws on unregistered player as owner", ->
    game = new Game
    player = new Player id: "5", game: game

    expect ->
      new Cell game: game, owner: player
    .toThrow('While instantiating Cell: Player is not registered in this.game.entities')