define (require) ->
  Backbone = require 'backbone'
  Game = require '../models/Game'

  Array::rotate = (->
    unshift = Array::unshift
    splice = Array::splice
    (count) ->
      len = @length >>> 0
      count = count >> 0
      unshift.apply this, splice.call(this, count % len, len)
      this
  )()

  return class GameNetGraphView extends Backbone.View
    initialize: (opts)->
      @dataPoints = 100
      @gameView = opts.gameView
      @dataz = new Array(@dataPoints)

      @model.bind 'clientTick', @recordTick, this

      @width = @dataPoints
      @height = 150
      @el = @make 'canvas', height: @width, width: @width


    recordTick: (serverUpdate) ->
      @dataz.shift()
      if serverUpdate
        totalSize = JSON.stringify(serverUpdate).length
      else
        totalSize = 0
      @dataz.push totalUpdateSize: totalSize
      console.warn JSON.stringify(@dataz)
      @render()

    render: ->
      ctx = @el.getContext('2d')
      ctx.clearRect 0, 0, @width, @height
      
      max = 1700
      #for datapoint in @dataz
      #  continue unless datapoint
      #  max = Math.max(0, datapoint.totalUpdateSize)

      scale = @height / max
      #scale = 0.5
      
      i = 0
      for datapoint in @dataz
        i++
        continue unless datapoint
        barHeight = datapoint.totalUpdateSize * scale
        console.log barHeight
        #ctx.fillRect 0,0,100,100

        if datapoint.totalUpdateSize > max
          ctx.fillStyle = 'red'
        else
          ctx.fillStyle = '#33b'
        ctx.fillRect i, 0, 1, barHeight

      this