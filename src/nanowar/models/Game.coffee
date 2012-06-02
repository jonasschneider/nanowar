define (require) ->
  Cell              = require('./Cell')
  Player            = require('./Player')
  Fleet             = require('./Fleet')
  EnhancerNode      = require('./EnhancerNode')
  SendFleetCommand  = require('../commands/SendFleetCommand')
  EntityCollection  = require('./EntityCollection')
  _                 = require 'underscore'
  Backbone          = require 'backbone'
  $          = require 'jquery'

  return class Game extends Backbone.Model
    defaults:
      tickLength: 1000 / 10
    
    initialize: ->
      etypes = Cell: Cell, Player: Player, Fleet: Fleet, EnhancerNode: EnhancerNode
      @entities = new EntityCollection [], game: this, types: etypes

      @bind 'start', =>
        @trigger 'publish', 'start'

      @bind 'update', (e) =>
        console.log 'game got update', e

        @runTells(e.tells) if e.tells

        #if e.ticks?
        # @ticks = e.ticks
        
        #@entities.trigger 'update', e.entities if e.entities?
        
        #if e.sendFleetCommand?
        #  e.sendFleetCommand.game = this
        #  cmd = new SendFleetCommand e.sendFleetCommand
        #  cmd.run()
        #  #@trigger 'publish', {sendFleet: e.sendFleet} if onServer?
        #
        #@run() if e == 'start'
      
      

      @ticks = 0
      @running = false
      @stopping = false
      @tellQueue = []
    
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

    loadMap: ->
      cells = [
        c1 = new Cell {x: 350, y: 100, size: 50, game: this}
        new Cell {x: 350, y: 300, size: 30, game: this, owner: @getPlayers()[0]}
        new Cell {x: 100, y: 200, size: 50, game: this}
        new Cell {x: 500, y: 200, size: 50, game: this}
        new Cell {x: 550, y: 100, size: 30, game: this, owner: @getPlayers()[1]}
        new EnhancerNode x: 440, y: 120, game: this, owner: @getPlayers()[1]
      ]
      @entities.add cells
    
    tellSelf: (what, args...) ->
      @tellQueue.push(to: '$self', what: what, with: args)

    # private?

    runTell: (tell) ->
      #if tell.to == '$self'
      console.log(tell)
      this[tell.what].call(this, tell.with...)

    addPlayer: (player) ->
      @entities.add player

    runTells: (tells) ->
      @runTell(tell) for tell in tells

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

      if @tellQueue.length > 0
        @trigger 'publish', tick: @ticks, tells: @tellQueue
        @runTells(@tellQueue)
        @tellQueue = []

      if winner = @getWinner()
        @trigger 'end', winner: winner
        @halt()
    
    ticksToTime: (ticks) ->
      ticks * @get 'tickLength'