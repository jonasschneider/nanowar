#= require_tree models
#= require_tree views
#= require_tree helpers

$(document).ready ->
  window.game =  game = new Nanowar.Game()
  gameDisplay = new Nanowar.views.GameView({model: game, el: $("#nanowar")[0]})
  
  me = new NanoWar.HumanPlayer("Joonas")
  pc = new NanoWar.Player("Fiz")
  game.add_player(me)
  game.add_player(pc)
  game.set_human_player(me)
  game.cells.add {x: 350, y: 100, size: 50, game: game}
  game.cells.add {x: 350, y: 300, size: 50, owner: me, game: game}
  game.cells.add {x: 100, y: 200, size: 50, game: game}
  game.cells.add {x: 500, y: 200, size: 50, game: game}
  game.cells.add {x: 550, y: 100, size: 10, owner: pc, game: game}
  
  gameDisplay.render()
  
  gameDisplay.run()