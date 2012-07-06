require ['nanowar/models/Game', 'nanowar/models/Player'], (Game, Player) ->
  describe 'Player', ->
    beforeEach ->
      @game = new Game
    
    it 'gets assigned a color', ->
      p1 = @game.world.spawn 'Player'
      p2 = @game.world.spawn 'Player'
      
      expect(p1.get 'color').toNotBe p2.get 'color'
      
    it 'does not overwrite the color', ->
      p1 = @game.world.spawn 'Player', color: 'lila-blassblau-kariert'
      
      expect(p1.get 'color').toBe 'lila-blassblau-kariert'
      
    describe '#toString()', ->
      it 'returns name', ->
        p = @game.world.spawn 'Player', name: 'ohai'
        expect(p.toString()).toBe "[object Player 'ohai']"

      it 'returns default when the player has no name', ->  
        p = @game.world.spawn 'Player'
        expect(p.toString()).toBe "[object Player 'anonymous coward']"