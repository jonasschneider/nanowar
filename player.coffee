Log: NanoWar.Log

class NanoWar.Player
  constructor: (name) ->
    @name: name
    @color: null
  
  set_game: (game) ->
    @game: game
    
class NanoWar.HumanPlayer extends NanoWar.Player
  constructor: ->
    @me: "lol"
    
  handle_click: (event) ->
    offset = @game.container.offset()
    x = event.clientX - offset.left
    y = event.clientY - offset.top
    match: false
    for cell in @game.cells
      if cell.is_inside(x, y)
        Log "Click on cell ${cell.id}"
        if @selection
          @game.send_fleet(@selection, cell)
        else
          @selection: cell if cell.owner == this
        
        match: true
        break
    if !match # deselect
      @selection: null
      
      
    return unless @selection