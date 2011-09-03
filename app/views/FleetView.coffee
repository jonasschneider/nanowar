#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.FleetView extends Backbone.View
  initialize: (opts) ->
    @gameView = opts.gameView
    
    @model.bind 'change', @render, this
    @model.bind 'destroy', @remove, this
    
    @el = @gameView.el.circle()
    
    @start()
  
  start_position: ->
    Nanowar.util.nearest_border(@model.get('from').position(), @model.get('from').get('size'), @model.get('to').position())
  
  end_position: ->
    Nanowar.util.nearest_border(@model.get('to').position(), @model.get('to').get('size'), @model.get('from').position())
  
  size: ->
    rad = (size) ->
      -0.0005*size^2+0.3*size
    
    if @model.get('strength') < 200
      rad(@model.get 'strength')
    else
      rad(200)
    
  start: ->
    startpos = @start_position()
    endpos = @end_position()
    
    @el.attr
      r: 0
      fill: @model.get('owner').get('color')
      cx: Math.round startpos.x
      cy: Math.round startpos.y
    
    @el.animate
      cx: Math.round endpos.x
      cy: Math.round endpos.y
    , @gameView.model.ticksToTime @model.eta()
    
    @el.animate
      r: @size()
    , 200, 'bounce'
    
    this
    
  remove: ->
    @el.remove()