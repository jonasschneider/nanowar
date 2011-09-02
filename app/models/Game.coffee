#= require <nanowar>
#= require "Cells"
#= require "Fleets"
#= require "Players"

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Cell    = require('./Cell').Cell
  Nanowar.Cells   = require('./Cells').Cells
  Nanowar.Players = require('./Players').Players
  Nanowar.Fleets  = require('./Fleets').Fleets
  _               = require 'underscore'
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

class root.Game extends Backbone.Model
  defaults:
    tickLength: 1000 / 10
  
  initialize: ->
    console.log("making game")
    
    @cells =  new Nanowar.Cells [], game: this
    @players =  new Nanowar.Players
    @fleets =  new Nanowar.Fleets [], game: this
    
    @cells.bind 'publish', (e) =>
      @trigger 'publish',
        cells: e
        
    @players.bind 'publish', (e) =>
      @trigger 'publish',
        players: e
    
    @fleets.bind 'publish', (e) =>
      @trigger 'publish',
        fleets: e
    
    @bind 'update', (e) =>
      @cells.trigger 'update', e.cells if e.cells?
      @players.trigger 'update', e.players if e.players?
      @fleets.trigger 'update', e.fleets if e.fleets?
      @run() if e == 'start'
    
    @bind 'start', =>
      @trigger 'publish', 'start'

    @ticks = 0
    @running = false
    @stopping = false
  
  check_for_end: ->
    owners = []
    @cells.each (cell) ->
      cellOwner = cell.get 'owner'
      owners.push cellOwner if cellOwner? && owners.indexOf(cellOwner) == -1
    
    if owners.length == 1
      console.log "Game over"
      @halt()
      @trigger 'end', winner: owners[0]
  
  run: ->
    console.log "GOGOGOG"
    
    @trigger 'start'
    
    @schedule()
    
  schedule: ->
    setTimeout =>
      @tick()
    , @get 'tickLength'
  
  halt: ->
    @stopping = true
  
  tick: ->
    @ticks++
    @trigger 'tick'
    @check_for_end()
    @schedule() unless @stopping
