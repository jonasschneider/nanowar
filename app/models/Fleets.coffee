#= require <nanowar>
#= require "Fleet"
#= require <helpers/IdentifyingCollection>

if exports?
  onServer = true
  Backbone = require('../vendor/backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Fleet = require('./Fleet').Fleet
  Nanowar.IdentifyingCollection = require('../helpers/IdentifyingCollection').IdentifyingCollection
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root      = Nanowar

class root.Fleets extends Nanowar.IdentifyingCollection
  model: Nanowar.Fleet
  
  initialize: (models, options) ->
    options || (options = {})
    @game = options.game
    throw "need game" unless @game
    
    @bind 'add', (fleet) =>
      @trigger 'publish', { add: fleet }
      
    @bind 'update', (data) =>
      if data.add
        data.add.game = @game
        @add data.add