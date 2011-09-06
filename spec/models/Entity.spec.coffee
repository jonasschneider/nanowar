Entity = require('../../app/models/Entity').Entity


describe 'Entity', ->
  it 'throws without game', ->
    expect ->
      new Entity
    .toThrow()

  it 'is creatable with game', ->
    new Entity game: {}