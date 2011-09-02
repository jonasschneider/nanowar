#= require <nanowar>
#= require "Player"

Nanowar = window.Nanowar

class Nanowar.Players extends Backbone.Collection
  model: Nanowar.Player
  
  add: (player) ->
    colors = ["red", "blue", "green", "yellow"]
    player.color = colors[@size()]
    super