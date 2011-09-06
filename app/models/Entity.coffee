#= require <nanowar>
#= require "Entity"
#= require <helpers/RelationalModel>

if exports?
  onServer = true
  Backbone = require('../vendor/backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.RelationalModel = require('../helpers/RelationalModel').RelationalModel
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar


class root.Entity extends Nanowar.RelationalModel
  constructor: (attributes, options) ->
    if attributes && attributes.game
      @game = attributes.game
      delete attributes.game
    else
      throw "Entity needs game"
    
    @bind 'update', (data) ->
      @set data
    
    super