#= require <nanowar>

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Cell = require('./Cell').Cell
  Nanowar.Player = require('./Player').Player
  Nanowar.util = require('../helpers/util').util
  Nanowar.RelationalModel = require('../helpers/RelationalModel.coffee').RelationalModel
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

# attributes: Cell from, Cell to, Game game, Player owner, int strength, int launchedAt
class root.Fleet extends Nanowar.RelationalModel
  defaults:
    launched_at: null
    speedPerTick: 6

  relationSpecs:
    from:
      relatedModel: Nanowar.Cell
      directory: 'game.cells'
    to:
      relatedModel: Nanowar.Cell
      directory: 'game.cells'
    owner:
      relatedModel: Nanowar.Player
      directory: 'game.players'

  initialize: ->
    @game = @get('game')
    @set game: undefined
    throw "Fleet needs game" unless @game
    
    super
    
    @game.bind 'tick', @update, this

    @bind 'change:from', =>
      @set owner: @get('from').get('owner')
      if !@get('strength')
        @set strength: Math.round(@get('from').getCurrentStrength() / 2)
  
  startPosition: ->
    Nanowar.util.nearestBorder @get('from').position(), @get('from').get('size'), @get('to').position()
  
  endPosition: ->
    Nanowar.util.nearestBorder @get('to').position(), @get('to').get('size'), @get('from').position()
  
  eta: ->
    @arrivalTime() - @game.ticks
  
  flightTime: ->
    Math.round @distance() / @get('speedPerTick')
  
  arrivalTime: ->
    @get('launched_at') + @flightTime()
  
  distance: ->
    Nanowar.util.distance(@startPosition(), @endPosition())
    
  is_valid: ->
    @get('from') != @get('to') and @get('strength') > 0
  
  launch: ->
    console.log "Fleet of #{@get('strength')} launching"
    @get('from').changeCurrentStrengthBy -@get('strength')
    @set launched_at: @game.ticks
  
  arrived: ->
    @arrivalTime() < @game.ticks
  
  update: ->
    if @arrived()
      if onServer?
        @get('to').handle_incoming_fleet this
      @destroy()
      
  destroy: ->
    @game.unbind 'tick', @update, this
    @trigger 'destroy', this    