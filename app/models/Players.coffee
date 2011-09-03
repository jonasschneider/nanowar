#= require <nanowar>
#= require "Player"
#= require <helpers/IdentifyingCollection>

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Player = require('./Player')
  Nanowar.IdentifyingCollection = require('../helpers/IdentifyingCollection').IdentifyingCollection
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root      = Nanowar

class root.Players extends Nanowar.IdentifyingCollection
  model: Nanowar.Player
  
  initialize: ->
    @bind 'add', (player) =>
      @trigger 'publish', { add: player }
      
    @bind 'update', (data) =>
      @add data.add if data.add
  
  _add: (player, opts) ->
    player = @_prepareModel player, opts
    colors = ["#A0483E", "#666885", "green", "yellow"]
    player.set color: colors[@size()] unless player.get 'color'
    
    super player, opts