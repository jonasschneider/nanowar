World = require('dyz/World')
Entity = require('dyz/Entity')

class MyEntity extends Entity
  attributeSpecs:
    strength: 0

  hello: ->
    'world'

class MyOtherEntity extends Entity

describe 'World', ->
  beforeEach ->
    @world = new World { MyEntity: MyEntity, MyOtherEntity: MyOtherEntity }
    @anotherWorld = new World { MyEntity: MyEntity, MyOtherEntity: MyOtherEntity }

  describe '#getEntitiesOfType', ->
    it 'works', ->
      ent =  @world.spawn 'MyEntity'
      @world.spawn 'MyOtherEntity'

      expect(@world.getEntitiesOfType('MyEntity').length).toBe 1
      expect(@world.getEntitiesOfType('MyEntity')[0]).toBe ent

  describe '#constructor', ->
    it 'infers the entity types from their classes', ->
      #coll = new World [MyEntity]
      expect(@world.types['MyEntity']).toBe MyEntity

  describe '#spawn', ->
    it 'throws on unknown entity type', ->
      expect =>
        @world.spawn 'Trolol'
      .toThrow 'unknown entity type Trolol'

  describe '#mutate', ->
    it 'records the spawning of new entities', ->
      result = @world.mutate =>
        @world.spawn 'MyEntity', strength: 1337
      
      expect(@anotherWorld.entities.length).toBe 0
      @anotherWorld.applyMutation(result)
      expect(@anotherWorld.entities.length).toBe 1
      expect(@anotherWorld.entities[0].get 'strength').toBe 1337

    it 'fires a change event for changed attributes', ->
      e = null
      spawn = @world.mutate =>
        e = @world.spawn 'MyEntity', strength: 1337

      change = @world.mutate =>
        e.set strength: 1338
      
      @anotherWorld.applyMutation(spawn)

      console.log(@anotherWorld)

      @anotherWorld.get(e.id).bind 'change', spy = jasmine.createSpy()
      @anotherWorld.applyMutation(change)

      expect(spy).toHaveBeenCalled()


  describe '#snapshotFull', ->
    it "works", ->
      @world.spawn 'MyEntity', strength: 1337

      @anotherWorld.applyFullSnapshot @world.snapshotFull()

      expect(@anotherWorld.get('MyEntity_1') instanceof MyEntity).toBe true
      expect(@anotherWorld.get('MyEntity_1').get 'strength').toBe 1337

  describe '#remove', ->
    it "works", ->
      e = @world.spawn 'MyEntity'

      expect(@world.get(e.id)).toBe e
      @world.remove(e)
      expect(@world.get(e.id)).toBe undefined

    it 'removes state associated with the entity', ->
      e = @world.spawn 'MyEntity', strength: 10
      e2 = @world.spawn 'MyEntity', strength: 15

      @world.remove(e)
      @world.remove(e2)
      expect(JSON.stringify(@world.state.internalState)).toBe '{}'
    
    it "fires the entity's remove event", ->
      e = @world.spawn 'MyEntity', strength: 10

      e.bind 'remove', spy = jasmine.createSpy()

      @world.remove(e)

      expect(spy).toHaveBeenCalled()


  describe '#setEntityAttribute', ->
    it "notifies the changed entity", ->
      e = @world.spawn 'MyEntity'
      e2 = @world.spawn 'MyEntity'

      called = false
      failed = false

      e.bind 'change', ->
        called = true

      e2.bind 'change', ->
        failed = true
      
      @world.setEntityAttribute e.id, 'strength', 4

      expect(called).toBe true
      expect(failed).toBe false

  describe '#snapshotAttributes', ->
    it 'allows to store and restore snapshots', ->
      fleet = @world.spawn 'MyEntity', strength: 2

      stateBefore = @world.snapshotAttributes()

      fleet.set strength: 10
      expect(fleet.get('strength')).toBe 10

      @world.applyAttributeSnapshot(stateBefore)

      expect(fleet.get('strength')).toBe 2

  describe 'entity messages', ->
    it 'allows sending entity messages within a mutation', ->
      ent = null

      spawn = @world.mutate =>
        ent = @world.spawn 'MyEntity'

      data = a: 0

      msg = @world.mutate ->
        ent.message 'omnom'

      @anotherWorld.applyMutation spawn
      @anotherWorld.get(ent.id).bind 'omnom', spy = jasmine.createSpy()
      @anotherWorld.applyMutation msg

      expect(spy).toHaveBeenCalled()

    it 'allows sending entity messages with an argument', ->
      ent = null

      spawn = @world.mutate =>
        ent = @world.spawn 'MyEntity'

      data = a: 0

      msg = @world.mutate ->
        ent.message 'omnom', data

      @anotherWorld.applyMutation spawn
      @anotherWorld.get(ent.id).bind 'omnom', spy = jasmine.createSpy()
      @anotherWorld.applyMutation msg

      expect(spy).toHaveBeenCalledWith(data)

    it 'allows sending serialized entities as an argument for an entity message', ->
      ent = null
      ent2 = null

      spawn = @world.mutate =>
        ent = @world.spawn 'MyEntity'
        ent2 = @world.spawn 'MyEntity'

      msg = @world.mutate ->
        ent.message 'omnom', ent2

      @anotherWorld.applyMutation spawn

      another_ent2 = @anotherWorld.get(ent2.id)
      @anotherWorld.get(ent.id).bind 'omnom', spy = jasmine.createSpy()

      @anotherWorld.applyMutation msg

      expect(spy).toHaveBeenCalledWith(another_ent2)