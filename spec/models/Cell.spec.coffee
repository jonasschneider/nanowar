require ['nanowar/models/Player', 'nanowar/models/Game', 'nanowar/models/Cell'], (Player, Game, Cell) ->
  describe 'Cell', ->
    it 'tracks the current cell value', ->
      game = new Game
      owner = game.entities.spawn 'Player'
      cell = game.entities.spawn 'Cell', size: 50
      cell.setRelation('owner', owner)

      expect(cell.getCurrentStrength()).toBe 0
      game.ticks = 10
      expect(cell.getCurrentStrength()).toBe 5