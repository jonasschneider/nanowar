EntityCollection = require('../../app/models/EntityCollection').EntityCollection
Backbone = require('../../app/vendor/backbone')

class MyEntity extends Backbone.Model

describe 'EntitiyCollection', ->
  it 'publishes on add', ->
    coll = new EntityCollection
    
    spy = jasmine.createSpy()
    coll.bind 'publish', spy
    
    myEntity = new MyEntity
    
    coll.add myEntity
    
    expect(spy).toHaveBeenCalled()
    expect(spy.mostRecentCall.args[0].add).toBe myEntity
    
  it 'publishes on change', ->
    coll = new EntityCollection
    
    spy = jasmine.createSpy()
    coll.bind 'publish', spy
    
    myEntity = new MyEntity
    coll.add myEntity
    
    myEntity.set someProperty: 'hi'
    
    expect(spy).toHaveBeenCalled()
    expect(spy.mostRecentCall.args[0].change).toBe myEntity
    
  it 'adds a cell when updated', ->
    coll = new EntityCollection
    
    myEntity = new MyEntity
    
    coll.trigger 'update', { add: myEntity }
    
    expect(coll.first()).toBe myEntity

  it 'changes a cell when updated', ->
    coll = new EntityCollection
    
    myEntity = new MyEntity someProperty: 1
    coll.add myEntity
    
    json = myEntity.toJSON()
    json.someProperty = 2
    
    coll.trigger 'update', { change: json }
    
    expect(coll.get(myEntity.id).get 'someProperty').toBe 2