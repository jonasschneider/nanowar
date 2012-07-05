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

  class Game extends Backbone.Model
    defaults:
      # client actions can take at worst 2*tickLength to propagate (command on server, results on client),
      # not even counting for processing and network latency!
      tickLength: 1000 / 10
    
    initialize: ->
      etypes = Cell: Cell, Player: Player, Fleet: Fleet, EnhancerNode: EnhancerNode
      @entities = new EntityCollection [], game: this, types: etypes

      @serverUpdates = {}

      @bind 'update', (e) =>
        console.log "game got update ", JSON.stringify(e)

        if e.tells
          @tellQueue.push(tell) for tell in e.tells

        if e.entityMutation
          @serverUpdates[e.tick] = { entityMutation: e.entityMutation }
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
    
    getEntities: (type) ->
      @entities.select (entity) -> entity instanceof type
    
    getCells: ->
      @getEntities Cell

    getPlayers: ->
      @getEntities Player
    
    getWinner: ->
      owners = []
      _(@getCells()).each (cell) =>
        cellOwner = cell.getRelation 'owner'
        owners.push cellOwner if cellOwner && owners.indexOf(cellOwner) == -1
      
      if owners.length == 1
        owners[0]
      else
        null

    loadMap: ->
      c1 = @entities.spawn 'Cell', x: 350, y: 100, size: 50
      @entities.spawn 'Cell', x: 350, y: 300, size: 30, owner_id: @getPlayers()[0].id
      @entities.spawn 'Cell', x: 100, y: 200, size: 50
      @entities.spawn 'Cell', x: 500, y: 200, size: 50
      @entities.spawn 'Cell', x: 550, y: 100, size: 30, owner_id: @getPlayers()[1].id
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
      fleet = @entities.spawn 'Fleet'
      fleet.setRelation('from', from)
      fleet.setRelation('to', to)
      
      if fleet.launch()
        console.log "launched a fleet"
      else
        console.log "fleet failed to launch"
        fleet.set dead: true

    moveCell: ->
      c = @getCells()[0]
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
      if @get('onServer')
        @trigger 'publish', run: true

      @schedule()
    
    schedule: ->
      setTimeout =>
        @tick()
      , @get 'tickLength'

    halt: ->
      @stopping = true
    
    tickClient: ->
      #@halt() if @ticks > 10
      @ticks++

      @sendClientTells()
      @trigger 'clientTick', @serverUpdates[@ticks+1]
      if update = @serverUpdates[@ticks]
        #console.log "=== CLIENT TICKING"
        if @lagging # we have recovered from a lag
          @lagging = false
          @entities.restoreAttributeSnapshot(@lagLastGoodAttributeSnapshot)

        if @ticks-2 > 0
          delete @serverUpdates[@ticks-2] # keep the mutation that led to the current tick and the one before that

        @clientLag = 0

        @entities.applyMutation(update.entityMutation)

        #console.log "=== CLIENT TICK DONE (now at tick #{@ticks}, total lag #{@clientLagTotal})"

        #if @lastServerUpdate - @ticks > 1 # we are lagging behind, tick again
        #  @tickClient()


      else
        console.log "did not yet receive update for tick #{@ticks}, extrapolating!"

        if !@lagging # we started to lag
          @lagging = true
          @lagLastGoodAttributeSnapshot = @entities.snapshotAttributes()
          @lagStartedAt = @ticks
          @lagExtrapolatedAttributes = []

          throw 'not enough data for extrapolate' if @lagStartedAt < 2


          # the changed attributes of the mutations that led to the two last good ticks
          attr1 = @entities.attributesChangedByMutation(@serverUpdates[@ticks-2].entityMutation)
          attr2 = @entities.attributesChangedByMutation(@serverUpdates[@ticks-1].entityMutation)


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
        m = @entities.mutate =>
          for data in @lagExtrapolatedAttributes
            [entId, attr, lastKnownValue, delta] = data
            thisValue = lastKnownValue + lagDuration * delta
            @entities.setEntityAttribute(entId, attr, thisValue)

        console.log m


        return


        for changedEnt in @lastDeltas
          oldEnt = _(@secondLastDeltas).detect (delta) =>
            delta.id == changedEnt.id
          continue unless oldEnt
          entDelta = {}

          for own prop of changedEnt 
            continue if prop == 'id'
            newerValue = changedEnt[prop]
            olderValue = oldEnt[prop]

            extrapValue = newerValue + (newerValue - olderValue)

            console.log("#{changedEnt.id}'s #{prop} changed from #{olderValue} to #{newerValue} -> extrapolated to #{extrapValue}")
            entDelta[prop] = extrapValue

          # FIXME: unbreak encapsulation
          @entities.trigger 'update', changedEntityId: changedEnt.id, changeDelta: entDelta


    
    tickServer: ->
      @ticks++
      console.log "=== TICKING"
    
      @updateAndPublish()
      console.log "=== SERVER TICK DONE (now at tick #{@ticks})"

    tick: ->
      @schedule() unless @stopping # FIXME: detect if tick is taking too long

      if @get('onServer')
        @tickServer()
      else
        @tickClient()



    updateAndPublish: ->
      entityMutation = @entities.mutate =>
        @runTellQueue()
        @entities.each (ent) =>
          ent.update && ent.update()
          @entities.remove(ent) if ent.get('dead')

      @trigger 'publish', tick: @ticks, entityMutation: entityMutation

      if winner = @getWinner()
        @trigger 'end', winner: winner
        @halt()


    ticksToTime: (ticks) ->
      ticks * @get 'tickLength'
  Game.tickLength = 1000 / 5
  return Game