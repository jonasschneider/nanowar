RelationalModel = require('../../app/helpers/RelationalModel.coffee').RelationalModel
Backbone = require('backbone')

class Person extends Backbone.Model

class Post extends RelationalModel
  relationSpec:
    author:
      relatedModel: Person
      directory: 'blog.authors'

  initialize: ->
    @blog = @get('blog')
    @unset 'blog'

    super

class BlogWithoutAuthors
  authors:
    get: (id) ->
      undefined

class BlogWithAuthor
  constructor: (author) ->
    @authors =
      get: (id) =>
        if id == author.id
          author
        else
          undefined

describe 'RelationalModel', ->

  describe 'when setting the property', ->
    it 'accepts null', ->
      expect((new Post).get('author')).toBe null


    it 'throws on unrelated object', ->
      class UnrelatedClass

      expect ->
        new Post author: new UnrelatedClass
      .toThrow("Expected an instance of Person")


    it 'does not accept unregistered related model object', ->
      jonas = new Person name: 'Jonas'

      expect ->
        new Post blog: new BlogWithoutAuthors, author: jonas
      .toThrow("Person is not registered in this.blog.authors")


    it 'throws on registered related model object without id', ->
      jonas = new Person name: 'Jonas'

      expect ->
        new Post blog: new BlogWithAuthor(jonas), author: jonas
      .toThrow("Person is not registered in this.blog.authors")


    it 'accepts registered related model object with id', ->
      jonas = new Person name: 'Jonas', id: 123
      x = new Post blog: new BlogWithAuthor(jonas), author: jonas

      expect(x.get('author')).toBe jonas
  ###
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