#= require <nanowar>

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Cell = require('./Cell').Cell
  Nanowar.Player = require('./Player').Player
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

# attributes: Cell from, Cell to, Game game, Player owner, int strength, int launchedAt
class root.Fleet extends Backbone.Model
  initialize: ->
    @game = @get('game')
    @set game: undefined
    throw "Fleet needs game" unless @game
    
    if @get('from') && @get('from') not instanceof Nanowar.Cell
      throw "Not instantiating new cell here" unless @get('from').id
      @set
        from: @game.cells.get(@get('from').id)
    
    if @get('to') && @get('to') not instanceof Nanowar.Cell
      throw "Not instantiating new cell here" unless @get('to').id
      @set
        to: @game.cells.get(@get('to').id)
    
    if @get('owner') && @get('owner') not instanceof Nanowar.Player
      throw "Not instantiating new player here" unless @get('owner').id
      @set
        owner: @game.players.get @get('owner').id
    @set
      owner: @get('from').get 'owner'
    
    @game.bind 'tick', @update, this
    
    if !@get('strength')
      @set strength: Math.round(@get('from').getCurrentStrength() / 2)
    
    @bind 'change:id', ->
      console.log("fleet id changed")
    
    @set launched_at: null
    @launch() if @is_valid()
  
  is_valid: ->
    @get('from') != @get('to') and @get('strength') > 0
  
  launch: ->
    console.log "Fleet of #{@get('strength')} launching from #{@get('from').cid} to #{@get('to').cid}"
    @get('from').changeCurrentStrengthBy -@get('strength')
    @set launched_at: @game.ticks
  
  fraction_done: ->
    (@game.ticks - @get('launched_at')) / 30
  
  update: ->
    if @fraction_done() >= 1
      @get('to').handle_incoming_fleet this
      @destroy()
      
  destroy: ->
    @game.unbind 'tick', @update, this
    @trigger 'destroy', this    