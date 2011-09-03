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
    @game = @get('game')
    @set game: undefined
    throw "Cell needs game" unless @game
    
    
    @bind 'change:owner', =>
      if @get('owner') && @get('owner') not instanceof Nanowar.Player
        throw "Not instantiating new player here" unless @get('owner').id
        @set { owner: @game.players.get @get('owner').id }, silent: true
    
    @bind 'change', =>
      console.log 'cell change '+JSON.stringify(@attributes)
    
    if @get('owner') && @get('owner') not instanceof Nanowar.Player
      throw "Not instantiating new player here" unless @get('owner').id
      @set
        owner: @game.players.get @get('owner').id
  
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
  
  getCurrentStrength: ->
    @get('knownStrength') + Math.round((@game.ticks - @get('knownStrengthAtTick')) * @units_per_tick())
    
  setCurrentStrength: (newStrength) ->
    @set
      knownStrengthAtTick : @game.ticks
      knownStrength       : newStrength
  
  changeCurrentStrengthBy: (delta) ->
    @setCurrentStrength @getCurrentStrength() + delta