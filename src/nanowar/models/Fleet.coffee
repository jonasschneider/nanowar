define (require) ->
  Player = require('./Player')
  Entity = require('./Entity')
  Cell = require('./Cell')
  
  _      = require('underscore')
  util = require('../helpers/util')

  return class Fleet extends Entity
    type: 'Fleet'

    attributeSpecs:
      strength: 0
      launchedAt: null
      speedPerTick: 6

      posx: 0
      posy: 0

      owner_id: 0
      from_id: 0
      to_id: 0

    startPosition: ->
      util.nearestBorder @getRelation('from').position(), @getRelation('from').get('size'), @getRelation('to').position()
    
    endPosition: ->
      util.nearestBorder @getRelation('to').position(), @getRelation('to').get('size'), @getRelation('from').position()
    
    eta: ->
      @arrivalTime() - @ticks()

    fractionDone: ->
      1 - (@eta() / @flightTime())
    
    flightTime: ->
      Math.round @distance() / @get('speedPerTick')
    
    arrivalTime: ->
      @get('launchedAt') + @flightTime()
    
    distance: ->
      util.distance(@startPosition(), @endPosition())
      
    canLaunch: ->
      @getRelation('from') && @getRelation('to') && @getRelation('from') != @getRelation('to') && @get('strength') > 0
    
    arrived: ->
      @arrivalTime() < @ticks()

    ###
    # MUTATORS
    ###

    launch: ->
      @setRelation 'owner', @getRelation('from').getRelation('owner')

      if !@get('strength')
        @set strength: Math.floor(@getRelation('from').getCurrentStrength() / 2)

      if @canLaunch()
        console.log "[Tick#{@ticks()}] [Fleet #{@id}] Fleet of #{@get('strength')} launching #{@getRelation('from').id}->#{@getRelation('to').id}; arrival in #{@flightTime()} ticks"
        @set
          posx: Math.round(@startPosition().x)
          posy: Math.round(@startPosition().y)
        @getRelation('from').changeCurrentStrengthBy -@get('strength')
        @set launchedAt: @ticks()
        true
      else false
    
    update: ->
      sp = @startPosition()
      ep = @endPosition()
      dx = ep.x - sp.x
      dy = ep.y - sp.y
      @set
        posx: sp.x + dx * @fractionDone()
        posy: sp.y + dy * @fractionDone()
      
      if @arrived()
        console.log "[Tick#{@ticks()}] [Fleet #{@id}] Arrived from route #{@getRelation('from').id}->#{@getRelation('to').id}"
        @getRelation('to').handle_incoming_fleet this
        @set dead: true