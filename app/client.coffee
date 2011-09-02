#= require_tree models
#= require_tree views
#= require_tree helpers

$(document).ready ->
  game =  new Nanowar.Game()
  gameDisplay = new Nanowar.views.GameView({model: game, el: $("#nanowar")[0]})
  
  me = new NanoWar.HumanPlayer("Joonas")
  pc = new NanoWar.Player("Fiz")
  game.add_player(me)
  game.add_player(pc)
  game.set_human_player(me)
  game.cells.add(new Nanowar.models.Cell({x: 350, y: 100, size: 50}))
  game.cells.add(new Nanowar.models.Cell({x: 350, y: 300, size: 50, owner: me}))
  game.cells.add(new Nanowar.models.Cell({x: 100, y: 200, size: 50}))
  game.cells.add(new Nanowar.models.Cell({x: 500, y: 200, size: 50}))
  game.cells.add(new Nanowar.models.Cell({x: 550, y: 100, size: 10, owner: pc}))
  
  gameDisplay.render()
  
  game.run()