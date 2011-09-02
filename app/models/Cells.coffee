#= require <nanowar>
#= require "Cell"
#= require <helpers/IdentifyingCollection>

if exports?
  onServer = true
  Backbone = require('backbone')
  
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
    
    @bind 'add', (cell) =>
      @trigger 'publish', { add: cell }
      
    @bind 'update', (data) =>
      if data.add?
        data.add.game = @game
        @add data.add