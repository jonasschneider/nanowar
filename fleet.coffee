Log: NanoWar.Log

class NanoWar.Fleet
  constructor: (game, from, to) ->
    @game: game
    @from: from
    @to: to
    @owner: @from.owner
    
    @size: Math.round(@from.units() / 2)
    
    if @is_valid()
      @from.change_units(-@size)
    
    @launch_ticks: @game.ticks
    @delete_me: false
  
  is_valid: ->
    @from != @to and @size != 0
  
  fraction_done: ->
    (@game.ticks - @launch_ticks) / 30
    
  start_position: (ctx) ->
    Log "$@from.x/$@from.y ($@from.size) -> $@to.x/$@to.y"
    
    
    dx = @to.x - @from.x
    dy = @from.y - @to.y
    
    alpha = Math.atan(dy/dx)
    
    x = Math.cos(alpha)*@from.size
    y = Math.sin(alpha)*@from.size
    
    # trial and error
    if(@from.x > @to.x || @from.y < @to.y)
      x = x * -1 
      y = y * -1
      
    if(@from.x <= @to.x && @from.y < @to.y)
      x = x * -1 
      y = y * -1
    
    return { x: @from.x+x, y: @from.y-y}
    
  position: ->
    startpos = @start_position()
    Log "START"
    Log startpos
    posx: startpos.x + (@to.x - startpos.x) * @fraction_done()
    posy: startpos.y + (@to.y - startpos.y) * @fraction_done()
    { x: posx, y: posy }
  
  draw: (ctx) ->
    Log "drawing"
    ctx.beginPath()
    pos = @position()
    Log pos
    ctx.arc(pos.x, pos.y, @size, 0, 2*Math.PI, false)
    ctx.fill();
    ctx.fillStyle: "purple"
    
    ctx.beginPath()
    pos = @start_position(ctx)
    Log pos
    ctx.arc(pos.x, pos.y, 20, 0, 2*Math.PI, false)
    ctx.fill();
    ctx.fillStyle: "black"
    
    
    
  update: ->
    if @fraction_done() >= 1
      @to.handle_incoming_fleet this
      @delete_me: true