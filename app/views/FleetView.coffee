#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.FleetView extends Backbone.View
  initialize: (opts) ->
    @gameView = opts.gameView
    
    @model.bind 'change', @render, this
    @model.bind 'destroy', @remove, this
    
    @el = @gameView.el.circle()
    
    @start()
  
  size: ->
    rad = (size) ->
      -0.0005*size^2+0.3*size
    
    if @model.get('strength') < 200
      rad(@model.get 'strength')
    else
      rad(200)
    
  start: ->
    @el.attr
      r: 0
      fill: @model.get('owner').get('color')
      cx: Math.round @model.startPosition().x
      cy: Math.round @model.startPosition().y
    
    @el.animate
      cx: Math.round @model.endPosition().x
      cy: Math.round @model.endPosition().y
    , @gameView.model.ticksToTime @model.flightTime()
    
    @el.animate
      r: @size()
    , 200, 'bounce'
    
    this
    
  remove: ->
    @el.remove()