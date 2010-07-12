Log: window.console.log

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
    if fleet.attacker == @owner # friendly fleet
      Log "Friendly fleet of ${fleet.size} arrived at $@id"
      @change_units(fleet.size)
    else # hostile fleet
      @change_units(-fleet.size)
      if @units() == 0
        @owner: null
      else if @units() < 0
        @owner: fleet.attacker()
        @set_units(-@units())
      
    
  handle_click: (event) ->
    if @is_friendly()
      @game.select(this)
    else
      @game.attack(this)
  
  is_click_inside: (x, y) ->
    x = Math.abs(x-@x)
    y = Math.abs(y-@y)
    dist = Math.sqrt(x*x+y*y)
    return dist < @size
  
  draw: (ctx)->
    #@create() unless @elem
    #@celldata.html(@units());
    if @game.selection == this
      ctx.fillStyle: "orange"
      ctx.strokeStyle: "black"
    else
      ctx.fillStyle: "black"
      ctx.strokeStyle: "white"
    
    ctx.beginPath()
    ctx.arc(@x, @y, @size, 0, 2*Math.PI, false)
    ctx.fill();
    ctx.fillStyle: "black"
    
    ctx.strokeText(@units(), @x, @y)
    
    ctx.fillStyle: "black"
    ctx.strokeStyle: "white"
    
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