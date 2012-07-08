require ['nanowar/models/Fleet', 'nanowar/models/Game', 'nanowar/models/Cell'], (Fleet, Game, Cell) ->
  describe 'Fleet', ->
    it 'stores attributes in collection', ->
      game = new Game
      fleet = game.world.spawn 'Fleet', strength: 10
      
      expect(fleet.get 'strength').toBe 10

      expect(game.world.getEntityAttribute(fleet.id, 'strength')).toBe 10

      game.world.setEntityAttribute(fleet.id, 'strength', 5)
      game.world.setEntityAttribute(fleet.id, 'lol', 3)

      expect(game.world.getEntityAttribute(fleet.id, 'strength')).toBe 5
      expect(game.world.getEntityAttribute(fleet.id, 'lol')).toBe 3

      expect(fleet.get('strength')).toBe 5

      fleet.set strength: 10
      expect(game.world.getEntityAttribute(fleet.id, 'strength')).toBe 10
    
    it 'records mutations of attributes', ->
      game = new Game
      fleet = game.world.spawn 'Fleet', strength: 10

      result = game.world.mutate ->
        fleet.set strength: 5

      expect(fleet.get('strength')).toBe 5
      expect(JSON.stringify(result)).toBe JSON.stringify([["changed", "Fleet_1","strength",5]])

    it 'records the spawning of new world', ->
      game = new Game

      result = game.world.mutate ->
        game.world.spawn 'Fleet', strength: 2

      expect(JSON.stringify(result[0])).toBe JSON.stringify(["spawned","Fleet",{id: 'Fleet_1'}])

    it 'allows to store and restore snapshots', ->
      game = new Game
      fleet = game.world.spawn 'Fleet', strength: 2

      stateBefore = game.world.snapshotAttributes()

      fleet.set strength: 10
      expect(fleet.get('strength')).toBe 10

      game.world.restoreAttributeSnapshot(stateBefore)

      expect(fleet.get('strength')).toBe 2


    it 'prohibits spawning and changes outside of mutations when in strict mode', ->
      game = new Game
      fleet = game.world.spawn 'Fleet', strength: 2
      game.world.enableStrictMode()

      expect ->
        game.world.spawn 'Fleet', strength: 2
      .toThrow()

      expect ->
        fleet.set strength: 10
      .toThrow()
    
    it 'manages relations', ->
      game = new Game
      fleet = game.world.spawn 'Fleet', strength: 2
      fleet2 = game.world.spawn 'Fleet', strength: 10

      fleet.setRelation('owner', fleet2)

      expect(fleet.get 'owner_id').toBe fleet2.id
      expect(fleet.getRelation('owner')).toBe fleet2

      fleet.setRelation('owner', entId: fleet.id)
      expect(fleet.getRelation('owner')).toBe fleet
