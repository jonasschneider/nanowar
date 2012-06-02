require ['nanowar/models/Game', 'nanowar/models/Player'], (Game, Player) ->
  describe 'Player', ->
    it 'gets assigned a color', ->
      game = new Game
      p1 = new Player game: game
      p2 = new Player game: game
      
      game.entities.add [p1, p2]
      
      expect(p1.get 'color').toNotBe p2.get 'color'
      
    it 'does not overwrite the color', ->
      game = new Game
      p1 = new Player game: game, color: 'lila-blassblau-kariert'
      
      game.entities.add p1
      
      expect(p1.get 'color').toBe 'lila-blassblau-kariert'
      
    describe '#toString()', ->
      it 'returns name', ->
        p = new Player game: new Game, name: 'ohai'
        expect(p.toString()).toBe "[object Player 'ohai']"


      it 'returns default when name is null', ->  
        p = new Player game: new Game, name: null
        expect(p.toString()).toBe "[object Player]"