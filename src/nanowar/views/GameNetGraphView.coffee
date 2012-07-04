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
      @graphHeight = 150
      @height = 160
      @el = @make 'canvas'
      @el.setAttribute 'height', @height
      @el.setAttribute 'width', @width


    recordTick: (serverUpdate) ->
      @dataz.shift()
      if serverUpdate
        totalSize = JSON.stringify(serverUpdate).length
      else
        totalSize = 0
      @dataz.push totalUpdateSize: totalSize
      @render()

    render: ->
      ctx = @el.getContext('2d')
      ctx.clearRect 0, 0, @width, @height
      
      max = 1700
      scale = @graphHeight / max

      i = 0
      for datapoint in @dataz
        i++
        continue unless datapoint
        barHeight = datapoint.totalUpdateSize * scale

        if datapoint.totalUpdateSize > max
          ctx.fillStyle = 'red'
        else
          ctx.fillStyle = '#88f'
        ctx.fillRect i, @graphHeight-barHeight, 1, barHeight

      ctx.fillStyle = '#fff'
      ctx.fillText("tick "+@model.ticks, 10, @graphHeight+10);

      this