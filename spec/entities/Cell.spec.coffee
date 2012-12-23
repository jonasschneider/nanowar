require ['nanowar/entities/Player', 'dyz/World', 'nanowar/entities/Cell'], (Player, World, Cell) ->
  describe 'Cell', ->
    it 'tracks the current cell value', ->
      world = new World Cell: Cell, Player: Player

      owner = world.spawn 'Player'
      cell = world.spawn 'Cell', size: 50
      cell.setRelation('owner', owner)

      expect(cell.getCurrentStrength()).toBe 0
      world.ticks = 10
      expect(cell.getCurrentStrength()).toBe 5