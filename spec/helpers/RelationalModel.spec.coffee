RelationalModel = require('../../app/helpers/RelationalModel.coffee').RelationalModel
Backbone = require('../../app/vendor/backbone')

class Person extends Backbone.Model

class Post extends RelationalModel
  relationSpecs:
    author:
      relatedModel: Person
      directory: 'blog.authors'

  initialize: ->
    @blog = @get('blog') || new BlogWithoutAuthors
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
  describe 'when setting the property via initializer', ->
    it 'accepts null', ->
      expect((new Post).get('author')).toBe null


    it 'throws on unrelated object', ->
      class UnrelatedClass

      expect ->
        new Post author: new UnrelatedClass
      .toThrow("While instantiating Post: Expected an instance of Person, not {}")


    it 'throws on unregistered related model object', ->
      jonas = new Person name: 'Jonas'

      expect ->
        new Post blog: new BlogWithoutAuthors, author: jonas
      .toThrow("While instantiating Post: Person is not registered in this.blog.authors")


    it 'throws on registered related model object without id', ->
      jonas = new Person name: 'Jonas'

      expect ->
        new Post blog: new BlogWithAuthor(jonas), author: jonas
      .toThrow("While instantiating Post: Person is not registered in this.blog.authors")


    it 'accepts registered related model object with id', ->
      jonas = new Person name: 'Jonas', id: 123
      x = new Post blog: new BlogWithAuthor(jonas), author: jonas

      expect(x.get('author')).toBe jonas


    it "accepts a correct serialized relation ", ->
      jonas = new Person name: 'Jonas', id: 123

      x = new Post blog: new BlogWithAuthor(jonas), author: { type: 'serializedRelation', model: 'Person', id: jonas.id }

      expect(x.get('author')).toBe jonas


    it "throws on serialized relation with wrong model", ->
      jonas = new Person name: 'Jonas', id: 123

      expect ->
        new Post blog: new BlogWithAuthor(jonas), author: { type: 'serializedRelation', model: 'Comment', id: jonas.id }
      .toThrow("While instantiating Post: Expected serialized relation of a Person model, not a Comment model")


    it "throws on serialized relation with unregistered model", ->
      jonas = new Person name: 'Jonas', id: 123

      expect ->
        new Post author: { type: 'serializedRelation', model: 'Person', id: jonas.id }
      .toThrow("While instantiating Post: Person is not registered in this.blog.authors")



  describe 'when setting the property via #set', ->
    it 'accepts null', ->
      p = new Post
      p.set author: null
      expect(p.get 'author').toBe null


    it 'throws on unrelated object', ->
      class UnrelatedClass

      expect ->
        p = new Post
        p.set author: {}
      .toThrow("While instantiating Post: Expected an instance of Person, not {}")


    it 'throws on unregistered related model object', ->
      jonas = new Person name: 'Jonas'

      expect ->
        p = new Post
        p.set author: jonas
      .toThrow("While instantiating Post: Person is not registered in this.blog.authors")


    it 'throws on registered related model object without id', ->
      jonas = new Person name: 'Jonas'

      expect ->
        new Post blog: new BlogWithAuthor(jonas), author: jonas
      .toThrow("While instantiating Post: Person is not registered in this.blog.authors")


    it 'accepts registered related model object with id', ->
      jonas = new Person name: 'Jonas', id: 123
      x = new Post blog: new BlogWithAuthor(jonas)
      x.set author: jonas

      expect(x.get('author')).toBe jonas


    it "accepts a correct serialized relation ", ->
      jonas = new Person name: 'Jonas', id: 123
      x = new Post blog: new BlogWithAuthor(jonas)
      x.set author: { type: 'serializedRelation', model: 'Person', id: jonas.id }

      expect(x.get('author')).toBe jonas



  describe '#toJSON', ->
    it 'works with null', ->
       expect((new Post).toJSON().author).toBe null


    it 'serializes relation', ->
      jonas = new Person name: 'Jonas', id: 123
      x = new Post(blog: new BlogWithAuthor(jonas), author: jonas).toJSON()

      expect(x.author.type).toBe 'serializedRelation'
      expect(x.author.model).toBe 'Person'
      expect(x.author.id).toBe jonas.id


    it 'does not change attributes', ->
      jonas = new Person name: 'Jonas', id: 123
      x = new Post blog: new BlogWithAuthor(jonas), author: jonas
      x.toJSON()

      expect(x.get('author')).toBe jonas



  describe 'integrated', ->
    it 'exports & restores relation', ->
      jonas = new Person name: 'Jonas', id: 123
      json = new Post(blog: new BlogWithAuthor(jonas), author: jonas).toJSON()

      json.blog = new BlogWithAuthor(jonas)
      restored = new Post json

      expect(restored.get 'author').toBe jonas