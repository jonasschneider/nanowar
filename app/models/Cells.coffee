#= require <nanowar>
#= require "Cell"
#= require <helpers/IdentifyingCollection>

if exports?
  onServer = true
  Backbone = require('../vendor/backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Cell = require('./Cell')
  Nanowar.IdentifyingCollection = require('../helpers/IdentifyingCollection').IdentifyingCollection
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

class root.Cells extends Nanowar.IdentifyingCollection
  model: Nanowar.Cell
  
  initialize: (models, options) ->
    options || (options = {})
    @game = options.game
    throw "need game" unless @game
    
    @bind 'add', (cell) =>
      @trigger 'publish', { add: cell }
      
    @bind 'update', (data) =>
      if data.add?
        data.add.game = @game
        @add data.add
        
      if data.change?
        @get(data.change.id).set data.change
        
    @bind 'change', (cell) =>
      @trigger 'publish', { change: cell }