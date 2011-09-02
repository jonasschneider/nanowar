#= require <nanowar>
#= require <models/object>

Log = NanoWar.Log

class Nanowar.models.Cell extends Backbone.Model
  initialize: (x, y, size, owner) -> 
    @type = "cell"
    
    @x = x
    @y = y
    @size = size
    @owner = owner
    
    @id = NanoWar.uniqueIdCount++
    
    @units = 0
    
  set_owner: (new_owner) ->
    @owner = new_owner
  
  handle_incoming_fleet: (fleet) ->
    if fleet.owner == @owner # friendly fleet
      Log "Friendly fleet of $fleet.strength arrived at $@id"
      @units += fleet.strength
    else # hostile fleet
      Log "Hostile fleet of $fleet.strength arrived at $@id"
      @units -= fleet.strength
      if Math.floor(@units) == 0
        @owner = null
        @units = 0
        Log "$@id changed to neutral"
      else if @units < 0
        @set_owner fleet.owner
        @units = -@units
        Log "$@id overtaken by $fleet.owner.name"
    
  nearest_border: (pos) ->
    dx = pos.x - @x
    dy = @y - pos.y
    
    alpha = Math.atan(dy/dx)
    
    x = Math.cos(alpha)*@size
    y = Math.sin(alpha)*@size
    
    # trial and error
    if(@x > pos.x || @y < pos.y)
      x = x * -1 
      y = y * -1
      
    if(@x <= pos.x && @y < pos.y)
      x = x * -1 
      y = y * -1
    
    return { x: @x+x, y: @y-y}
  
  units_per_tick: ->
    return 0 unless @owner # neutral cells don't produce
    @size * @game.desired_tick_length / 8000
  
  setup: ->
    @set_owner @owner
  
  update: ->
    @units += @units_per_tick()