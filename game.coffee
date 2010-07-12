window.NanoWar: {}
NanoWar: window.NanoWar
$: window.$
Log: window.console.log

NanoWar.uniqueIdCount: 1

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
    colors = ["red", "blue", "green", "yellow"]
    @players.push player
    player.set_game this
    player.color = colors[@players.length-1]
    
  set_human_player: (player) ->
    @human_player: player
  
  run: ->
    return if @running
    @running: true
    Log "GOGOGOG"
    $(@container).click (event) =>
      @handle_click(event)
    @schedule()
    
  schedule: ->
    window.setTimeout =>
      @update()
    , 20
  
  tick: ->
    @ticks++
    @last_tick: new Date().getTime()
  
  fps_info: ->
    tick_time = new Date().getTime() - @last_tick
    fps = Math.round(1000 / tick_time)
    
    num_cells = @cells.length
    num_fleets = @fleets.length
    
    "$fps fps ($tick_time ms/frame) ${num_cells}/${num_fleets}"
  
  update: ->
    try
      backbuf: $("#nanowar-backbuf")[0]
      ctx: backbuf.getContext('2d');  
      
      ctx.fillStyle: "white"
      ctx.fillRect(0,0,700,500); # clear canvas  
      ctx.fillStyle: "black"
      
      ctx.strokeStyle: "black"
      ctx.strokeText(@fps_info(), 50, 100) # draw fps
      
      @tick()
      
      #ctx.fillRect(30,30,@ticks*@ticks,50);
      fleet.update() for fleet in @fleets
      
      #cell.update() for cell in @cells
      
      @cleanup()
      
      fleet.draw(ctx) for fleet in @fleets
      cell.draw(ctx) for cell in @cells
      
      
      # draw backbuf on real screen
      @container[0].getContext('2d').drawImage(backbuf, 0, 0)
    catch error
      Log error
    @schedule()
    
  select: (cell) ->
    @selection: cell
    Log "Cell ${cell.id} selected"
  
  send_fleet: (target) ->
    return unless @selection
    Log "Cell ${@selection.id} sends to cell ${target.id}"
    @fleets.push new NanoWar.Fleet this, @selection, target
    
  cleanup: ->
    for fleet, i in @fleets
      if fleet.delete_me
        @fleets.splice(i,1)
        @cleanup()
        break
  
  handle_click: (event) ->
    offset = @container.offset()
    x = event.clientX - offset.left
    y = event.clientY - offset.top
    for cell in @cells
      if cell.is_inside(x, y)
        Log "Click on cell ${cell.id}"
        cell.handle_click(event)
        inside = cell
        break
    if !inside
      @selection: null
 

class NanoWar.Player
  constructor: (name) ->
    @name: name
    @color: null
  
  set_game: (game) ->
    @game: game