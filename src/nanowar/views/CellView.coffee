Backbone = require 'backbone'
CellDataView = require './CellDataView'

module.exports = class CellView extends Backbone.View
  initialize: (options) ->
    @gameView = options.gameView
    window.lastCellView = this
    
    @gameView.bind          'select',             @render,  this
    @gameView.appView.bind  'change:localPlayerId', @render,  this
    @model.bind             'change',             @render,  this
    @model.bind             'change',             @pop,     this
    
    @el = layers = @gameView.paper.set()

    layers.push @shadow = @gameView.paper.circle(0,0,40)
    layers.push @selectedShadow = @gameView.paper.circle(0,0,40)
    layers.push @bg = @gameView.paper.circle(0,0,40)
    layers.push metal = @gameView.paper.circle(0,0,40)
    layers.push @fg = @gameView.paper.circle(0,0,40)
    layers.push @hover = @gameView.paper.circle(0,0,40)
    
    @hover.attr fill: 'white', opacity: 0
    metal.attr fill: "url(#metalPattern)"
    @shadow.attr fill: 'black'
    @selectedShadow.attr fill: 'white'
    @shadow.node.setAttribute "filter", "url(#cellShadow)" # Raphael doesn't like the filter attribute
    @selectedShadow.node.setAttribute "filter", "url(#cellShadow)" # Raphael doesn't like the filter attribute
    
    layers.attr
      stroke: 'none'
      r: 0

    console.warn "rendering, r=#{@model.get('size')}"
    
    @animating = true
    @el.animate
      r: @model.get('size')
    , 700, 'bounce', =>
      @animating = false
    
    $(@hover.node).click =>
      @trigger 'click'
    
    $(@hover.node).mouseover =>
      if @model.getRelation('owner') && @gameView.appView.localPlayerId == @model.getRelation('owner').id
        @hover.attr opacity: 0.05
    
    $(@hover.node).mouseout =>
      @hover.attr opacity: 0
    
    new CellDataView {model: @model, gameView: @gameView, cellView: this}

  render: ->
    @el.attr
      cx: @model.get('x')
      cy: @model.get('y')
    
    unless @animating
      @el.attr r: @model.get('size')
    
    if @model.getRelation('owner') && @model.getRelation('owner').get('color')
      switch @model.getRelation('owner').get('color')
        when 'red'
          @bg.attr({fill: "url(#redBackground)"})
          @fg.attr({fill: "url(#redForeground)"})
        when 'blue'
          @bg.attr({fill: "url(#blueBackground)"})
          @fg.attr({fill: "url(#blueForeground)"})
        else
          throw "I don't know color #{@model.getRelation('owner').get('color')}"
    else
      @bg.attr({fill: "url(#greyBackground)"})
      @fg.attr({fill: "url(#greyForeground)"})
    
    if @gameView.selectedCell == this
      @selectedShadow.attr opacity: 0.7
      @shadow.attr opacity: 0
    else
      @selectedShadow.attr opacity: 0
      @shadow.attr opacity: 1
    
    this

  pop: ->
    @el.animate r: @model.get('size')+7, 50, 'bounce', => 
      @el.animate r: @model.get('size'), 60