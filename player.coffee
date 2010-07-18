Log: NanoWar.Log

class NanoWar.Player
  constructor: (name) ->
    @name: name
    @color: null
  
  set_game: (game) ->
    @game: game
    
class NanoWar.HumanPlayer extends NanoWar.Player
  constructor: (name) ->
    @name: name
    
  handle_click: (event) ->
    offset = @game.container.offset()
    x = event.clientX - offset.left
    y = event.clientY - offset.top
    
    if cell: event.originalTarget.nw_cell
        Log "Click on cell ${cell.id}"
        if @selection
          @game.send_fleet(@selection, cell)
        else
          @selection: cell if cell.owner == this
    else
      @selection: null