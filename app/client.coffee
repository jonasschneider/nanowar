#= require_tree models
#= require_tree views
#= require_tree helpers

$(document).ready ->
  game =  new NanoWar.Game("nanowar")
  me = new NanoWar.HumanPlayer("Joonas")
  pc = new NanoWar.Player("Fiz")
  game.add_player(me)
  game.add_player(pc)
  game.set_human_player(me)
  game.add(new NanoWar.Cell(350, 100, 50))
  game.add(new NanoWar.Cell(350, 300, 50, me))
  game.add(new NanoWar.Cell(100, 200, 50))
  game.add(new NanoWar.Cell(500, 200, 50))
  game.add(new NanoWar.Cell(550, 100, 10, pc))
  game.run()