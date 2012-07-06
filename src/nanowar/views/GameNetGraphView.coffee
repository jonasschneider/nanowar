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

      @model.bind 'instrument:client-tick', @recordTick, this
      @model.bind 'run', @recordRunTime, this

      @width = @dataPoints + 40
      @graphHeight = 150
      @height = 230
      @el = @make 'canvas'
      @el.setAttribute 'height', @height
      @el.setAttribute 'width', @width

    recordRunTime: ->
      @timeAtRun = new Date().getTime()

    recordTick: (instrumentationData) ->
      @dataz.shift()
      @dataz.push instrumentationData
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

      max = Game.tickLength
      scale = 20 / max
      i = 0
      for datapoint in @dataz
        i++
        continue unless datapoint
        barHeight = datapoint.clientProcessingTime * scale + 2

        if datapoint.clientProcessingTime > max
          ctx.fillStyle = 'red'
          ctx.fillRect i, @graphHeight+40-barHeight, 1, barHeight
        else
          ctx.fillStyle = 'green'
          ctx.fillRect i, @graphHeight+40-barHeight, 1, 2
      
      ctx.fillStyle = '#aaa'
      ctx.fillRect 0, @graphHeight+40, @dataPoints, 1
      ctx.fillText ((@dataz[@dataPoints-1] || {}).clientProcessingTime or '0')+'ms', @dataPoints, @graphHeight+40
      
      i = 0
      for datapoint in @dataz
        i++
        continue unless datapoint
        barHeight = datapoint.serverProcessingTime * scale + 2

        if datapoint.serverProcessingTime > max
          ctx.fillStyle = 'red'
          ctx.fillRect i, @graphHeight+40-barHeight, 1, barHeight
        else
          ctx.fillStyle = 'blue'
          ctx.fillRect i, @graphHeight+60-barHeight, 1, 2

      ctx.fillStyle = '#aaa'
      ctx.fillRect 0, @graphHeight+60, @dataPoints, 1
      ctx.fillText ((@dataz[@dataPoints-1] || {}).serverProcessingTime or '0')+'ms', @dataPoints, @graphHeight+60

      ticksPerSecond = 1000 / Game.tickLength
      updateSizeSum = 0
      i = @dataPoints-ticksPerSecond
      while i < @dataPoints
        datapoint = @dataz[i++]
        continue unless datapoint
        updateSizeSum += datapoint.totalUpdateSize
      kbpsIn = (updateSizeSum/1024).toFixed(1)

      ctx.fillStyle = '#fff'
      ctx.fillText("tick #{@model.ticks} - #{kbpsIn}kb/s in", 10, @graphHeight+10);

      expectedPassedTicks = (new Date().getTime() - @timeAtRun) / 100
      syncError = (@model.ticks - expectedPassedTicks).toFixed(1)
      ctx.fillText("#{@model.world.entities.length} ents, sync error #{syncError} ticks", 10, @graphHeight+20);

      this