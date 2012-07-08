define (require) ->
  Player = require('./Player')
  Entity = require('nanowar/Entity')
  _      = require('underscore')
  util = require('../helpers/util')

  return class EnhancerNode extends Entity
    defaults:
      x: 0
      y: 0
    
    relationSpecs:
      owner:
        relatedModel: Player
        directory: 'game.world'
    
    initialize: ->
      @_previousAffectedCells = @affectedCells()
      
      @game.world.bind 'add',    @update, this
      @game.world.bind 'change', @update, this
      @game.world.bind 'remove', @update, this
    
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