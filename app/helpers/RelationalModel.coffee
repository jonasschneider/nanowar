onServer = false
if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  _ = require('underscore')
  uuid = require('node-uuid');
  Nanowar.Player = require('../models/Player').Player
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar
  _ = window._


# 1. Don't forget to call super (after setting directory)
# Directory API: get(id) => model

class root.RelationalModel extends Backbone.Model
  toJSON: ->
    oldValues = {}
    dataz = {}
    _(@relationSpecs).each (options, name) =>
      dataz[name] = 
        if oldValues[name] = @get(name)
          { type: 'serializedRelation', model: options.relatedModelName, id: oldValues[name].id, toJSON: ->
            this
          }
        else
          null
    @set dataz, silent: true
    val = super
    _(@relationSpecs).each (options, name) =>
      dataz[name] = oldValues[name]
    @set dataz, silent: true
    val

  initialize: ->
    _(@relationSpecs).each (options, name) =>
      options.relatedModelName ||= options.relatedModel.toString().match(/function (.+)\(\)/)[1]
      
      if(options.directory)
        # traverse path to directory
        segments = options.directory.split '.'
        options.directoryObject = this
        options.directoryObject = options.directoryObject[segments.shift()] until segments.length == 0

      @bind 'change:'+name, =>
        @_updateRelation(name)
      
      @_updateRelation(name)

  _updateRelation: (name) ->
    options = @relationSpecs[name]

    dataz = {}
    dataz[name] =
      if value = @get(name)
        deserialized = false
        if value instanceof Backbone.Model
          id = value.get('id')
        else if value.type? && value.type == 'serializedRelation'
          if value.model != options.relatedModelName
            throw "Expected serialized relation of a #{options.relatedModelName} model, not a #{value.model} model"
          id = value.id
        else
          try
            value = JSON.stringify value
          finally
            throw "Expected an instance of #{options.relatedModelName}, not #{value}"

        if id && options.directoryObject && inDir = options.directoryObject.get id
          inDir
        else
          throw "#{options.relatedModelName} is not registered in this.#{options.directory}"

      else
        null
    @set dataz
    ###
    @bind 'change:owner', =>
      if @get('owner') && @get('owner') not instanceof Nanowar.Player
        throw "Not instantiating new player here" unless @get('owner').id
        
        if owner = @game.players.get(@get('owner').id)
          @set { owner: owner }, silent: true
        else
          
          throw "Couldn't find player with id " + @get('owner').id
        
    @trigger 'change:owner'
    ###