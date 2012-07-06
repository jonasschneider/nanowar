require ['nanowar/models/EnhancerNode', 'nanowar/models/Cell', 'nanowar/models/Game', 'nanowar/models/Player'], (EnhancerNode, Cell, Game, Player) ->
  describe 'EnhancerNode', ->
    it 'has an owner', ->
      node = new EnhancerNode game: new Game
      expect(node.relationSpecs.owner).not.toBe undefined
      
    it 'is an entity', ->
      expect ->
        new EnhancerNode
      .toThrow 'Entity needs game'
      
    describe '#affectedCells', ->
      it 'returns [] when there are not cells', ->
        node = new EnhancerNode game: new Game
        expect(node.affectedCells().length).toBe 0
        
      it 'affects a cell owned by the player', ->
        game = new Game
        game.world.add me = new Player game: game
        game.world.add cell = new Cell game: game, owner: me
        node = new EnhancerNode game: game, owner: me
        
        expect(node.affectedCells().length).toBe 1
        expect(node.affectedCells()[0]).toBe cell
      
      it 'does not affect cells owned by others', ->
        game = new Game
        game.world.add me = new Player game: game
        game.world.add fiz = new Player game: game
        game.world.add cell = new Cell game: game, owner: fiz
        node = new EnhancerNode game: game, owner: me
        
        expect(node.affectedCells().length).toBe 0
        
      it 'only affects the nearest 2 cells', ->
        game = new Game
        game.world.add me = new Player game: game
        game.world.add cell1 = new Cell game: game, owner: me, x: 100, y: 0
        game.world.add new Cell game: game, x: 0, y: 0
        node = new EnhancerNode game: game, owner: me, x: 80, y: 0
        
        expect(node.affectedCells().length).toBe 1
        expect(node.affectedCells()[0]).toBe cell1
        
        game.world.add new Cell game: game, x: 80, y: 0
        game.world.add cell2 = new Cell game: game, owner: me, x: 50, y: 0
        
        expect(node.affectedCells().length).toBe 2
        expect(node.affectedCells()[0]).toBe cell1
        expect(node.affectedCells()[1]).toBe cell2
        
        game.world.add new Cell game: game, owner: me, x: 30, y: 0
        game.world.add cell3 = new Cell game: game, owner: me, x: 60, y: 0 # nearer than cell 2
        
        expect(node.affectedCells().length).toBe 2
        expect(node.affectedCells()[0]).toBe cell1
        expect(node.affectedCells()[1]).toBe cell3


    it 'triggers affectedCells:add when a new cell gets affected', ->
      game = new Game
      game.world.add me = new Player game: game
      
      node = new EnhancerNode game: game, owner: me
      node.bind 'affectedCells:add', spy = jasmine.createSpy()
      
      game.world.add cell1 = new Cell game: game, owner: me
      
      expect(spy).toHaveBeenCalled()
      expect(spy.mostRecentCall.args[0]).toBe cell1


    it "triggers affectedCells:remove when an affected cell's owner changes", ->
      game = new Game
      game.world.add me = new Player game: game
      game.world.add fiz = new Player game: game
      
      node = new EnhancerNode game: game, owner: me
      node.bind 'affectedCells:remove', spy = jasmine.createSpy()
      
      game.world.add cell = new Cell game: game, owner: me
      expect(spy).not.toHaveBeenCalled()
      
      cell.set owner: fiz
      
      expect(spy).toHaveBeenCalledWith cell


    it "doesnt't trigger when another entity is changed", ->
      game = new Game
      game.world.add me = new Player game: game, owner: 'invalid'
      
      node = new EnhancerNode game: game, owner: me
      node.bind 'affectedCells:remove', spy = jasmine.createSpy()
      
      me.set owner: 'more invalid'
      
      expect(spy).not.toHaveBeenCalled()


    it "doesn't trigger when other cell attributes change", ->
      game = new Game
      game.world.add me = new Player game: game
      
      node = new EnhancerNode game: game, owner: me
      node.bind 'affectedCells:remove', spy = jasmine.createSpy()
      
      game.world.add cell = new Cell game: game, owner: me, x: 0
      
      cell.set x: 50
      
      expect(spy).not.toHaveBeenCalled()


    it "doesn't trigger when an unaffected cell changes", ->
      game = new Game
      game.world.add me = new Player game: game
      game.world.add fiz = new Player game: game
      game.world.add p3 = new Player game: game
      game.world.add cell = new Cell game: game, owner: fiz, x: 0
      
      node = new EnhancerNode game: game, owner: me
      node.bind 'affectedCells:remove', spy = jasmine.createSpy()
      
      cell.set owner: p3
      
      expect(spy).not.toHaveBeenCalled()


    it "triggers affectedCells:add when a cell changes owner", ->
      game = new Game
      game.world.add me = new Player game: game
      game.world.add fiz = new Player game: game
      
      node = new EnhancerNode game: game, owner: me
      node.bind 'affectedCells:add', spy = jasmine.createSpy()
      
      game.world.add cell = new Cell game: game, owner: fiz, x: 0
      expect(spy).not.toHaveBeenCalled()
      
      cell.set owner: me
      
      expect(spy).toHaveBeenCalledWith(cell)


    it "doesn't trigger affectedCells:add when the list is already full", ->
      game = new Game
      game.world.add me = new Player game: game
      
      node = new EnhancerNode game: game, owner: me
      
      game.world.add cell = new Cell game: game, owner: me, x: 0
      game.world.add cell = new Cell game: game, owner: me, x: 0
      
      node.bind 'affectedCells:add', spy = jasmine.createSpy()
      
      game.world.add cell = new Cell game: game, owner: me, x: 0
      
      expect(spy).not.toHaveBeenCalled()


    it "triggers affectedCells:remove when a cell is removed", ->
      game = new Game
      game.world.add me = new Player game: game
      game.world.add cell = new Cell game: game, owner: me, x: 0
      
      node = new EnhancerNode game: game, owner: me
      
      node.bind 'affectedCells:remove', spy = jasmine.createSpy()
      game.world.remove cell
      
      expect(spy).toHaveBeenCalledWith cell


    it "does not trigger affectedCells:remove when an unaffected cell is removed", ->
      game = new Game
      game.world.add me = new Player game: game
      game.world.add fiz = new Player game: game
      game.world.add cell = new Cell game: game, owner: fiz, x: 0
      
      node = new EnhancerNode game: game, owner: me
      
      node.bind 'affectedCells:remove', spy = jasmine.createSpy()
      game.world.remove cell
      
      expect(spy).not.toHaveBeenCalled()