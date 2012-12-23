require ['dyz/World', 'nanowar/Entity'], (World, Entity) ->
  class EntWithAttrs extends Entity
    attributeSpecs:
      strength: 0

  class EntWithoutAttrs extends Entity
  
  describe 'Entity', ->
    beforeEach ->
      @world = new World EntWithAttrs: EntWithAttrs, EntWithoutAttrs: EntWithoutAttrs
    
    it 'throws when setting undeclared attributes', ->
      ent = @world.spawn 'EntWithAttrs', strength: 10
      ent.set strength: 5

      expect ->
        ent.set lolz: 'ohai'
      .toThrow()

    it 'allows entities without attributes', ->
      fleet = @world.spawn 'EntWithoutAttrs'
      
      expect ->
        fleet.set strength: 5
      .toThrow()

    describe '#attributes', ->
      it 'collects the attributes and returns them', ->
        fleet = @world.spawn 'EntWithAttrs'
        
        expect(JSON.stringify fleet.attributes()).toBe '{"strength":0,"dead":false}'