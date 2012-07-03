require ['nanowar/models/Fleet', 'nanowar/models/Game', 'nanowar/models/Cell'], (Fleet, Game, Cell) ->
  describe 'Fleet', ->
    it 'stores attributes in collection', ->
      game = new Game
      fleet = game.entities.spawn 'Fleet', strength: 10
      
      expect(fleet.get 'strength').toBe 10

      expect(game.entities.getEntityAttribute(fleet.id, 'strength')).toBe 10

      game.entities.setEntityAttribute(fleet.id, 'strength', 5)
      game.entities.setEntityAttribute(fleet.id, 'lol', 3)

      expect(game.entities.getEntityAttribute(fleet.id, 'strength')).toBe 5
      expect(game.entities.getEntityAttribute(fleet.id, 'lol')).toBe 3

      expect(fleet.get('strength')).toBe 5
      expect(fleet.get('lol')).toBe 3

      fleet.set strength: 10
      expect(game.entities.getEntityAttribute(fleet.id, 'strength')).toBe 10
    
    it 'records mutations of attributes', ->
      game = new Game
      fleet = game.entities.spawn 'Fleet', strength: 10

      result = game.entities.mutate ->
        fleet.set strength: 5

      expect(fleet.get('strength')).toBe 5
      expect(JSON.stringify(result)).toBe JSON.stringify([["changed", "Fleet_1","strength",5]])

    it 'records the spawning of new entities', ->
      game = new Game

      result = game.entities.mutate ->
        game.entities.spawn 'Fleet', strength: 2

      expect(JSON.stringify(result)).toBe JSON.stringify([["spawned","Fleet","Fleet_1"],["changed","Fleet_1","strength",2]])

    it 'allows to store and restore snapshots', ->
      game = new Game
      fleet = game.entities.spawn 'Fleet', strength: 2

      stateBefore = game.entities.snapshotAttributes()

      fleet.set strength: 10
      expect(fleet.get('strength')).toBe 10

      game.entities.restoreAttributeSnapshot(stateBefore)

      expect(fleet.get('strength')).toBe 2


    it 'prohibits spawning and changes outside of mutations when in strict mode', ->
      game = new Game
      fleet = game.entities.spawn 'Fleet', strength: 2
      game.entities.enableStrictMode()

      expect ->
        game.entities.spawn 'Fleet', strength: 2
      .toThrow()

      expect ->
        fleet.set strength: 10
      .toThrow()
    
    it 'manages relations', ->
      game = new Game
      fleet = game.entities.spawn 'Fleet', strength: 2
      fleet2 = game.entities.spawn 'Fleet', strength: 10

      fleet.setRelation('neighbour', fleet2)

      expect(fleet.get 'neighbour_id').toBe fleet2.id
      expect(fleet.getRelation('neighbour')).toBe fleet2