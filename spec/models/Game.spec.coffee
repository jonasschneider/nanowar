Game = require('../../app/models/Game').Game
Cell = require('../../app/models/Cell').Cell
Player = require('../../app/models/Player').Player


describe 'Game', ->
  describe '#getCells', ->
    it 'works', ->
      game = new Game
      cell = new Cell game: game
      
      game.entities.add cell
      game.entities.add new Player
      
      expect(game.getCells().length).toBe 1
      expect(game.getCells()[0]).toBe cell