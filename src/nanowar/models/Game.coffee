define (require) ->
  Cell              = require('../entities/Cell')
  Player            = require('../entities/Player')
  Fleet             = require('../entities/Fleet')
  EnhancerNode      = require('../entities/EnhancerNode')
  World  = require('nanowar/World')
  _                 = require 'underscore'
  Backbone          = require 'backbone'
  $          = require 'jquery'

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
          @serverUpdates[e.tick] = e
          @lastServerUpdate = e.tick

        @run() if e.run
      
      @ticks = 0

      # client vars
      @clientLag = 0
      @clientLagTotal = 0
      @lastServerUpdate = 0

      # common vars
      @running = false
      @stopping = false
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
      #new EnhancerNode x: 440, y: 120, game: this, owner: @getPlayers()[1]
    
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
      

    # UNSPECCED
    run: -> # probably blows up synchronisation
      console.log "GOGOGOG"
      @trigger 'run'
      @timeAtRun = new Date().getTime()
      if @get('onServer')
        setTimeout =>
          @trigger 'publish', run: true
        , 30

      @schedule()
    
    schedule: ->
      @tick()

      realtimeForNextTick = @timeAtRun + (@ticks * Game.tickLength)
      timeout = realtimeForNextTick - new Date().getTime()

      throw 'desynced!' if timeout < 0
      setTimeout =>
        @schedule()
      , timeout

    halt: ->
      @stopping = true
    
    tickClient: ->
      #@halt() if @ticks > 10
      startTime = new Date().getTime()

      @sendClientTells()
      if update = @serverUpdates[@ticks]
        #console.log "=== CLIENT TICKING"
        if @lagging # we have recovered from a lag
          @lagging = false
          @world.restoreAttributeSnapshot(@lagLastGoodAttributeSnapshot)

        if @ticks-2 > 0
          delete @serverUpdates[@ticks-2] # keep the mutation that led to the current tick and the one before that

        @clientLag = 0

        @world.applyMutation(update.entityMutation)

        #console.log "=== CLIENT TICK DONE (now at tick #{@ticks}, total lag #{@clientLagTotal})"

        #if @lastServerUpdate - @ticks > 1 # we are lagging behind, tick again
        #  @tickClient()


      else
        console.log "did not yet receive update for tick #{@ticks}, extrapolating!"

        if !@lagging # we started to lag
          @lagging = true
          @lagLastGoodAttributeSnapshot = @world.snapshotAttributes()
          @lagStartedAt = @ticks
          @lagExtrapolatedAttributes = []

          throw 'not enough data for extrapolate' if @lagStartedAt < 2


          # the changed attributes of the mutations that led to the two last good ticks
          attr1 = @world.attributesChangedByMutation(@serverUpdates[@ticks-2].entityMutation)
          attr2 = @world.attributesChangedByMutation(@serverUpdates[@ticks-1].entityMutation)


          for changeInfo1 in attr1
            [ent, attribute, olderValue] = changeInfo1
            changeInfo2 = _(attr2).detect (x) => x[0] == changeInfo1[0] and x[1] == changeInfo1[1]
            continue unless changeInfo2
            newerValue = changeInfo2[2]
            console.log "extrapolating #{ent}'s #{attribute}, was last changed from #{olderValue} to #{newerValue}"
            d = newerValue - olderValue
            @lagExtrapolatedAttributes.push [ent, attribute, newerValue, d]

        @clientLagTotal++
        lagDuration = @ticks - @lagStartedAt

        if lagDuration > 10 # todo: constant
          console.log "lost more than 10 ticks, connection lost :("
          @halt()
          return

        # extrapolate here
        m = @world.mutate =>
          for data in @lagExtrapolatedAttributes
            [entId, attr, lastKnownValue, delta] = data
            thisValue = lastKnownValue + lagDuration * delta
            @world.setEntityAttribute(entId, attr, thisValue)

        console.log m

      endTime = new Date().getTime()
      @trigger 'instrument:client-tick', 
        totalUpdateSize: JSON.stringify(@serverUpdates[@ticks] || {}).length # FIXME: handle lagging etc correctly
        clientProcessingTime: (endTime-startTime)
        serverProcessingTime: (@serverUpdates[@ticks] || {serverProcessingTime: 0}).serverProcessingTime # FIXME: same
    
    tickServer: ->
      console.log "=== TICKING"
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

      if @get('onServer')
        @tickServer()
      else
        @tickClient()

    ticksToTime: (ticks) ->
      ticks * Game.tickLength
  
  Game.tickLength = 1000 / 5
  Game.ticksPerSecond = 1000 / Game.tickLength

  return Game