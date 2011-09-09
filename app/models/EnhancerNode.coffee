#= require <nanowar>
#= require "Entity"
#= require "Player"

if exports?
  onServer = true
  Backbone = require('../vendor/backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Player = require('./Player').Player
  Nanowar.Entity = require('./Entity').Entity
  _ = require('../vendor/underscore')
  Nanowar.util = require('../helpers/util').util
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar
  _    = window._

class root.EnhancerNode extends Nanowar.Entity
  defaults:
    x: 0
    y: 0
  
  relationSpecs:
    owner:
      relatedModel: Nanowar.Player
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
      Nanowar.util.distance(@position(), cell.position())
    .first(2).value()