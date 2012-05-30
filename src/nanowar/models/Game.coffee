define (require) ->
  Cell              = require('./Cell')
  Player            = require('./Player')
  Fleet             = require('./Fleet')
  EnhancerNode      = require('./EnhancerNode')
  SendFleetCommand  = require('../commands/SendFleetCommand')
  EntityCollection  = require('./EntityCollection')
  _                 = require 'underscore'
  Backbone          = require 'backbone'

  return class Game extends Backbone.Model
    defaults:
      tickLength: 1000 / 10
    
    initialize: ->
      @entities = new EntityCollection [], game: this, types: [Cell, Player, Fleet, EnhancerNode]

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
          cmd = new SendFleetCommand e.sendFleetCommand
          cmd.run()
          #@trigger 'publish', {sendFleet: e.sendFleet} if onServer?
        
        @run() if e == 'start'
      
      

      @ticks = 0
      @running = false
      @stopping = false
    
    getEntities: (type) ->
      @entities.select (entity) -> entity instanceof type
    
    getCells: ->
      @getEntities Cell

    getPlayers: ->
      @getEntities Player
    
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