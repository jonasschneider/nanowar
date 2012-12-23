Player = require('./Player')
Entity = require('dyz/Entity')
_      = require('underscore')
util = require('../helpers/util')

module.exports = class EnhancerNode extends Entity
  attributeSpecs:
    x: 0
    y: 0

    owner_id: 0
    strength: 0
  
  initialize: ->
    @_previousAffectedCells = @affectedCells()

  update: ->
    newly = @affectedCells()
    previously = @_previousAffectedCells
    
    _(newly).chain().difference(previously).each (c) =>
      @message 'affectedCells:add', c.id
      c.set size: c.get('size')+10
    
    _(previously).chain().difference(newly).each (c) =>
      # entity could be stale, be cautious
      @message 'affectedCells:remove', c.id
      if c = @collection.get(c.id)
        c.set size: c.get('size')-10
    
    @_previousAffectedCells = newly
    
  position: ->
    x: @get 'x'
    y: @get 'y'

  affectedCells: ->
    _(@collection.getEntitiesOfType('Cell')).chain()
    .select (cell) =>
      cell.getRelation('owner') == @getRelation('owner')
    .sortBy (cell) =>
      util.distance(@position(), cell.position())
    .first(2).value()

  changeCurrentStrengthBy: (d) ->
    @set strength: @get('strength')+d

  setCurrentStrength: (s) ->
    @set strength: s

  getCurrentStrength: ->
    @get('strength')

  handle_incoming_fleet: (fleet) ->
    if fleet.getRelation('owner') == @getRelation('owner') # friendly fleet
      console.log "Friendly fleet of #{fleet.get('strength')} arrived"
      @changeCurrentStrengthBy fleet.get('strength')
    else # hostile fleet
      console.log "Hostile fleet of #{fleet.get('strength')} arrived"
      newStrength = @getCurrentStrength() - fleet.get('strength')
      
      if newStrength == 0
        @setRelation 'owner', null

        console.log "#{@cid} changed to neutral"
      else if newStrength < 0
        @setRelation 'owner', fleet.getRelation('owner')
        
        newStrength = -newStrength
        
        console.log "#{@cid} overtaken by #{fleet.getRelation('owner').get('name')}"
      
      @setCurrentStrength newStrength
  