EntityCollection = require('../../app/models/EntityCollection').EntityCollection
Entity = require('../../app/models/Entity').Entity

class MyEntity extends Entity
  hello: ->
    'world'

class MyOtherEntity extends Entity

describe 'EntityCollection', ->
  describe 'change triggers', ->
    it 'publishes on add', ->
      coll = new EntityCollection [], types: [MyEntity], game: {}
      
      spy = jasmine.createSpy()
      coll.bind 'publish', spy
      
      myEntity = new MyEntity game: {}
      
      coll.add myEntity
      
      expect(spy).toHaveBeenCalled()
      expect(spy.mostRecentCall.args[0].add).toBe myEntity
  
  
    it 'publishes on change', ->
      coll = new EntityCollection [], types: [MyEntity], game: {}
      
      spy = jasmine.createSpy()
      coll.bind 'publish', spy
      
      myEntity = new MyEntity game: {}
      coll.add myEntity
      
      myEntity.set someProperty: 'hi'
      
      expect(spy).toHaveBeenCalled()
      expect(spy.mostRecentCall.args[0].change).toBe myEntity



  describe 'when updating', ->
    describe 'with a new entity', ->
      it 'adds the entity', ->
        coll = new EntityCollection [], types: [MyEntity], game: {}
        
        myEntity = new MyEntity aProperty: 'value', game: {}
        
        coll.trigger 'update', { add: myEntity.toJSON() }
        
        expect(coll.first() instanceof MyEntity).toBe true
        expect(coll.first().hello()).toBe 'world'
        expect(coll.first().get 'aProperty').toBe 'value'

      it 'changes an entity when updated', ->
        coll = new EntityCollection [], types: [MyEntity], game: {}
        
        myEntity = new MyEntity someProperty: 1, game: {}
        coll.add myEntity
        
        json = myEntity.toJSON()
        json.someProperty = 2
        
        coll.trigger 'update', { change: json }
        
        expect(coll.get(myEntity.id).get 'someProperty').toBe 2

  describe '#add', ->
    it 'passes the game to new entities', ->
      gameStub = {a: 1}
      coll = new EntityCollection [], types: [MyEntity], game: gameStub
      json = new MyEntity(game: gameStub).toJSON()
      
      coll.add json
      
      expect(coll.first().game).toBe gameStub


    it 'throws nicely on unknown entity type', ->
      coll = new EntityCollection [], types: [MyEntity], game: {}
      
      entity = new MyOtherEntity game: {}
      
      expect ->
        coll.add entity.toJSON()
      .toThrow 'I dont know what to do with {"type":"MyOtherEntity"}. Known types are [MyEntity]'


    it 'can be polymorphic', ->
      coll = new EntityCollection [], types: [MyEntity, MyOtherEntity], game: {}
      
      myEntityA = new MyEntity aProperty: 'value', game: {}
      myEntityB = new MyOtherEntity bProperty: 'value2', game: {}
      
      coll.add myEntityA.toJSON()
      coll.add myEntityB.toJSON()
      
      expect(coll.first() instanceof MyEntity).toBe true
      expect(coll.first().get 'aProperty').toBe 'value'
      
      expect(coll.last() instanceof MyOtherEntity).toBe true
      expect(coll.last().get 'bProperty').toBe 'value2'