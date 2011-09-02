#= require <nanowar>
#= require <models/object>

Log = NanoWar.Log

class Nanowar.models.Cell extends Backbone.Model
  defaults:
    units: 0
  
  initialize: -> 
    @get('game').bind 'tick', @produce, this
    
  position: ->
    x: @get 'x'
    y: @get 'y'
  
  handle_incoming_fleet: (fleet) ->
    if fleet.get('owner') == @get('owner') # friendly fleet
      Log "Friendly fleet of #{fleet.strength} arrived at #{@cid}"
      @set
        units: @get('units') + fleet.strength
    else # hostile fleet
      Log "Hostile fleet of #{fleet.strength} arrived at #{@cid}"
      @set
        units: @get('units') - fleet.strength
      if Math.floor(@get('units')) == 0
        @set
          owner: null
          units: 0
        Log "#{@cid} changed to neutral"
      else if @get('units') < 0
        @set
          owner: fleet.get('owner')
          units: -@get('units')
        Log "#{@cid} overtaken by #{fleet.get('owner').name}"
  
  units_per_tick: ->
    return 0 unless @get 'owner' # neutral cells don't produce
    @get('size') * @get('game').get 'timeFactor'
  
  setup: ->
    @set_owner @owner
  
  produce: ->
    #console.log(@attributes.units)
    #console.log 'producing. - ' + @units_per_tick()
    @set
      units: @get('units') + Math.ceil(@units_per_tick())