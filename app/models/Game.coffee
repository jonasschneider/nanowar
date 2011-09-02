#= require <nanowar>
#= require "Cells"
#= require "Players"

Nanowar = window.Nanowar

Nanowar.uniqueIdCount = 1

class Nanowar.Game extends Backbone.Model
  defaults:
    tickLength: 1000 / 10
    cellProductionMultiplier: 1 / 100
    
    cells:  new Nanowar.Cells
    players:  new Nanowar.Players
  
  initialize: () ->
    @cells = @get 'cells'
    @players = @get 'players'

    @ticks = 0
    
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