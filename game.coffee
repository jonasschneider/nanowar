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
    @schedule()
    
  schedule: ->
    window.setTimeout =>
      @update()
    , 50
  
  update: ->
    Log "Updating"
    @ticks++
    cell.update(this) for cell in @cells
    @schedule()
      

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
    @elem: $("<div class='cell'><span class='celldata'></span></div>").uniqueId("NWCell").css({"width": @size*2, "height": @size*2, "left": @x-@size, "top": @y-@size}).appendTo(@game.container)
    @celldata: @elem.find(".celldata")
      
  update: ->
    @create() unless @elem
    Log "Updating cell with id " + @elem.attr("id")
    @celldata.html(@contents());
    
  contents: ->
    Math.floor(@game.ticks / 1000 * @size * 2)