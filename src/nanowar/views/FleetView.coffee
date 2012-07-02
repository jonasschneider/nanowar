define (require) ->
  Backbone = require 'backbone'

  return class FleetView extends Backbone.View
    initialize: (opts) ->
      @gameView = opts.gameView
      
      @model.bind 'change', @render, this
      @model.bind 'remove', @remove, this
      
      @el = @gameView.paper.circle()
      
      
      @strengthText = @gameView.paper.text -100, -100, @model.get('strength')
      
      @start()
    
    render: ->
      @strengthText.attr text: @model.get('strength')

      # FIXME: We're immediately screwed when packets go missing
      #@el.animate
      #  cx: @model.get('posx')
      #  cy: @model.get('posy')
      #, @model.game.get('tickLength')

      #@x ||= 0
      #@x += 2

      #@el.attr
      #  cx: @x

      @strengthText.animate
        x: @model.get('posx')
        y: @model.get('posy') - 10
      , @model.game.get('tickLength')

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
      @strengthText.attr
        font: '12px Arial'
        stroke:   'none'
        fill:     'black'
        x: Math.round @model.startPosition().x
        y: Math.round @model.startPosition().y - 10
      
      diff = new Date().getTime() - @model.game.fleetclicktime

      @el.attr
        r: @size()
        fill: @model.get('owner').get('color')
        cx: @model.get('from').get('x')
        cy: @model.get('from').get('y') # hackish, should use fleet pos

      #@el.animate
      #  cx: Math.round @model.endPosition().x
      #  cy: Math.round @model.endPosition().y
      #, @timeInFlight()

      prevx = newx = @model.get('from').get('x')
      prevy = newy = @model.get('from').get('y')

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