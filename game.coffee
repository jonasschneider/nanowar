window.NanoWar: {}
NanoWar: window.NanoWar
$: window.$
Log: NanoWar.Log: (msg) ->
  if window? && window.console?
    window.console.log(msg)


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
    @halt: false
    
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
    cell.setup(this) for cell in @cells
    $(@container).click (event) =>
      @human_player.handle_click(event)
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
      #backbuf: $("#nanowar-backbuf")[0]
      #ctx: backbuf.getContext('2d');  
      
      #ctx.fillStyle: "white"
      #ctx.fillRect(0,0,700,500); # clear canvas
      #ctx.fillStyle: "black"
      
      #ctx.strokeStyle: "black"
      #ctx.strokeText(@fps_info(), 50, 100) # draw fps
      
      @tick()
      
      fleet.update() for fleet in @fleets
      @cleanup()
      
      
      #fleet.draw(ctx) for fleet in @fleets
      cell.draw() for cell in @cells
      
      # draw backbuf on real screen
      #@container[0].getContext('2d').drawImage(backbuf, 0, 0)
      
      @check_for_end()
    catch error
      Log error
    @schedule() unless @halt
  
  check_for_end: ->
    owners = []
    for cell in @cells
      owners.push(cell.owner) if cell.owner && owners.indexOf(cell.owner) == -1
    if(owners.length == 1)
      if owners[0] == @human_player
        alert("You win!")
      else
        alert("You lose...")
      @halt: true
    
  send_fleet: (from, to) ->
    Log "Cell ${from.id} sends to cell ${to.id}"
    fleet = new NanoWar.Fleet this, from, to
    @fleets.push fleet if fleet.is_valid()
    
  cleanup: ->
    for fleet, i in @fleets
      if fleet.delete_me
        @fleets.splice(i,1)
        @cleanup()
        break