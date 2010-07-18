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
    @players: []
    @events: []
    @objects: []
    
    @human_player: null
    @selection: null
    
    @running: false
    @halt: false
    @desired_tick_length: 1000/30
    
  add: (object) ->
    @objects.push object
    object.set_game this
    object.setup() if @running
    
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
    object.setup(this) for object in @objects
    
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
    
    "$fps fps ($@last_tick_length ms/frame) ${@objects.length}"
  
  update: ->
    try
      # Update FPS
      @fps_text.nodeValue: @fps_info()
      
      # Tick
      @tick()
      
      # Process events
      while event: @events.pop()
        @human_player.handle_click(event)
      
      # Update objects
      object.update() for object in @objects
      
      # Remove deleted objects
      @cleanup_objects()
      
      # Draw objects
      object.draw() for object in @objects
      
      # End game if conditions are met
      @check_for_end()
    catch error
      Log error
    @schedule() unless @halt
  
  check_for_end: ->
    owners = []
    for object in @objects
      owners.push(object.owner) if object.type == "cell" && object.owner && owners.indexOf(object.owner) == -1
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
      @objects.push fleet
    
  cleanup_objects: ->
    for object, i in @objects
      if object.delete_me
        object.destroy()
        @objects.splice(i,1)
        @cleanup_objects()
        break