#= require <nanowar>

Nanowar = window.Nanowar
Log = Nanowar.Log
$ = window.$

Nanowar.uniqueIdCount = 1

class Nanowar.Game extends Backbone.Model
  defaults:
    timeFactor: 1 / 100
  
  initialize: () ->
    
    @cells = new Nanowar.models.CellCollection

    @ticks = 0
    @last_tick = 0
    @players = []
    @events = []
    @objects = []
    
    @human_player = null
    
    
  add: (object) ->
    @objects.push object
    object.game = this
    object.setup() if @running
    
  add_player: (player) ->
    colors = ["red", "blue", "green", "yellow"]
    @players.push player
    player.set_game this
    player.color = colors[@players.length-1]
    
  set_human_player: (player) ->
    @human_player = player
  
  tick: ->
    @ticks++
    @last_tick = new Date().getTime()
    
    @trigger 'tick'
    
    @check_for_end()
  
  check_for_end: ->
    owners = []
    for object in @objects
      owners.push(object.owner) if object.type == "cell" && object.owner && owners.indexOf(object.owner) == -1
    if(owners.length == 1)
      if owners[0] == @human_player
        alert("You win!")
      else
        alert("You lose...")
      @halt = true
    

    
  cleanup_objects: ->
    for object, i in @objects
      if object.delete_me
        object.destroy()
        @objects.splice(i,1)
        @cleanup_objects()
        break