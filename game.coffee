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
    #Log "Updating"
    
    @show_fps() if @ticks > 0 && @ticks % 5 == 0
    
    @tick()
    
    cell.update() for cell in @cells
    fleet.update() for fleet in @fleets
    
    @schedule()
    
  select: (cell) ->
    @selection: cell
    Log "Cell selected"
  
  attack: (target) ->
    return unless @selection
    fleet: new NanoWar.Fleet this, @selection, target, =>
      Log "arrived"
    fleet.launch()
    @fleets.push fleet
    
    Log "Attack launched"
    @selection: null
    

class NanoWar.Fleet
  constructor: (game, from, to, onArrive) ->
    @game: game
    @from: from
    @to: to
    @onArrive: onArrive
    @size: Math.round(@from.contents() / 2)
    @elem: null
    @launch_ticks: 0
    
  create: ->
    @elem: $("<div class='fleet'></div>").uniqueId("NWFleet").appendTo(@game.container)
    @elem.html(@size)
  
  launch: ->
    @launch_ticks: @game.ticks
  
  fraction_done: ->
    (@game.ticks - @launch_ticks) / 100
    
  position: ->
    posx: @from.x + (@to.x - @from.x) * @fraction_done()
    posy: @from.y + (@to.y - @from.y) * @fraction_done()
    [posx, posy]
    
  update: ->
    @create() unless @elem
    Log "Fleet ("+@size+" units, "+ @fraction_done() +" done) is runnin from " + @from.id() + " to " + @to.id()
    pos = @position()
    @elem.css({"left": pos[0], "top": pos[1]})
    if @fraction_done() == 1
      Log "Fleet has arrived"
      @game.fleets
      for fleet, i in @game.fleets
        @game.fleets.splice(i,1) if fleet is this
    

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
      
  handle_click: (event) ->
    if @is_friendly()
      Log "selecting me"
      @game.select(this)
    else
      @game.attack(this)
  
  update: ->
    @create() unless @elem
    @celldata.html(@contents());
    
  contents: ->
    Math.floor(@game.ticks / 1000 * @size * 2)