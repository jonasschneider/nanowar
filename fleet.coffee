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
    
  attacker: ->
    @from.owner
  
  create: ->
    @elem: $("<div class='fleet'></div>").uniqueId("NWFleet").appendTo(@game.container)
    @elem.html(@size)
  
  
  fraction_done: ->
    (@game.ticks - @launch_ticks) / 30
    
  position: ->
    posx: @from.x + (@to.x - @from.x) * @fraction_done()
    posy: @from.y + (@to.y - @from.y) * @fraction_done()
    [posx, posy]
  
  destroy: ->
    for fleet, i in @game.fleets
      @game.fleets.splice(i,1) if fleet is this
  
  update: ->
    @create() unless @elem
    Log "Fleet ("+@size+" units, "+ @fraction_done() +" done) is runnin from " + @from.id() + " to " + @to.id()
    pos = @position()
    @elem.css({"left": pos[0], "top": pos[1]})
    if @fraction_done() >= 1
      Log "Fleet has arrived"
      @to.handle_incoming_fleet this
      @destroy()