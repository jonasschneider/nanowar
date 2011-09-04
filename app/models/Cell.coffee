#= require <nanowar>
#= require <helpers/RelationalModel>
#= require "Player"

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Player = require('./Player').Player
  Nanowar.RelationalModel = require('../helpers/RelationalModel.coffee').RelationalModel
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

class root.Cell extends Nanowar.RelationalModel
  relationSpecs:
    owner:
      relatedModel: Nanowar.Player
      directory: 'game.players'

  defaults:
    x:      0
    y:      0
    size:   0
    productionMultiplier: 1 / 100
    maxStorageMultiplier: 2
    
    knownStrength:        0
    knownStrengthAtTick:  0
  
  initialize: ->
    @game = @get('game')
    @set game: undefined
    throw "Cell needs game" unless @game
    super
    
    @bind 'change', =>
      console.log 'cell change '+JSON.stringify(@attributes)
    
  position: ->
    x: @get 'x'
    y: @get 'y'
  
  handle_incoming_fleet: (fleet) ->
    @trigger 'incomingFleet', fleet
    if fleet.get('owner') == @get('owner') # friendly fleet
      console.log "Friendly fleet of #{fleet.get('strength')} arrived at #{@cid}"
      @changeCurrentStrengthBy fleet.get('strength')
    else # hostile fleet
      console.log "Hostile fleet of #{fleet.get('strength')} arrived at #{@cid}"
      newStrength = @getCurrentStrength() - fleet.get('strength')
      
      if newStrength == 0
        @set
          owner: null
        , silent: true
        
        console.log "#{@cid} changed to neutral"
      else if newStrength < 0
        @set
          owner: fleet.get('owner')
        , silent: true
        
        newStrength = -newStrength
        
        console.log "#{@cid} overtaken by #{fleet.get('owner').get('name')}"
      
      @setCurrentStrength newStrength
  
  units_per_tick: ->
    return 0 unless @get 'owner' # neutral cells don't produce
    @get('size') * @get 'productionMultiplier'
  
  setup: ->
    @set_owner @owner
  
  getMax: ->
    @get('size') * @get 'maxStorageMultiplier'
    
  getCurrentStrength: ->
    Math.min @getMax(), @get('knownStrength') + Math.round((@game.ticks - @get('knownStrengthAtTick')) * @units_per_tick())
    
  setCurrentStrength: (newStrength) ->
    @set
      knownStrengthAtTick : @game.ticks
      knownStrength       : newStrength
  
  changeCurrentStrengthBy: (delta) ->
    @setCurrentStrength @getCurrentStrength() + delta