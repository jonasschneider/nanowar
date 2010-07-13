Log: NanoWar.Log

class NanoWar.Cell
  constructor: (x, y, size, owner) -> 
    @x: x
    @y: y
    @size: size
    @owner: owner
    
    @game: null
    @id: NanoWar.uniqueIdCount++
    
    @last_absolute_units: 0
    @last_absolute_ticks: 0
  
  set_game: (game) ->
    @game: game
  
  is_friendly: ->
    @owner == @game.human_player
  
  handle_incoming_fleet: (fleet) ->
    if fleet.owner == @owner # friendly fleet
      Log "Friendly fleet of $fleet.strength arrived at $@id"
      @change_units(fleet.strength)
    else # hostile fleet
      Log "Hostile fleet of $fleet.strength arrived at $@id"
      @change_units(-fleet.strength)
      if @units() == 0
        @owner: null
        Log "$@id changed to neutral"
      else if @units() < 0
        @owner: fleet.owner
        @set_units(-@units())
        Log "$@id overtaken by $fleet.owner.name"
  
  is_inside: (x, y) ->
    x = Math.abs(x-@x)
    y = Math.abs(y-@y)
    dist = Math.sqrt(x*x+y*y)
    return dist < @size
  
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
    
  draw: (ctx)->
    if @game.human_player.selection == this
      ctx.fillStyle: "orange"
      ctx.strokeStyle: "black"
    else
      if @owner? && @owner.color
        ctx.fillStyle: @owner.color
      else
        ctx.fillStyle: "grey"
      ctx.strokeStyle: "white"
    
    ctx.beginPath()
    ctx.arc(@x, @y, @size, 0, 2*Math.PI, false)
    ctx.closePath()
    ctx.fill();
    ctx.fillStyle: "black"
    
    ctx.strokeText(@units(), @x, @y)
    
  unit_growth: ->
    return 0 unless @owner # neutral cells don't produce
    Math.floor((@game.ticks - @last_absolute_ticks) / 1000 * @size * 2)
    
  units: ->
    @last_absolute_units + @unit_growth()
    
  set_units: (num) ->
    @last_absolute_units: num
    @last_absolute_ticks: @game.ticks
  
  change_units: (delta) ->
    @set_units @units() + delta