Log: NanoWar.Log

class NanoWar.Fleet
  constructor: (game, from, to) ->
    @game: game
    @from: from
    @to: to
    @owner: @from.owner
    
    @strength: Math.round(@from.units() / 2)
    
    @delete_me: false
  
  is_valid: ->
    @from != @to and @size != 0
  
  launch: ->
    @from.change_units(-@strength)
    @launch_ticks: @game.ticks
    @setup()
  
  fraction_done: ->
    (@game.ticks - @launch_ticks) / 30
  
  start_position: ->
    @from.nearest_border({x: @to.x, y: @to.y})
  
  end_position: ->
    @to.nearest_border({x: @from.x, y: @from.y})
  
  size: ->
    rad: (size) ->
      -0.0005*size^2+0.3*size
    
    if @strength < 200
      rad(@strength)
    else
      rad(200)
  
  setup: ->
    @elem: document.createElementNS( "http://www.w3.org/2000/svg", "circle" )
    @elem.nw_fleet: this
    @elem.setAttribute("r", @size())
    @elem.setAttribute("stroke", "none")
    
    @elem.setAttribute("cx", @start_position().x)
    @elem.setAttribute("cy", @start_position().y)
    
    @game.container[0].appendChild(@elem)
  
  position: ->
    startpos = @start_position()
    endpos = @end_position()
    posx: startpos.x + (endpos.x - startpos.x) * @fraction_done()
    posy: startpos.y + (endpos.y - startpos.y) * @fraction_done()
    { x: posx, y: posy }
  
  draw: ->
    pos = @position()
    @elem.setAttribute("cx", pos.x)
    @elem.setAttribute("cy", pos.y)
  
  update: ->
    if @fraction_done() >= 1
      @to.handle_incoming_fleet this
      @delete_me: true
  
  destroy: ->
    Log "destroying"
    @game.container[0].removeChild(@elem)