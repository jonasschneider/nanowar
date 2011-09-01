#= require <models/game>

Log = NanoWar.Log

class NanoWar.CellData extends NanoWar.Object
  constructor: (cell) ->
    @type = "cell_data"
    @cell = cell
    
  setup: ->
    @elem = document.createElementNS( "http://www.w3.org/2000/svg", "text" )
    @elem.nw_cell = @cell
    @elem.setAttributes
      x: @cell.x
      y: @cell.y
      transform: "translate(0,5)"
      "class": "cell-data"
    
    @text = document.createTextNode("0")
    @elem.appendChild(@text)
    
    @game.container[0].appendChild(@elem)
  
  draw: ->
    @text.nodeValue = Math.floor @cell.units