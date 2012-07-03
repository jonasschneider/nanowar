define (require) ->
  Entity = require('./Entity')
  Player = require('./Player')

  return class Cell extends Entity
    type: 'Cell'

    attributeSpecs:
      x:      0
      y:      0
      size:   0

      productionMultiplier: 1 / 100
      maxStorageMultiplier: 2      
      knownStrength:        0
      knownStrengthAtTick:  0

      owner_id:      0

    initialize: ->
      @bind 'change:owner', @handleOwnerUpdate

    position: ->
      x: @get 'x'
      y: @get 'y'
    
    getMax: ->
      @get('size') * @get 'maxStorageMultiplier'
      
    getCurrentStrength: ->
      Math.min @getMax(), @get('knownStrength') + Math.round((@ticks() - @get('knownStrengthAtTick')) * @productionPerTick())

    productionPerTick: ->
      return 0 unless @getRelation('owner') # neutral cells don't produce
      @get('size') * @get 'productionMultiplier'
    
    ###
    # MUTATORS
    ###
    
    handle_incoming_fleet: (fleet) ->
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
    
    handleOwnerUpdate: ->
      val = @get 'owner'
      @set { owner: @_previousAttributes.owner }, silent: true
      @checkpointStrength()
      @set { owner: val }, silent: true
    
    checkpointStrength: (options) ->
      @setCurrentStrength @getCurrentStrength(), options
    
    setCurrentStrength: (newStrength, options) ->
      @set
        knownStrengthAtTick : @game.ticks
        knownStrength       : newStrength
      , options
    
    changeCurrentStrengthBy: (delta, options) ->
      @setCurrentStrength @getCurrentStrength() + delta, options