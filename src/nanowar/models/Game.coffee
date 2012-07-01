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

      @serverUpdates = {}

      @bind 'update', (e) =>
        console.log 'game got update', e

        if e.tells
          @tellQueue.push(tell) for tell in e.tells

        #if e.ticks?
        # @ticks = e.ticks

        if e.entityChanges
          @serverUpdates[e.tick] = { entityChanges: e.entityChanges }

        
        #@entities.trigger 'update', e.entities if e.entities?
        
        #if e.sendFleetCommand?
        #  e.sendFleetCommand.game = this
        #  cmd = new SendFleetCommand e.sendFleetCommand
        #  cmd.run()
        #  #@trigger 'publish', {sendFleet: e.sendFleet} if onServer?
        #
        @run() if e.run
      
      

      @ticks = 0
      @running = false
      @stopping = false
      @tellQueue = []
      @sendQueue = []
    
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
      tell = to: '$self', what: what, with: args
      if @get('onServer')
        @tellQueue.push tell
      else
        @sendQueue.push tell

    # private?

    runTell: (tell) ->
      console.log("running:", tell)
      #if tell.to == '$self' # TODO: ONLY WORKS FOR TELLS TO GAME AT THIS TIME!
      this[tell.what].call(this, tell.with...)

    addPlayer: (player) ->
      @entities.add player

    sendFleet: (from, to) ->
      fleet = new Fleet 
        from: from
        to: to
        game: this
      
      if fleet.launch()
        console.log "launched a fleet"
        @entities.add fleet
      else
        console.log "fleet failed to launch"

    runTells: (tells) ->
      @runTell(tell) for tell in tells

    sendClientTells: ->
      if @sendQueue.length > 0
        @trigger 'publish', tick: @ticks, tells: @sendQueue
        @sendQueue = []

    runTellQueue: ->
      @runTells(@tellQueue)
      @tellQueue = []
      

    # UNSPECCED
    run: -> # probably blows up synchronisation
      console.log "GOGOGOG"
      @trigger 'publish', run: true if @get('onServer')

      @schedule()
    
    schedule: ->
      setTimeout =>
        @tick()
      , @get 'tickLength'

    executeServerUpdatesForTick: (tick) ->
      if upd = @serverUpdates[tick]
        (@entities.trigger 'update', change) for change in upd.entityChanges
        delete @serverUpdates[tick]
        true
      else
        false
    
    halt: ->
      @stopping = true
    
    tick: ->
      @executeServerUpdatesForTick(0)

      @schedule() unless @stopping # FIXME: detect if tick is taking too long
      @ticks++
      console.log "=== TICKING" if @get('onServer')
      #@trigger 'tick'

      if @get('onServer')
        @updateAndPublish()
      else
        @sendClientTells()
        res = @executeServerUpdatesForTick(@ticks)

        throw "did not yet receive update for tick #{@ticks}" unless res
        # TODO: interpolate

      @entities.each (e) =>
        @entities.remove(e) if e.get('dead')

      console.log "=== TICK DONE." if @get('onServer')
    
    updateAndPublish: ->
      entityChanges = []

      @entities.bind 'publish', (change) ->
        entityChanges.push change

      @runTellQueue()
      (ent.update && ent.update()) for ent in @entities.models

      if winner = @getWinner()
        @trigger 'end', winner: winner
        @halt()

      @trigger 'publish', tick: @ticks, entityChanges: entityChanges

    ticksToTime: (ticks) ->
      ticks * @get 'tickLength'