require ['nanowar/models/EntityCollection', 'nanowar/models/Entity', 'nanowar/models/Game'], (EntityCollection, Entity, Game) ->
  class MyEntity extends Entity
    attributeSpecs:
      strength: 0

    hello: ->
      'world'

  class MyOtherEntity extends Entity

  describe 'EntityCollection', ->
    beforeEach ->
      @game = new Game
      @coll = new EntityCollection [], types: {'MyEntity': MyEntity}, game: @game

    describe 'applying mutations', ->
      it "works", ->
        mut = [["spawned","MyEntity",{id: "Fleet_1"}],["changed","Fleet_1","strength",1337]]

        @coll.applyMutation(mut)

        expect(@coll.get('Fleet_1') instanceof MyEntity).toBe true
        expect(@coll.get('Fleet_1').get 'strength').toBe 1337

    describe '#remove', ->
      it "works", ->
        e = @coll.spawn 'MyEntity'

        expect(@coll.get(e.id)).toBe e

        @coll.remove(e)

        expect(@coll.get(e.id)).toBe undefined


    describe '#setEntityAttribute', ->
      it "notifies the changed entity", ->
        e = @coll.spawn 'MyEntity'
        e2 = @coll.spawn 'MyEntity'

        called = false
        failed = false

        e.bind 'change', ->
          called = true

        e2.bind 'change', ->
          failed = true
        
        @coll.setEntityAttribute e.id, 'strength', 4

        expect(called).toBe true
        expect(failed).toBe false