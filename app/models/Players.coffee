#= require <nanowar>
#= require "Player"

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Player = require('./Player')
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root      = Nanowar

class root.Players extends Backbone.Collection
  model: Nanowar.Player
  
  initialize: ->
    @bind 'add', (player) =>
      @trigger 'publish', { add: player }
      
    @bind 'update', (data) =>
      @add data.add if data.add
  
  add: (player) ->
    colors = ["red", "blue", "green", "yellow"]
    player.color = colors[@size()]
    super