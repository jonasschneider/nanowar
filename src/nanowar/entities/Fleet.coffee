Player = require('./Player')
Entity = require('dyz/Entity')
Cell = require('./Cell')

_      = require('underscore')
util = require('../helpers/util')

module.exports = class Fleet extends Entity
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
    t = @getRelation('to')
    if t && t.entityTypeName == 'Cell'
      util.nearestBorder @getRelation('to').position(), @getRelation('to').get('size'), @getRelation('from').position()
    else
      x: t.get('x')
      y: t.get('y')
  
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
      @message 'launch'
      true
    else false
  
  update: ->
    sp = @startPosition()
    ep = @endPosition()
    dx = ep.x - sp.x
    dy = ep.y - sp.y
    @set
      posx: parseFloat (sp.x + dx * @fractionDone()).toFixed(2)
      posy: parseFloat (sp.y + dy * @fractionDone()).toFixed(2)
    
    if @arrived()
      console.log "[Tick#{@ticks()}] [Fleet #{@id}] Arrived from route #{@getRelation('from').id}->#{@getRelation('to').id}"
      @getRelation('to').handle_incoming_fleet this
      @set dead: true