define (require) ->
  Backbone = require 'backbone'
  Game = require 'dyz/Game'

  return class FleetView extends Backbone.View
    initialize: (opts) ->
      @gameView = opts.gameView
      
      @model.bind 'remove', @remove, this
      @model.bind 'launch', @start, this
      
    render: (time) ->
      return unless @model.get('launchedAt') > 0

      ctx = @gameView.canvas.getContext("2d")
      
      ctx.beginPath()

      x = @model.interpolate('posx', time)
      y = @model.interpolate('posy', time)
      
      ctx.arc(x, y, @radius, 0, Math.PI*2, true)
      ctx.closePath()
      ctx.fillStyle = 'orange'
      ctx.fill()

      text = @model.get('strength')
      w = ctx.measureText(text).width
      ctx.fillText(text, x - w/2, y - @radius - 5)

    size: ->
      rad = (size) ->
        -0.0005*size^2+0.3*size
      
      if @model.get('strength') < 200
        rad(@model.get 'strength')
      else
        rad(200)
    
    timeInFlight: ->
      @gameView.model.ticksToTime @model.flightTime()
    
    start: ->
      @radius = @size()

      #if @timeInFlight() > 500
      #  @el.attr r: 0
      #  @el.animate
      #    r: @size()
      #  , 200, 'bounce'
      #  
      #  disappear = =>
      #    @el.animate
      #      r: 0
      #    , 200, 'bounce'
      #  setTimeout disappear, @timeInFlight()-200
      
      this
      
    remove: ->
      @gameView.fleetvs.splice(@gameView.fleetvs.indexOf(this), 1)