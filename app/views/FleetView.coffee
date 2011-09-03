#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.FleetView extends Backbone.View
  initialize: (opts) ->
    @gameView = opts.gameView
    
    @model.bind 'change', @render, this
    @model.bind 'destroy', @remove, this
    
    @el = @gameView.el.circle()
    
    @start()
  
  startPosition: ->
    @model.get('from').position()
  
  endPosition: ->
    @model.get('to').position()
  
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
      cx: Math.round @startPosition().x
      cy: Math.round @startPosition().y
    
    @el.animate
      cx: Math.round @endPosition().x
      cy: Math.round @endPosition().y
    , @gameView.model.ticksToTime @model.flightTime()
    
    @el.animate
      r: @size()
    , 200, 'bounce'
    
    this
    
  remove: ->
    @el.remove()