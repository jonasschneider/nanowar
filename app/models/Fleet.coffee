#= require <nanowar>

# attributes: Cell from, Cell to, Game game, Player owner
class Nanowar.models.Fleet extends Backbone.Model
  initialize: ->
    @set
      owner: @get('from').get 'owner'
    @get('game').bind 'tick', @update, this
    
    @strength = Math.round(@get('from').get('units') / 2)
    
    @bind 'change', ->
      console.log("fleet changed")
    @launched_at = null
  
  is_valid: ->
    @get('from') != @get('to') and @strength > 0
  
  launch: ->
    console.log "Fleet of #{@strength} launching from #{@get('from').cid} to #{@get('to').cid}"
    @get('from').set 
      units: @get('from').get('units') - @strength
    @launched_at = @get('game').ticks
  
  
  fraction_done: ->
    (@get('game').ticks - @launched_at) / 30
  
  size: ->
    rad = (size) ->
      -0.0005*size^2+0.3*size
    
    if @strength < 200
      rad(@strength)
    else
      rad(200)
  
  update: ->
    @trigger 'change'
    
    if @fraction_done() >= 1
      @trigger 'arrive'
      @get('to').handle_incoming_fleet this
      @destroy()
      
  destroy: ->
    @trigger 'destroy'
    @get('game').unbind 'tick', @update