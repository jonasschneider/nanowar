require ['nanowar/models/Game', 'nanowar/models/Cell', 'nanowar/models/Player'], (Game, Cell, Player) ->
  describe 'Game', ->
    describe '#getCells', ->
      it 'works', ->
        game = new Game
        cell = new Cell game: game

        game.entities.add cell
        game.entities.add new Player game: game

        expect(game.getCells().length).toBe 1
        expect(game.getCells()[0]).toBe cell

    describe '#getPlayers', ->
      it 'works', ->
        game = new Game
        player = new Player game: game, name: 'ohai'

        game.entities.add new Cell game: game
        game.entities.add player

        expect(game.getPlayers().length).toBe 1
        expect(game.getPlayers()[0]).toBe player


    describe '#getWinner', ->
      it 'returns 0 when there are multiple players remaining', ->
        game = new Game
        game.entities.add p1 = new Player game: game
        game.entities.add p2 = new Player game: game
        game.entities.add new Cell game: game, owner: p1
        game.entities.add new Cell game: game, owner: p2

        expect(game.getWinner()).toBe null

      it 'returns the winner when there is only one player remaining', ->
        game = new Game
        game.entities.add p1 = new Player game: game
        game.entities.add p2 = new Player game: game
        game.entities.add new Cell game: game, owner: p2
        game.entities.add new Cell game: game, owner: p2

        expect(game.getWinner()).toBe p2