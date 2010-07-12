Log: window.console.log

class NanoWar.Fleet
  constructor: (game, from, to) ->
    @game: game
    @from: from
    @to: to
    @owner: @from.owner
    
    @size: Math.round(@from.units() / 2)
    @from.change_units(-@size)
    
    @launch_ticks: @game.ticks
    @delete_me: false
    
  fraction_done: ->
    (@game.ticks - @launch_ticks) / 100
    
  position: ->
    posx: @from.x + (@to.x - @from.x) * @fraction_done()
    posy: @from.y + (@to.y - @from.y) * @fraction_done()
    [posx, posy]
  
  draw: (ctx) ->
    ctx.beginPath()
    pos = @position()
    ctx.arc(pos[0], pos[1], @size, 0, 2*Math.PI, false)
    ctx.fill();
    ctx.fillStyle: "black"
    
  update: ->
    if @fraction_done() >= 1
      @to.handle_incoming_fleet this
      @delete_me: true