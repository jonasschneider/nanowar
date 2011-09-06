#= require <nanowar>
#= require <helpers/IdentifyingCollection>

if exports?
  onServer = true
  Backbone = require('../vendor/backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.IdentifyingCollection = require('../helpers/IdentifyingCollection').IdentifyingCollection
  _               = require 'underscore'
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar
  _               = window._

class root.EntityCollection extends Nanowar.IdentifyingCollection
  initialize: (models, options) ->
    unless options && options.types?
      throw "Need types"
    
    @types = {}
    _(options.types).each (klass) =>
      @types[klass.getType()] = klass
      
    unless @game = options.game
      throw "Need game" 
    
    @bind 'add', (entity) =>
      @trigger 'publish', { add: entity }
      
    @bind 'update', (data) =>
      if data.add?
        @add data.add
        
      if data.change?
        @get(data.change.id).trigger 'update', data.change
        
    @bind 'change', (entity) =>
      @trigger 'publish', { change: entity }

  _add: (entity) ->
    if _(@types).any((type) ->
      entity instanceof type
    )
      super entity
    else
      klass = @types[entity.type]
      unless klass
        typeNames = _(@types).map (klass, name) -> name
        throw "I dont know what to do with #{JSON.stringify entity}. Known types are [#{typeNames.join(', ')}]"
      entity.game = @game
      entityObj = new klass entity
      super entityObj