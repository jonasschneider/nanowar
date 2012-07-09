define (require) ->
  Player = require('./Player')
  Entity = require('nanowar/Entity')
  _      = require('underscore')
  util = require('../helpers/util')

  return class EnhancerNode extends Entity
    attributeSpecs:
      x: 0
      y: 0

      owner_id: 0
    
    initialize: ->
      @_previousAffectedCells = @affectedCells()

    update: ->
      newly = @affectedCells()
      previously = @_previousAffectedCells
      
      _(newly).chain().difference(previously).each (c) =>
        @message 'affectedCells:add', c
      
      _(previously).chain().difference(newly).each (c) =>
        @message 'affectedCells:remove', c
      
      @_previousAffectedCells = newly
      
    position: ->
      x: @get 'x'
      y: @get 'y'
    
    affectedCells: ->
      _(@collection.getEntitiesOfType('Cell')).chain()
      .select (cell) =>
        cell.getRelation('owner') == @getRelation('owner')
      .sortBy (cell) =>
        util.distance(@position(), cell.position())
      .first(2).value()