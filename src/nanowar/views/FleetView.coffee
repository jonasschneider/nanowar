define (require) ->
  Backbone = require 'backbone'
  Game = require '../models/Game'

  return class FleetView extends Backbone.View
    initialize: (opts) ->
      @gameView = opts.gameView
      
      @model.bind 'change', @render, this
      @model.bind 'remove', @remove, this

      @model.bind 'launch', @start, this
      
      @el = @gameView.paper.circle()

      @strengthText = @gameView.paper.text -100, -100, @model.get('strength')

    render: ->
      return unless @model.get('launchedAt') > 0

      #@strengthText.attr text: @model.get('strength')

      #@el.animate
      #  cx: @model.get('posx')
      #  cy: @model.get('posy')
      #, Game.tickLength

      ctx = @gameView.canvas.getContext("2d")

      ctx.beginPath()
      ctx.arc(@model.get('posx'), @model.get('posy'), @radius, 0, Math.PI*2, true)
      ctx.closePath()
      ctx.fillStyle = 'orange'
      ctx.fill()

      text = @model.get('strength')

      w = ctx.measureText(text).width

      ctx.fillText(text, @model.get('posx') - w/2, @model.get('posy') - 10)

      #@x ||= 0
      #@x += 2

      #@el.attr
      #  cx: @x

      #@strengthText.animate
      #  x: @model.get('posx')
      #  y: @model.get('posy') - 10
      #, Game.tickLength

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

      @strengthText.attr
        font: '12px Arial'
        stroke:   'none'
        fill:     'black'
        x: Math.round @model.startPosition().x
        y: Math.round @model.startPosition().y - 10
      
      @el.attr
        r: @size()
        fill: @model.getRelation('owner').get('color')
        cx: @model.getRelation('from').get('x')
        cy: @model.getRelation('from').get('y') # hackish, should use fleet pos

      #@el.animate
      #  cx: Math.round @model.endPosition().x
      #  cy: Math.round @model.endPosition().y
      #, @timeInFlight()

      prevx = newx = @model.getRelation('from').get('x')
      prevy = newy = @model.getRelation('from').get('y')

      console.log "posx: #{@model.get('posx')}"

      curx = @model.get('posx')
      cury = @model.get('posy')

      @el.attr
        cx: curx
        cy: cury

      if @timeInFlight() > 500
        @el.attr r: 0
        @el.animate
          r: @size()
        , 200, 'bounce'
        
        disappear = =>
          @el.animate
            r: 0
          , 200, 'bounce'
        setTimeout disappear, @timeInFlight()-200
      
      this
      
    remove: ->
      @el.remove()
      @strengthText.remove()
      clearInterval @drawInterval
      @gameView.fleetvs.splice(@gameView.fleetvs.indexOf(this), 1)