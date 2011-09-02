#= require <nanowar>
#= require "Cells"
#= require "Players"

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Cell = require('./Cell').Cell
  Nanowar.Cells = require('./Cells').Cells
  Nanowar.Players = require('./Players').Players
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

class root.Game extends Backbone.Model
  defaults:
    tickLength: 1000 / 10
  
  initialize: ->
    console.log("making game")
    
    @cells =  new Nanowar.Cells
    @players =   new Nanowar.Players
    
    @cells.bind 'publish', (e) =>
      @trigger 'publish',
        cells: e
    
    @bind 'update', (e) =>
      @cells.trigger 'update', e.cells if e.cells?
      @players.trigger 'update', e.players if e.players?
    
    
    @bind 'tick', ->
      _(@cells).each (cell) ->
        cell.trigger 'tick', @ticks
    , this

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