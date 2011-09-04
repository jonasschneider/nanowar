#= require <nanowar>
#= require <helpers/RelationalModel>
#= require <models/Fleet>
#= require <models/Cell>

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Fleet = require('../models/Fleet').Fleet
  Nanowar.Cell = require('../models/Cell').Cell
  Nanowar.RelationalModel = require('../helpers/RelationalModel.coffee').RelationalModel
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

class root.SendFleetCommand extends Nanowar.RelationalModel
  relationSpecs:
    from:
      relatedModel: Nanowar.Cell
      directory: 'game.cells'
    to:
      relatedModel: Nanowar.Cell
      directory: 'game.cells'
      
  initialize: ->
    @game = @get('game')
    @set game: undefined
    throw "SendFleetCommand needs game" unless @game
    
    super
    
  run: ->
    fleet = new Nanowar.Fleet 
      from: @get('from')
      to: @get('to')
      game: @game
    
    fleet.launch()
    
    @game.fleets.add fleet