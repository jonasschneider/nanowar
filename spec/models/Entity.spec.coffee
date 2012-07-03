require ['nanowar/models/Game'], (Game) ->
  describe 'Entity', ->
    it 'throws when setting undeclared attributes', ->
      game = new Game
      fleet = game.entities.spawn 'Fleet', strength: 10

      fleet.set strength: 5

      expect ->
        fleet.set lolz: 'ohai'
      .toThrow()