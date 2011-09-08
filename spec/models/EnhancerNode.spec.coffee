EnhancerNode = require('../../app/models/EnhancerNode').EnhancerNode
Cell = require('../../app/models/Cell').Cell
Game = require('../../app/models/Game').Game
Player = require('../../app/models/Player').Player

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
      game.entities.add me = new Player game: game
      game.entities.add cell = new Cell game: game, owner: me
      node = new EnhancerNode game: game, owner: me
      
      expect(node.affectedCells().length).toBe 1
      expect(node.affectedCells()[0]).toBe cell
    
    it 'does not affect cells owned by others', ->
      game = new Game
      game.entities.add me = new Player game: game
      game.entities.add fiz = new Player game: game
      game.entities.add cell = new Cell game: game, owner: fiz
      node = new EnhancerNode game: game, owner: me
      
      expect(node.affectedCells().length).toBe 0
      
    it 'only affects the nearest 2 cells', ->
      game = new Game
      game.entities.add me = new Player game: game
      game.entities.add cell1 = new Cell game: game, owner: me, x: 100, y: 0
      game.entities.add new Cell game: game, x: 0, y: 0
      node = new EnhancerNode game: game, owner: me, x: 80, y: 0
      
      expect(node.affectedCells().length).toBe 1
      expect(node.affectedCells()[0]).toBe cell1
      
      game.entities.add new Cell game: game, x: 80, y: 0
      game.entities.add cell2 = new Cell game: game, owner: me, x: 50, y: 0
      
      expect(node.affectedCells().length).toBe 2
      expect(node.affectedCells()[0]).toBe cell1
      expect(node.affectedCells()[1]).toBe cell2
      
      game.entities.add new Cell game: game, owner: me, x: 30, y: 0
      game.entities.add cell3 = new Cell game: game, owner: me, x: 60, y: 0 # nearer than cell 2
      
      expect(node.affectedCells().length).toBe 2
      expect(node.affectedCells()[0]).toBe cell1
      expect(node.affectedCells()[1]).toBe cell3