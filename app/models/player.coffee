#= require <nanowar>

Log = NanoWar.Log

class NanoWar.Player
  constructor: (name) ->
    @name = name
    @color = null
  
  set_game: (game) ->
    @game = game
    
class NanoWar.HumanPlayer extends NanoWar.Player
  constructor: (name) ->
    @name = name
    
  
  select: (cell) ->
    @selection = cell
    cell.elem.addClass "selected"
  
  deselect: ->
    if @selection
      @selection.elem.removeClass("selected")
      @selection = null
  
  handle_click: (event) ->
    window.console.log("lol")
    if cell = event.target.nw_cell
      #Log "Click on cell ${cell.id}"
      window.console.log("lol")
      if @selection
        @game.send_fleet(@selection, cell)
      else
        @select(cell) if cell.owner == this
    else
      @deselect()