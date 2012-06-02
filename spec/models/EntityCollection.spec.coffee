require ['nanowar/models/EntityCollection', 'nanowar/models/Entity', 'nanowar/models/Game'], (EntityCollection, Entity, Game) ->
  class MyEntity extends Entity
    hello: ->
      'world'

  class MyOtherEntity extends Entity

  describe 'EntityCollection', ->
    beforeEach ->
      @game = new Game
    describe 'on entity change', ->
      it 'publishes entity on add', ->
        @game.set onServer: true
        coll = new EntityCollection [], types: {'MyEntity': MyEntity}, game: @game
        
        spy = jasmine.createSpy()
        coll.bind 'publish', spy
        
        myEntity = new MyEntity game: @game
        
        coll.add myEntity
        
        expect(spy).toHaveBeenCalled()
        expect(JSON.stringify spy.mostRecentCall.args[0].add).toBe JSON.stringify myEntity
    
    
      it 'publishes a delta on change', ->
        @game.set onServer: true
        coll = new EntityCollection [], types: {'MyEntity': MyEntity}, game: @game
        
        spy = jasmine.createSpy()
        coll.bind 'publish', spy
        
        myEntity = new MyEntity game: @game
        coll.add myEntity
        
        myEntity.set someProperty: 'hi'
        
        expect(spy).toHaveBeenCalled()
        callArg = spy.mostRecentCall.args[0]
        expect(callArg.changedEntityId).toBe myEntity.id
        expect(JSON.stringify callArg.changeDelta).toBe '{"someProperty":"hi"}'


      it 'sends incremental updates', ->
        @game.set onServer: true
        coll = new EntityCollection [], types: {'MyEntity': MyEntity, 'MyOtherEntity': MyOtherEntity}, game: @game
        
        updates = []
        coll.bind 'publish', (c) =>
          updates.push c
        
        coll.add ent = new MyEntity game: @game, id: 1
        
        expect(updates.length).toBe 1
        expect(JSON.stringify updates[0].add).toBe JSON.stringify ent
        
        ent.set someProperty: 'cool'
        
        expect(updates.length).toBe 2
        expect(updates[1].changedEntityId).toBe 1
        expect(JSON.stringify updates[1].changeDelta).toBe '{"someProperty":"cool"}'



    describe 'on update', ->
      describe 'with an add entity request', ->
        it 'adds the entity', ->
          coll = new EntityCollection [], types: {'MyEntity': MyEntity}, game: @game
          
          myEntity = new MyEntity aProperty: 'value', game: @game
          
          coll.trigger 'update', { add: myEntity.toJSON() }
          
          expect(coll.first() instanceof MyEntity).toBe true
          expect(coll.first().hello()).toBe 'world'
          expect(coll.first().get 'aProperty').toBe 'value'


      describe 'with a change entity request', ->
        it "calls 'update' on the changed entity", ->
          coll = new EntityCollection [], types: {'MyEntity': MyEntity}, game: @game
          
          coll.add myEntity = new MyEntity someProperty: 1, game: @game
          
          spy = jasmine.createSpy('entity update handler')
          myEntity.bind 'update', spy
          
          coll.trigger 'update', { changedEntityId: myEntity.id, changeDelta: {"someProperty":1337} }
          
          expect(spy).toHaveBeenCalled()
          expect(spy.mostRecentCall.args.length).toBe 1
          expect(spy.mostRecentCall.args[0].someProperty).toBe 1337


        it "throws when attempting to update an unknown entity", ->
          coll = new EntityCollection [], types: {'MyEntity': MyEntity}, game: @game
          
          coll.add myEntity = new MyEntity someProperty: 1, game: @game
          
          expect ->
            coll.trigger 'update', { changedEntityId: 2, changeDelta: {"someProperty":1337} }
          .toThrow 'Could not find entity with id 2'



    describe '#add', ->
      it 'passes the game to new entities', ->
        coll = new EntityCollection [], types: {'MyEntity': MyEntity}, game: @game
        json = new MyEntity(game: @game).toJSON()
        
        coll.add json
        
        expect(coll.first().game).toBe @game


      it 'throws nicely on unknown entity type', ->
        coll = new EntityCollection [], types: {'MyEntity': MyEntity}, game: @game
        
        entity = new MyOtherEntity game: @game
        
        expect ->
          coll.add entity.toJSON()
        .toThrow 'I dont know what to do with {"type":"MyOtherEntity"}. Known types are [MyEntity]'


      it 'is polymorphic', ->
        coll = new EntityCollection [], types: {'MyEntity': MyEntity, 'MyOtherEntity': MyOtherEntity}, game: @game
        
        myEntityA = new MyEntity aProperty: 'value', game: @game
        myEntityB = new MyOtherEntity bProperty: 'value2', game: @game
        
        coll.add myEntityA.toJSON()
        coll.add myEntityB.toJSON()
        
        expect(coll.first() instanceof MyEntity).toBe true
        expect(coll.first().get 'aProperty').toBe 'value'
        
        expect(coll.last() instanceof MyOtherEntity).toBe true
        expect(coll.last().get 'bProperty').toBe 'value2'