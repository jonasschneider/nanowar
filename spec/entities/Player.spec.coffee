require ['dyz/World', 'nanowar/entities/Player'], (World, Player) ->
  describe 'Player', ->
    beforeEach ->
      @world = new World { Player: Player }
    
    it 'gets assigned a color', ->
      p1 = @world.spawn 'Player'
      p2 = @world.spawn 'Player'
      
      expect(p1.get 'color').toNotBe p2.get 'color'
      
    it 'does not overwrite the color', ->
      p1 = @world.spawn 'Player', color: 'lila-blassblau-kariert'
      
      expect(p1.get 'color').toBe 'lila-blassblau-kariert'
      
    describe '#toString()', ->
      it 'returns name', ->
        p = @world.spawn 'Player', name: 'ohai'
        expect(p.toString()).toBe "[object Player 'ohai']"

      it 'returns default when the player has no name', ->  
        p = @world.spawn 'Player'
        expect(p.toString()).toBe "[object Player 'anonymous coward']"