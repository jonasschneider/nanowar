define (require) ->
  Player = require('./Player')
  Entity = require('./Entity')
  Cell = require('./Cell')
  
  _      = require('underscore')
  util = require('../helpers/util')

  # attributes: Cell from, Cell to, Game game, Player owner, int strength, int launchedAt
  return class Fleet extends Entity
    defaults:
      launched_at: null
      speedPerTick: 6

    relationSpecs:
      from:
        relatedModel: Cell
        directory: 'game.entities'
      to:
        relatedModel: Cell
        directory: 'game.entities'
      owner:
        relatedModel: Player
        directory: 'game.entities'

    initialize: ->
      if @game.get('onServer')
        @game.bind 'tick', @update, this
        
        @bind 'remove', =>
          @game.unbind 'tick', @update, this
    
    startPosition: ->
      util.nearestBorder @get('from').position(), @get('from').get('size'), @get('to').position()
    
    endPosition: ->
      util.nearestBorder @get('to').position(), @get('to').get('size'), @get('from').position()
    
    eta: ->
      @arrivalTime() - @game.ticks

    fractionDone: ->
      1 - (@eta() / @flightTime())
    
    flightTime: ->
      Math.round @distance() / @get('speedPerTick')
    
    arrivalTime: ->
      @get('launched_at') + @flightTime()
    
    distance: ->
      util.distance(@startPosition(), @endPosition())
      
    canLaunch: ->
      @get('from') && @get('to') && @get('from') != @get('to') && @get('strength') > 0
    
    launch: ->
      @set owner: @get('from').get('owner')

      if !@get('strength')
        @set strength: Math.floor(@get('from').getCurrentStrength() / 2)

      if @canLaunch()
        console.log "[Tick#{@game.ticks}] [Fleet #{@id}] Fleet of #{@get('strength')} launching #{@get('from').id}->#{@get('to').id}; arrival in #{@flightTime()} ticks"
        @set
          posx: Math.round(@startPosition().x)
          posy: Math.round(@startPosition().y)
        @get('from').changeCurrentStrengthBy -@get('strength')
        @set launched_at: @game.ticks
        true
      else false
    
    arrived: ->
      @arrivalTime() < @game.ticks

    update: ->
      sp = @startPosition()
      ep = @endPosition()
      dx = ep.x - sp.x
      dy = ep.y - sp.y
      @set
        posx: Math.round(sp.x + dx * @fractionDone())
        posy: Math.round(sp.y + dy * @fractionDone())
      
      if @arrived()
        console.log "[Tick#{@game.ticks}] [Fleet #{@id}] Arrived from route #{@get('from').id}->#{@get('to').id}"
        @get('to').handle_incoming_fleet this
        @set dead: true