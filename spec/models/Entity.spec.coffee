Entity = require('../../app/models/Entity').Entity


describe 'Entity', ->
  it 'throws without game', ->
    expect ->
      new Entity
    .toThrow()

  it 'is creatable with game', ->
    new Entity game: {}

  describe 'on update', ->
    it 'sets the attributes', ->
      myEntity = new Entity someProperty: 1, game: {}
      
      json = myEntity.toJSON()
      json.someProperty = 2
      
      myEntity.trigger 'update', json
      
      expect(myEntity.get 'someProperty').toBe 2