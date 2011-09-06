#= require <nanowar>
#= require "Cell"
#= require "Player"
#= require "Fleet"
#= require <commands/SendFleetCommand>

if exports?
  onServer = true
  Backbone = require('../vendor/backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Cell    = require('./Cell').Cell
  Nanowar.Player = require('./Player').Player
  Nanowar.Fleet  = require('./Fleet').Fleet
  Nanowar.SendFleetCommand  = require('../commands/SendFleetCommand').SendFleetCommand
  Nanowar.EntityCollection = require('./EntityCollection').EntityCollection
  _               = require 'underscore'
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar
  _         = window._

class root.Game extends Backbone.Model
  defaults:
    tickLength: 1000 / 10
  
  initialize: ->
    @entities = new Nanowar.EntityCollection [], game: this, types: [Nanowar.Cell, Nanowar.Player]

    if onServer?
      @entities.bind 'publish', (e) =>
        @trigger 'publish',
          entities: e
          ticks: @ticks
      
      @bind 'start', =>
        @trigger 'publish', 'start'

    @bind 'update', (e) =>
      if e.ticks?
        @ticks = e.ticks
      
      @entities.trigger 'update', e.entities if e.entities?
      
      if e.sendFleetCommand?
        e.sendFleetCommand.game = this
        cmd = new Nanowar.SendFleetCommand e.sendFleetCommand
        cmd.run()
        #@trigger 'publish', {sendFleet: e.sendFleet} if onServer?
      
      @run() if e == 'start'
    
    

    @ticks = 0
    @running = false
    @stopping = false
  
  getEntities: (type) ->
    @entities.select (entity) -> entity instanceof type
  
  getCells: ->
    @getEntities Nanowar.Cell

  getPlayers: ->
    @getEntities Nanowar.Player
  
  getWinner: ->
    owners = []
    _(@getCells()).each (cell) =>
      cellOwner = cell.get 'owner'
      owners.push cellOwner if cellOwner? && owners.indexOf(cellOwner) == -1
    
    if owners.length == 1
      owners[0]
    else
      null
  
  # UNSPECCED
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
    @schedule() unless @stopping
    @ticks++
    @trigger 'tick'
    
    if winner = @getWinner()
      @trigger 'end', winner: winner
      @halt()
  
  ticksToTime: (ticks) ->
    ticks * @get 'tickLength'