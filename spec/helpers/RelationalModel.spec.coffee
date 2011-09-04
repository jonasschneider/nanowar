RelationalModel = require('../../app/helpers/RelationalModel.coffee').RelationalModel
Backbone = require('backbone')

class Post extends RelationalModel
  relations:
    author:
      model: 'Author'
    
class Author extends Backbone.Model

describe 'RelationalModel', ->
  it 'accepts null as relation model', ->
    expect((new Post).get('author')).toBe null
  ###  
  it 'accepts Player object as owner', ->
    jonas = new Author name: 'Jonas'
    x = new Post author: jonas
    
    expect(x.get('author')).toBe jonas
  ##
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
    
    expect ->
      new Cell game: new Game, owner: player.attributes
    .toThrow "Couldn't find player with id myid"
  ###