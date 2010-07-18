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
    @events: []
    @human_player: null
    @selection: null
    @halt: false
    @desired_tick_length: 1000/30
    
  add_cell: (cell) ->
    @cells.push cell
    
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
    
    @fps_container: document.createElementNS( "http://www.w3.org/2000/svg", "text" )
    @fps_container.setAttribute("x", 700-200)
    @fps_container.setAttribute("y", 500-480)
    @fps_text: document.createTextNode("asdf")
    @fps_container.appendChild(@fps_text)
    @container[0].appendChild(@fps_container)

    $(@container).click (event) =>
      @events.unshift event
    @schedule()
    
  schedule: ->
    window.setTimeout =>
      @update()
    , @desired_tick_length
  
  tick: ->
    @ticks++
    @last_tick: new Date().getTime()
  
  fps_info: ->
    @last_tick_length = new Date().getTime() - @last_tick
    fps = Math.round(1000 / @last_tick_length)
    
    num_cells = @cells.length
    num_fleets = @fleets.length
    
    "$fps fps ($@last_tick_length ms/frame) ${num_cells}/${num_fleets}"
  
  update: ->
    try
      @fps_text.nodeValue: @fps_info()
      @tick()
      
      while event: @events.pop()
        @human_player.handle_click(event)
      
      
      fleet.update() for fleet in @fleets
      cell.update() for cell in @cells
      
      @cleanup_fleets()
      
      
      fleet.draw() for fleet in @fleets
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
    if fleet.is_valid()
      fleet.launch()
      @fleets.push fleet
    
  cleanup_fleets: ->
    for fleet, i in @fleets
      if fleet.delete_me
        fleet.destroy()
        @fleets.splice(i,1)
        @cleanup_fleets()
        break