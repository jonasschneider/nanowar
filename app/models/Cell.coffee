#= require <nanowar>

class Nanowar.Cell extends Backbone.Model
  defaults:
    x:      0
    y:      0
    size:   0
    game:   null
    owner:  null
    
    knownStrength:        0
    knownStrengthAtTick:  0
  
  initialize: -> 
    @setCurrentStrength(0)
    
  position: ->
    x: @get 'x'
    y: @get 'y'
  
  handle_incoming_fleet: (fleet) ->
    if fleet.get('owner') == @get('owner') # friendly fleet
      Log "Friendly fleet of #{fleet.strength} arrived at #{@cid}"
      @changeCurrentStrengthBy fleet.strength
    else # hostile fleet
      Log "Hostile fleet of #{fleet.strength} arrived at #{@cid}"
      @changeCurrentStrengthBy -fleet.strength
      
      if @getCurrentStrength() == 0
        @set
          owner: null
        
        Log "#{@cid} changed to neutral"
      else if @getCurrentStrength() < 0
        @set
          owner: fleet.get('owner')
        @setCurrentStrength -@getCurrentStrength()
        
        Log "#{@cid} overtaken by #{fleet.get('owner').name}"
  
  units_per_tick: ->
    return 0 unless @get 'owner' # neutral cells don't produce
    @get('size') * @get('game').get 'cellProductionMultiplier'
  
  setup: ->
    @set_owner @owner
  
  getCurrentStrength: ->
    @get('knownStrength') + Math.round((@get('game').ticks - @get('knownStrengthAtTick')) * @units_per_tick())
    
  setCurrentStrength: (newStrength) ->
    @set
      knownStrengthAtTick : @get('game').ticks
      knownStrength       : newStrength
  
  changeCurrentStrengthBy: (delta) ->
    @setCurrentStrength @getCurrentStrength() + delta