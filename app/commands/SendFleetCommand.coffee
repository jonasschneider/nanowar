#= require <nanowar>
#= require <helpers/RelationalModel>
#= require <models/Fleet>
#= require <models/Cell>

if exports?
  onServer = true
  Backbone = require('../vendor/backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Fleet = require('../models/Fleet').Fleet
  Nanowar.Cell = require('../models/Cell').Cell
  Nanowar.Entity = require('../models/Entity').Entity
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

class root.SendFleetCommand extends Nanowar.Entity
  relationSpecs:
    from:
      relatedModel: Nanowar.Cell
      directory: 'game.entities'
    to:
      relatedModel: Nanowar.Cell
      directory: 'game.entities'
      
  initialize: ->
    
  run: ->
    fleet = new Nanowar.Fleet 
      from: @get('from')
      to: @get('to')
      game: @game
    
    if fleet.launch()
      @game.entities.add fleet