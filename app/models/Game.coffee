#= require <nanowar>

Nanowar = window.Nanowar
Log = Nanowar.Log
$ = window.$

Nanowar.uniqueIdCount = 1

class Nanowar.Game extends Backbone.Model
  defaults:
    tickLength: 1000 / 10
    cellProductionMultiplier: 1 / 100
  
  initialize: () ->
    @cells = new Nanowar.models.CellCollection

    @ticks = 0
    @last_tick = 0
    @players = []
    @events = []
    
    @human_player = null
    
    
  add_player: (player) ->
    colors = ["red", "blue", "green", "yellow"]
    @players.push player
    player.set_game this
    player.color = colors[@players.length-1]
    
  set_human_player: (player) ->
    @human_player = player
  
  tick: ->
    @ticks++
    
    @trigger 'tick'
    
    @check_for_end()
  
  check_for_end: ->
    owners = []
    @cells.each (cell) ->
      cellOwner = cell.get 'owner'
      owners.push cellOwner if cellOwner? && owners.indexOf(cellOwner) == -1
    
    if owners.length == 1
      alert("Game over")
      @trigger 'end'