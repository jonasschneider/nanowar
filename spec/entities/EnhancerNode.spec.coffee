EnhancerNode =  require('nanowar/entities/EnhancerNode')
Player = require('nanowar/entities/Player')
Cell = require('nanowar/entities/Cell')
World = require('dyz/World')

describe 'EnhancerNode', ->
  beforeEach ->
    @world = new World Cell: Cell, Player: Player, EnhancerNode: EnhancerNode
    
  describe '#affectedCells', ->
    it 'returns [] when there are no cells', ->
      node = @world.spawn 'EnhancerNode'
      expect(node.affectedCells().length).toBe 0
      
    it 'affects a cell owned by the player', ->
      me = @world.spawn 'Player' 
      cell = @world.spawn 'Cell', owner_id: me.id
      node = @world.spawn 'EnhancerNode', owner_id: me.id
      
      expect(node.affectedCells().length).toBe 1
      expect(node.affectedCells()[0]).toBe cell
    
    it 'does not affect cells owned by others', ->
      me = @world.spawn 'Player'
      fiz = @world.spawn 'Player'
      cell = @world.spawn 'Cell', owner_id: fiz.id
      node = @world.spawn 'EnhancerNode', owner_id: me.id
      
      expect(node.affectedCells().length).toBe 0
      
    it 'only affects the nearest 2 cells', ->
      me = @world.spawn 'Player'
      cell1 = @world.spawn 'Cell', owner_id: me.id, x: 100, y: 0
      @world.spawn 'Cell', x: 0, y: 0
      
      node = @world.spawn 'EnhancerNode', owner_id: me.id, x: 80, y: 0
      
      expect(node.affectedCells().length).toBe 1
      expect(node.affectedCells()[0]).toBe cell1
      
      @world.spawn 'Cell', x: 80, y: 0
      cell2 = @world.spawn 'Cell', owner_id: me.id, x: 50, y: 0
      
      expect(node.affectedCells().length).toBe 2
      expect(node.affectedCells()[0]).toBe cell1
      expect(node.affectedCells()[1]).toBe cell2
      
      @world.spawn 'Cell', owner_id: me.id, x: 30, y: 0
      cell3 = @world.spawn 'Cell', owner_id: me.id, x: 60, y: 0 # nearer than cell 2
      
      expect(node.affectedCells().length).toBe 2
      expect(node.affectedCells()[0]).toBe cell1
      expect(node.affectedCells()[1]).toBe cell3


  it 'triggers affectedCells:add when a new cell gets affected', ->
    me = @world.spawn 'Player'
    
    node = @world.spawn 'EnhancerNode', owner_id: me.id
    node.bind 'affectedCells:add', spy = jasmine.createSpy()
    
    cell1 = @world.spawn 'Cell', owner_id: me.id

    node.update()

    expect(spy).toHaveBeenCalled()
    expect(spy.mostRecentCall.args[0]).toBe cell1.id


  it "triggers affectedCells:remove when an affected cell's owner changes", ->
    me = @world.spawn 'Player'
    fiz = @world.spawn 'Player'
    
    node = @world.spawn 'EnhancerNode', owner_id: me.id
    node.bind 'affectedCells:remove', spy = jasmine.createSpy()
    
    cell = @world.spawn 'Cell', owner_id: me.id

    node.update()
    expect(spy).not.toHaveBeenCalled()

    cell.setRelation 'owner', fiz
    node.update()
    
    expect(spy).toHaveBeenCalledWith cell.id

  it "doesn't trigger when other cell attributes change", ->
    me = @world.spawn 'Player'
    fiz = @world.spawn 'Player'
    
    node = @world.spawn 'EnhancerNode', owner_id: me.id
    node.bind 'affectedCells:remove', spy = jasmine.createSpy()
    
    cell = @world.spawn 'Cell', owner_id: me.id

    cell.set x: 50
    
    node.update()
    expect(spy).not.toHaveBeenCalled()


  it "doesn't trigger when an unaffected cell changes", ->
    me = @world.spawn 'Player'
    fiz = @world.spawn 'Player'
    p3 = @world.spawn 'Player'

    cell = @world.spawn 'Cell', owner_id: fiz.id
    
    node = @world.spawn 'EnhancerNode', owner_id: me.id
    node.bind 'affectedCells:remove', spy = jasmine.createSpy()
    
    cell.setRelation 'owner', p3
    
    node.update()
    expect(spy).not.toHaveBeenCalled()


  it "triggers affectedCells:add when a cell changes owner", ->
    me = @world.spawn 'Player'
    fiz = @world.spawn 'Player'
    
    node = @world.spawn 'EnhancerNode', owner_id: me.id
    node.bind 'affectedCells:add', spy = jasmine.createSpy()
    
    cell = @world.spawn 'Cell', owner_id: fiz.id

    node.update()
    expect(spy).not.toHaveBeenCalled()
    
    cell.setRelation 'owner', me
    
    node.update()
    expect(spy).toHaveBeenCalledWith(cell.id)


  it "doesn't trigger affectedCells:add when the list is already full", ->
    me = @world.spawn 'Player'

    node = @world.spawn 'EnhancerNode', owner_id: me.id
    
    @world.spawn 'Cell', owner_id: me.id
    @world.spawn 'Cell', owner_id: me.id

    node.update()
    node.bind 'affectedCells:add', spy = jasmine.createSpy()
    @world.spawn 'Cell', owner_id: me.id

    node.update()
    expect(spy).not.toHaveBeenCalled()


  it "triggers affectedCells:remove when a cell is removed", ->
    me = @world.spawn 'Player'

    node = @world.spawn 'EnhancerNode', owner_id: me.id
    node.bind 'affectedCells:remove', spy = jasmine.createSpy()

    cell = @world.spawn 'Cell', owner_id: me.id

    node.update()

    @world.remove(cell)

    node.update()
    expect(spy).toHaveBeenCalledWith cell.id


  it "does not trigger affectedCells:remove when an unaffected cell is removed", ->
    me = @world.spawn 'Player'
    fiz = @world.spawn 'Player'

    node = @world.spawn 'EnhancerNode', owner_id: me.id
    node.bind 'affectedCells:remove', spy = jasmine.createSpy()

    cell = @world.spawn 'Cell', owner_id: fiz.id

    node.update()
    
    @world.remove(cell)

    node.update()
    expect(spy).not.toHaveBeenCalled()