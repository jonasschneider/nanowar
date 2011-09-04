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


# 1. Don't forget to call super

class root.RelationalModel extends Backbone.Model
  defaults:
    owner: null
  initialize: ->
    _(@relations).each (options, name) =>

      options.relatedModelName ||= options.relatedModel.toString().match(/function (.+)\(\)/)[1]

      dataz = {}
      dataz[name] = 
        if value = @get(name)
          if value instanceof options.relatedModel
            value
          else
            throw "Expected an instance of #{options.relatedModelName}"
        else
          null
      @set dataz
    
    @bind 'change:owner', =>
      if @get('owner') && @get('owner') not instanceof Nanowar.Player
        throw "Not instantiating new player here" unless @get('owner').id
        
        if owner = @game.players.get(@get('owner').id)
          @set { owner: owner }, silent: true
        else
          
          throw "Couldn't find player with id " + @get('owner').id
        
    @trigger 'change:owner'