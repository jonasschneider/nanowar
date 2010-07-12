window.NanoWar: {}
NanoWar: window.NanoWar
$: window.$
Log: window.console.log

class NanoWar.Game
  constructor: (container_id) ->
    @container: $("#"+container_id)
    @ticks: 0
    @last_tick: 0
    @cells: []
    @players: []
    @fleets: []
    @human_player: null
    @selection: null
    
  add_cell: (cell) ->
    @cells.push cell
    cell.set_game this
    
  add_player: (player) ->
    @players.push player
    player.set_game this
    
  set_human_player: (player) ->
    @human_player: player
  
  run: ->
    return if @running
    @running: true
    Log "GOGOGOG"
    @schedule()
    
  schedule: ->
    window.setTimeout =>
      @update()
    , 50
  
  tick: ->
    @ticks++
    @last_tick: new Date().getTime()
  
  show_fps: ->
    tick_time = new Date().getTime() - @last_tick
    fps = 1000 / tick_time
    @container.find(".fps").html(Math.round(fps) + "fps (" + tick_time + "ms)")
  
  update: ->
    Log "Updating"
    try
      @show_fps() if @ticks > 0 && @ticks % 5 == 0
      
      @tick()
      
      cell.update() for cell in @cells
      fleet.update() for fleet in @fleets
      
    catch error
      Log error
    @schedule()
    
  select: (cell) ->
    @selection: cell
    Log "Cell selected"
  
  attack: (target) ->
    return unless @selection
    @fleets.push new NanoWar.Fleet this, @selection, target
    @selection: null
    



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
    

class NanoWar.Player
  constructor: (name) ->
    @name: name
  
  set_game: (game) ->
    @game: game

class NanoWar.Cell
  constructor: (x, y, size, owner) -> 
    @x: x
    @y: y
    @size: size
    @owner: owner
    
    @game: null
    @elem: null
    
    @last_absolute_units: 0
    @last_absolute_ticks: 0
  
  set_game: (game) ->
    @game: game
  
  id: ->
    @elem.attr("id")
  
  is_friendly: ->
    @owner == @game.human_player
  
  create: ->
    @elem: $("<div class='cell'><span class='celldata'></span></div>").uniqueId("NWCell").css({"width": @size*2, "height": @size*2, "left": @x-@size, "top": @y-@size}).appendTo(@game.container)
    @celldata: @elem.find(".celldata")
    
    $(@elem).click =>
      @handle_click(arguments)
  
  handle_incoming_fleet: (fleet) ->
    Log "OMG! " + @id() + " receives fleet of " + fleet.size
    if fleet.attacker == @owner # friendly fleet
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
      Log "selecting me"
      @game.select(this)
    else
      @game.attack(this)
  
  update: ->
    @create() unless @elem
    @celldata.html(@units());
    
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