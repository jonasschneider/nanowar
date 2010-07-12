Log: window.console.log

class NanoWar.Fleet
  constructor: (game, from, to) ->
    @game: game
    @from: from
    @to: to
    
    @size: Math.round(@from.units() / 2)
    @from.change_units(-@size)
    
    @elem: null
    @launch_ticks: @game.ticks
    @delete_me: false
    
  attacker: ->
    @from.owner
  
  create: ->
    @elem: $("<div class='fleet'></div>").uniqueId("NWFleet").appendTo(@game.container)
    @elem.html(@size)
  
  
  fraction_done: ->
    (@game.ticks - @launch_ticks) / 100
    
  position: ->
    posx: @from.x + (@to.x - @from.x) * @fraction_done()
    posy: @from.y + (@to.y - @from.y) * @fraction_done()
    [posx, posy]
  
  destroy: ->
    for fleet, i in @game.fleets
      @game.fleets.splice(i,1) if fleet is this
  
  draw: (ctx) ->
    ctx.beginPath()
    pos = @position()
    ctx.arc(pos[0], pos[1], @size, 0, 2*Math.PI, false)
    ctx.fill();
    ctx.fillStyle: "black"
    
  update: ->
    if @fraction_done() >= 1
      Log "Fleet has arrived"
      @to.handle_incoming_fleet this
      @delete_me: true