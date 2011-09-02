#= require <nanowar>

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Player = require('./Player').Player
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

class root.Cell extends Backbone.Model
  defaults:
    x:      0
    y:      0
    size:   0
    owner:  null
    productionMultiplier: 1 / 100
    
    knownStrength:        0
    knownStrengthAtTick:  0
  
  initialize: ->
    if @get('owner') && @get('owner') not instanceof Nanowar.Player
      if @get('owner').id
        @set
          owner: Nanowar.Player.dir.get(@get('owner').id)
      else
        @set
          owner: new Nanowar.Player(@get('owner'))
    
    @bind 'tick', (newTicks) ->
      @ticks = newTicks
    , this
  
  
  position: ->
    x: @get 'x'
    y: @get 'y'
  
  handle_incoming_fleet: (fleet) ->
    if fleet.get('owner') == @get('owner') # friendly fleet
      console.log "Friendly fleet of #{fleet.strength} arrived at #{@cid}"
      @changeCurrentStrengthBy fleet.strength
    else # hostile fleet
      console.log "Hostile fleet of #{fleet.strength} arrived at #{@cid}"
      @changeCurrentStrengthBy -fleet.strength
      
      if @getCurrentStrength() == 0
        @set
          owner: null
        
        console.log "#{@cid} changed to neutral"
      else if @getCurrentStrength() < 0
        @set
          owner: fleet.get('owner')
        @setCurrentStrength -@getCurrentStrength()
        
        console.log "#{@cid} overtaken by #{fleet.get('owner').name}"
  
  units_per_tick: ->
    return 0 unless @get 'owner' # neutral cells don't produce
    @get('size') * @get 'productionMultiplier'
  
  setup: ->
    @set_owner @owner
  
  getCurrentStrength: ->
    @get('knownStrength') + Math.round((@ticks - @get('knownStrengthAtTick')) * @units_per_tick())
    
  setCurrentStrength: (newStrength) ->
    @set
      knownStrengthAtTick : @ticks
      knownStrength       : newStrength
  
  changeCurrentStrengthBy: (delta) ->
    @setCurrentStrength @getCurrentStrength() + delta