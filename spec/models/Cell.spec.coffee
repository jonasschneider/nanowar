Cell = require('../../app/models/Cell').Cell
Game = require('../../app/models/Game').Game
Player = require('../../app/models/Player').Player
panda = 'happy'

describe 'Cell', ->
  
  it 'throws without game', ->
    expect ->
      new Cell
    .toThrow()
  
  it 'is creatable with game', ->
    new Cell game: new Game
    
  it 'accepts Player object as owner', ->
    player = new Player
    x = new Cell game: new Game, owner: player
    expect x.get('owner') instanceof Player
    
  it 'throws on player attributes as owner', ->
    player = new Player
    expect ->
      new Cell game: new Game, owner: player.attributes
    .toThrow()
    
  it "accepts a registered player's attributes' as owner", ->
    game = new Game
    player = new Player
    game.players.add player
    x = new Cell game: game, owner: player.attributes
    expect(x.get('owner')).toBe player
  
  it "throws on unregistered player's attributes' as owner", ->
    player = new Player
    player.set id: "myid"
    console.log player.attributes
    expect ->
      new Cell game: new Game, owner: player.attributes
    .toThrow "Couldn't find player with id myid"