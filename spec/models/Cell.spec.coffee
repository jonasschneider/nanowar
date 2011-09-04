Cell = require('../../app/models/Cell').Cell
Game = require('../../app/models/Game').Game
Player = require('../../app/models/Player').Player

describe 'Cell', ->
  it 'throws without game', ->
    expect ->
      new Cell
    .toThrow()

  it 'is creatable with game', ->
    new Cell game: new Game

  it 'accepts registered Player as owner', ->
    player = new Player
    game = new Game
    game.players.add player
    x = new Cell game: game, owner: player

    expect(x.get('owner')).toBe player
    
  it 'throws on player attributes as owner', ->
    player = new Player

    expect ->
      new Cell game: new Game, owner: player.attributes
    .toThrow()
  
  it "throws on unregistered player as owner", ->
    player = new Player id: "5"

    expect ->
      new Cell game: new Game, owner: player
    .toThrow()