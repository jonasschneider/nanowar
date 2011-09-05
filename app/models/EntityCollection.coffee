#= require <nanowar>

if exports?
  onServer = true
  Backbone = require('../vendor/backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.IdentifyingCollection = require('../helpers/IdentifyingCollection').IdentifyingCollection
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

class root.EntityCollection extends Nanowar.IdentifyingCollection
  
  initialize: (models, options) ->
    
    @bind 'add', (entity) =>
      @trigger 'publish', { add: entity }
      
    @bind 'update', (data) =>
      if data.add?
        @add data.add
        
      if data.change?
        @get(data.change.id).set data.change
        
    @bind 'change', (entity) =>
      @trigger 'publish', { change: entity }