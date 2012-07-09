require ['nanowar/World', 'nanowar/Entity'], (World, Entity) ->
  class MyEntity extends Entity
    attributeSpecs:
      strength: 0

    hello: ->
      'world'

  class MyOtherEntity extends Entity

  describe 'World', ->
    beforeEach ->
      @coll = new World { MyEntity: MyEntity, MyOtherEntity: MyOtherEntity }

    describe '#getEntitiesOfType', ->
      it 'works', ->
        ent =  @coll.spawn 'MyEntity'
        @coll.spawn 'MyOtherEntity'

        expect(@coll.getEntitiesOfType('MyEntity').length).toBe 1
        expect(@coll.getEntitiesOfType('MyEntity')[0]).toBe ent

    describe '#constructor', ->
      it 'infers the entity types from their classes', ->
        #coll = new World [MyEntity]
        expect(@coll.types['MyEntity']).toBe MyEntity

    describe '#spawn', ->
      it 'throws on unknown entity type', ->
        expect =>
          @coll.spawn 'Trolol'
        .toThrow 'unknown entity type Trolol'

    describe '#applyMutation', ->
      it "works", ->
        mut = [["spawned","MyEntity",{id: "Fleet_1"}],["changed","Fleet_1$strength",1337]]

        @coll.applyMutation(mut)

        expect(@coll.get('Fleet_1') instanceof MyEntity).toBe true
        expect(@coll.get('Fleet_1').get 'strength').toBe 1337

    describe '#attributesChangedByMutation', ->
      it "returns only changes", ->
        mut = [["spawned","MyEntity",{id: "Fleet_3"}],["changed","Fleet_1","strength",1337]]

        a = @coll.attributesChangedByMutation(mut)

        expect(JSON.stringify(a)).toBe JSON.stringify([["Fleet_1", "strength", 1337]])

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