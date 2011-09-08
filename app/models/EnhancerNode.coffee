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