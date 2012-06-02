require ['nanowar/models/Fleet', 'nanowar/models/Game', 'nanowar/models/Cell'], (Fleet, Game, Cell) ->
  describe 'Fleet', ->
    it 'accepts registered Cell', ->
      game = new Game
      game.entities.add cell1 = new Cell game: game
      game.entities.add cell2 = new Cell game: game
      
      fleet = new Fleet game: game, from: cell1, to: cell2
      expect(fleet.get 'from').toBe cell1
      expect(fleet.get 'to').toBe cell2

    it 'serializes', ->
      game = new Game
      game.entities.add cell1 = new Cell game: game
      game.entities.add cell2 = new Cell game: game

      fleetJson = new Fleet(game: game, from: cell1, to: cell2).toJSON()
      fleetJson.game = game
      fleet = new Fleet fleetJson

      expect(fleet.get 'from').toBe cell1
      expect(fleet.get 'to').toBe cell2