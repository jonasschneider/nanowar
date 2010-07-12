window.NanoWar: {}
NanoWar: window.NanoWar
$: window.$
Log: window.console.log

class NanoWar.Game
  constructor: (container_id) ->
    @container: $("#"+container_id)
    @ticks: 0
    @cells: []
    
  add_cell: (cell) ->
    @cells.push cell
    cell.set_game this
  
  run: ->
    return if @running
    @running: true
    Log "GOGOGOG"
    cell.create(this) for cell in @cells
    @schedule()
    
  schedule: ->
    window.setTimeout =>
      @update()
    , 50
  
  update: ->
    Log "Updating"
    @ticks++
    cell.update(this) for cell in @cells
    true
      

class NanoWar.Cell
  constructor: (x, y, size) -> 
    @x: x
    @y: y
    @size: size
    
    @game: null
    @elem: null
  
  set_game: (game) ->
    @game: game
  
  create: ->
    @elem: $("<div>this div will get an id</div>").uniqueId("NWCell").appendTo(@game.container)
  
  update: ->
    Log "Updating cell of size " + @size + ", id is " + @dom_id