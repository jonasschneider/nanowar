#= require <nanowar>

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Cell = require('./Cell').Cell
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

# attributes: Cell from, Cell to, Game game, Player owner
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
    
    @set
      owner: @get('from').get 'owner'
    
    @bind 'tick', @update, this
    
    @strength = Math.round(@get('from').getCurrentStrength() / 2)
    
    @launched_at = null
  
  is_valid: ->
    @get('from') != @get('to') and @strength > 0
  
  launch: ->
    console.log "Fleet of #{@strength} launching from #{@get('from').cid} to #{@get('to').cid}"
    @get('from').changeCurrentStrengthBy -@strength
    @launched_at = @get('game').ticks
  
  fraction_done: ->
    (@get('game').ticks - @launched_at) / 30
  
  size: ->
    rad = (size) ->
      -0.0005*size^2+0.3*size
    
    if @strength < 200
      rad(@strength)
    else
      rad(200)
  
  update: ->
    if @fraction_done() >= 1
      @trigger 'arrive'
      @get('to').handle_incoming_fleet this
      @destroy()