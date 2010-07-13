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
    

    
  start_position: ->
    @from.nearest_border({x: @to.x, y: @to.y})
  
  end_position: ->
    @to.nearest_border({x: @from.x, y: @from.y})
  
  position: ->
    startpos = @start_position()
    endpos = @end_position()
    posx: startpos.x + (endpos.x - startpos.x) * @fraction_done()
    posy: startpos.y + (endpos.y - startpos.y) * @fraction_done()
    { x: posx, y: posy }
  
  draw: (ctx) ->
    ctx.beginPath()
    pos = @position()
    ctx.arc(pos.x, pos.y, @size, 0, 2*Math.PI, false)
    ctx.fill();
    ctx.fillStyle: "purple"
    
  update: ->
    if @fraction_done() >= 1
      @to.handle_incoming_fleet this
      @delete_me: true