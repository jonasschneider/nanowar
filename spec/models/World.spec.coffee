require ['nanowar/World', 'nanowar/Entity'], (World, Entity) ->
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

    describe '#applyMutation', ->
      it "works", ->
        mut = [["spawned","MyEntity",{id: "Fleet_1"}],["changed","Fleet_1$strength",1337]]

        @world.applyMutation(mut)

        expect(@world.get('Fleet_1') instanceof MyEntity).toBe true
        expect(@world.get('Fleet_1').get 'strength').toBe 1337

    describe '#attributesChangedByMutation', ->
      it "returns only changes", ->
        mut = [["spawned","MyEntity",{id: "Fleet_1"}],["changed","Fleet_1$strength",1337]]

        a = @world.attributesChangedByMutation(mut)

        expect(JSON.stringify(a)).toBe JSON.stringify({"Fleet_1$strength": 1337})

    describe '#remove', ->
      it "works", ->
        e = @world.spawn 'MyEntity'

        expect(@world.get(e.id)).toBe e
        @world.remove(e)
        expect(@world.get(e.id)).toBe undefined

      it 'removes state associated with the entity', ->
        e = @world.spawn 'MyEntity', strength: 10
        e2 = @world.spawn 'MyEntity', strength: 15

        k = @world._generateAttrKey(e.id, 'strength')
        expect(@world.state[k]).toBe 10

        @world.remove(e)
        expect(@world.state[k]).toBe undefined
        expect(e2.get('strength')).toBe 15


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

    it 'allows sending entity messages within a mutation', ->
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