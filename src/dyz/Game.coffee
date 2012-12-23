define (require) ->
  Cell              = require('nanowar/entities/Cell')
  Player            = require('nanowar/entities/Player')
  Fleet             = require('nanowar/entities/Fleet')
  EnhancerNode      = require('nanowar/entities/EnhancerNode')
  World  = require('dyz/World')
  _                 = require 'underscore'
  Backbone          = require 'backbone'

  class Game extends Backbone.Model
    initialize: ->
      etypes = Cell: Cell, Player: Player, Fleet: Fleet, EnhancerNode: EnhancerNode
      @world = new World etypes

      @serverUpdates = {}

      @bind 'update', (e) =>
        console.log "game got update ", JSON.stringify(e)

        if e.tells
          @tellQueue.push(tell) for tell in e.tells

        if e.entityMutation
          @dataReceivedSinceTick += JSON.stringify(e).length
          @serverUpdates[e.tick] = e
          @lastReceivedUpdateTicks = e.tick

        @run() if e.run
      
      @ticks = 0

      # client vars
      @clientLag = 0
      @clientLagTotal = 0
      @lastReceivedUpdateTicks = 0
      @lastAppliedUpdateTicks = 0
      @dataReceivedSinceTick

      # common vars
      @running = false
      @tellQueue = []
      @sendQueue = []
    
    getWinner: ->
      owners = []
      for cell in @world.getEntitiesOfType('Cell')
        cellOwner = cell.getRelation 'owner'
        owners.push cellOwner if cellOwner && owners.indexOf(cellOwner) == -1
      
      if owners.length == 1
        owners[0]
      else
        null

    loadMap: ->
      players = @world.getEntitiesOfType('Player')
      c1 = @world.spawn 'Cell', x: 350, y: 100, size: 50
      @world.spawn 'Cell', x: 350, y: 300, size: 30, owner_id: players[0].id
      @world.spawn 'Cell', x: 100, y: 200, size: 50
      @world.spawn 'Cell', x: 500, y: 200, size: 50
      @world.spawn 'Cell', x: 550, y: 100, size: 30, owner_id: players[1].id
      @world.spawn 'EnhancerNode', x: 440, y: 120, owner_id: players[1].id
    
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

    sendFleet: (from, to) ->
      fleet = @world.spawn 'Fleet'
      fleet.setRelation('from', from)
      fleet.setRelation('to', to)
      
      if fleet.launch()
        console.log "launched a fleet"
      else
        console.log "fleet failed to launch"
        fleet.set dead: true

    moveCell: ->
      c = @world.getEntitiesOfType('Cell')[0]
      c.set x: c.get('x')+50

    runTells: (tells) ->
      @runTell(tell) for tell in tells

    sendClientTells: ->
      if @sendQueue.length > 0
        @trigger 'publish', tells: @sendQueue
        @sendQueue = []

    runTellQueue: ->
      @runTells(@tellQueue)
      @tellQueue = []
      
    halt: ->
      @running = false
    
    tickClient: ->
      #console.log "=== CLIENT TICKING #{@ticks}"
      startTime = new Date().getTime()

      @sendClientTells()

      if @dirtyWorldResetSnapshot
        @world.applyAttributeSnapshot(@dirtyWorldResetSnapshot)
        delete @dirtyWorldResetSnapshot

      reachableTicks = Math.min(@ticks, @lastReceivedUpdateTicks)

      while reachableTicks > @lastAppliedUpdateTicks
        next = ++@lastAppliedUpdateTicks

        lastAppliedUpdate = @serverUpdates[next]
        @world.applyMutation(lastAppliedUpdate.entityMutation)

        if next-2 > 0
          delete @serverUpdates[next-2] # keep the mutation that led to the recent tick and the one before that


      if reachableTicks < @ticks
        ticksToExtrapolate = @ticks - reachableTicks
        startingPoint = reachableTicks
        console.log "client is lagging behind, going to extrapolate for #{ticksToExtrapolate} ticks from tick #{startingPoint}"

        if ticksToExtrapolate > 10 # todo: constant
          console.log "lost more than 10 ticks, connection lost :("
          @halt()
          return

        if @lastAppliedUpdateTicks > 2

          @dirtyWorldResetSnapshot = @world.snapshotAttributes()
          # these are the mutations that led to the two last good ticks
          mut1 = @serverUpdates[startingPoint-1].entityMutation
          mut2 = @serverUpdates[startingPoint].entityMutation

          @world.state.extrapolate(mut1, mut2, ticksToExtrapolate)
  
      endTime = new Date().getTime()


      @trigger 'instrument:client-tick', 
        totalUpdateSize: @dataReceivedSinceTick
        clientProcessingTime: (endTime-startTime)
        serverProcessingTime: (lastAppliedUpdate || {serverProcessingTime: 0}).serverProcessingTime
      @dataReceivedSinceTick = 0

      #console.log "=== CLIENT TICK DONE"
    
    tickServer: ->
      console.log "=== SERVER TICKING #{@ticks}"
      startTime = new Date().getTime()

      entityMutation = @world.mutate =>
        @runTellQueue()
        @world.each (ent) =>
          ent.update && ent.update()
          @world.remove(ent) if ent.get('dead')

      if winner = @getWinner()
        @trigger 'end', winner: winner
        @halt()

      expectedPassedTicks = (new Date().getTime() - @timeAtRun) / 1000 * Game.ticksPerSecond
      syncError = (@ticks - expectedPassedTicks).toFixed(1)

      endTime = new Date().getTime()

      @trigger 'publish', 
        tick: @ticks
        entityMutation: entityMutation
        serverProcessingTime: (endTime-startTime)
        syncError: syncError

      console.log "=== SERVER TICKED TO #{@ticks}"

    tick: ->
      @ticks++
      @world.ticks = @ticks
      @world.tickStartedAt = new Date().getTime()
      @world.tickLength = Game.tickLength

      if @get('onServer')
        @tickServer()
      else
        @tickClient()

    ticksToTime: (ticks) ->
      ticks * Game.tickLength


    # TIME-CRITICAL STUFF
    run: -> # probably blows up synchronisation
      console.log "GOGOGOG"
      @trigger 'run'
      @timeAtRun = new Date().getTime()
      if @get('onServer')
        setTimeout =>
          @trigger 'publish', run: true
        , 30

      @running = true
      @scheduleTick()
    
    scheduleTick: ->
      @tick()

      if @running
        realtimeForNextTick = @timeAtRun + (@ticks * Game.tickLength)
        timeout = realtimeForNextTick - new Date().getTime()

        if timeout < 0
          console.warn "WARNING: desynched, scheduling next tick immediately"
          timeout = 0
        
        setTimeout =>
          @scheduleTick()
        , timeout

  
  Game.tickLength = 1000 / 5
  Game.ticksPerSecond = 1000 / Game.tickLength

  return Game