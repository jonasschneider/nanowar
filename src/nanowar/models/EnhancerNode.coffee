define (require) ->
  Player = require('./Player')
  Entity = require('./Entity')
  _      = require('underscore')
  util = require('../helpers/util')

  return class EnhancerNode extends Entity
    defaults:
      x: 0
      y: 0
    
    relationSpecs:
      owner:
        relatedModel: Player
        directory: 'game.entities'
    
    initialize: ->
      @_previousAffectedCells = @affectedCells()
      
      @game.entities.bind 'add',    @update, this
      @game.entities.bind 'change', @update, this
      @game.entities.bind 'remove', @update, this
    
    update: ->
      newly = @affectedCells()
      previously = @_previousAffectedCells
      
      _(newly).chain().difference(previously).each (c) =>
        @trigger 'affectedCells:add', c
      
      _(previously).chain().difference(newly).each (c) =>
        @trigger 'affectedCells:remove', c
      
      @_previousAffectedCells = newly
      
    position: ->
      x: @get 'x'
      y: @get 'y'
    
    affectedCells: ->
      _(@game.getCells()).chain()
      .select (cell) =>
        cell.get('owner') == @get('owner')
      .sortBy (cell) =>
        util.distance(@position(), cell.position())
      .first(2).value()