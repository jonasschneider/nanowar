EntityCollection = require('../../app/models/EntityCollection').EntityCollection
Entity = require('../../app/models/Entity').Entity

class MyEntity extends Entity
  hello: ->
    'world'

class MyOtherEntity extends Entity

describe 'EntityCollection', ->
  describe 'change triggers', ->
    it 'publishes on add', ->
      coll = new EntityCollection [], types: [MyEntity]
      
      spy = jasmine.createSpy()
      coll.bind 'publish', spy
      
      myEntity = new MyEntity
      
      coll.add myEntity
      
      expect(spy).toHaveBeenCalled()
      expect(spy.mostRecentCall.args[0].add).toBe myEntity
  
  
    it 'publishes on change', ->
      coll = new EntityCollection [], types: [MyEntity]
      
      spy = jasmine.createSpy()
      coll.bind 'publish', spy
      
      myEntity = new MyEntity
      coll.add myEntity
      
      myEntity.set someProperty: 'hi'
      
      expect(spy).toHaveBeenCalled()
      expect(spy.mostRecentCall.args[0].change).toBe myEntity



  describe 'on update', ->
    describe 'add', ->
      it 'can add an entity', ->
        coll = new EntityCollection [], types: [MyEntity]
        
        myEntity = new MyEntity aProperty: 'value'
        
        coll.trigger 'update', { add: myEntity.toJSON() }
        
        expect(coll.first() instanceof MyEntity).toBe true
        expect(coll.first().hello()).toBe 'world'
        expect(coll.first().get 'aProperty').toBe 'value'


      it 'throws nicely on unknown entity type', ->
        coll = new EntityCollection [], types: [MyEntity]
        
        entity = new MyOtherEntity
        
        expect ->
          coll.trigger 'update', { add: entity.toJSON() }
        .toThrow 'I dont know what to do with {"type":"MyOtherEntity"}. Known types are [MyEntity]'


      it 'can be polymorphic', ->
        coll = new EntityCollection [], types: [MyEntity, MyOtherEntity]
        
        myEntityA = new MyEntity aProperty: 'value'
        myEntityB = new MyOtherEntity bProperty: 'value2'
        
        coll.trigger 'update', { add: myEntityA.toJSON() }
        coll.trigger 'update', { add: myEntityB.toJSON() }
        
        expect(coll.first() instanceof MyEntity).toBe true
        expect(coll.first().get 'aProperty').toBe 'value'
        
        expect(coll.last() instanceof MyOtherEntity).toBe true
        expect(coll.last().get 'bProperty').toBe 'value2'

    
    it 'changes an entity when updated', ->
      coll = new EntityCollection [], types: [MyEntity]
      
      myEntity = new MyEntity someProperty: 1
      coll.add myEntity
      
      json = myEntity.toJSON()
      json.someProperty = 2
      
      coll.trigger 'update', { change: json }
      
      expect(coll.get(myEntity.id).get 'someProperty').toBe 2
