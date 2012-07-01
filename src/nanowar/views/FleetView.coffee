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

      @el.attr
        cx: Math.round @model.get('posx')
        cy: Math.round @model.get('posy')
    
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
      
      #@strengthText.animate
      #  x: Math.round @model.endPosition().x
      #  y: Math.round @model.endPosition().y - 10
      #, @timeInFlight()
      
      @el.attr
        r: @size()
        fill: @model.get('owner').get('color')
        #cx: Math.round @model.startPosition().x
        #cy: Math.round @model.startPosition().y
      
      #@el.animate
      #  cx: Math.round @model.endPosition().x
      #  cy: Math.round @model.endPosition().y
      #, @timeInFlight()
      
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