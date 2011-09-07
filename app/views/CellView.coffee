#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.CellView extends Backbone.View
  initialize: (options) ->
    @gameView = options.gameView
    window.lastCellView = this
    
    @gameView.bind          'select',             @render,  this
    @gameView.appView.bind  'change:localPlayer', @render,  this
    @model.bind             'change',             @render,  this
    @model.bind             'incomingFleet',      @pop,     this
    
    @el = layers = @gameView.paper.set()

    layers.push(@shadow = @gameView.paper.circle(0,0,40))
    layers.push(@bg = @gameView.paper.circle(0,0,40))
    layers.push(metal = @gameView.paper.circle(0,0,40))
    layers.push(@fg = @gameView.paper.circle(0,0,40))
    
    metal.attr({fill: "url(#metalPattern)"})
    @shadow.attr({fill: "black" })
    @shadow.node.setAttribute("filter", "url(#cellShadow)")
    
    layers.attr({stroke: 'none', cx: @model.get('x'), cy: @model.get('y'), r: 0})
    
    #window.processingAuxSources ||= []
    #window.processingAuxSources.push
    #  x: @model.get('x') + $(@gameView.container).offset().left
    #  y: @model.get('y') + $(@gameView.container).offset().top
    #  r: @model.get('size') + 20
    
    @el.animate
      r: @model.get('size')
    , 700, 'bounce'
    
    $(_(@el.items).pluck('node')).click =>
      @trigger 'click'
      
    new Nanowar.views.CellDataView {model: @model, gameView: @gameView}
    
  render: ->
    if @gameView.appView.localPlayer && @gameView.appView.localPlayer == @model.get('owner')
      @el.attr
        stroke: 'green'
        strokeWidth: '2px'
    else
      @el.attr stroke: 'none'
    
    if @model.get('owner') && @model.get('owner').get('color')
      switch @model.get('owner').get('color')
        when 'red'
          @bg.attr({fill: "url(#redBackground)"})
          @fg.attr({fill: "url(#redForeground)"})
        when 'blue'
          @bg.attr({fill: "url(#blueBackground)"})
          @fg.attr({fill: "url(#blueForeground)"})
    else
      @bg.attr({fill: "url(#greyBackground)"})
      @fg.attr({fill: "url(#greyForeground)"})
    
    if @gameView.selectedCell == this
      @shadow.attr
        fill: 'orange'
    else
      @shadow.attr
        fill: 'black'
    
    this
    
  pop: ->
    @el.animate r: @model.get('size')+7, 50, 'bounce', => 
      @el.animate r: @model.get('size'), 60