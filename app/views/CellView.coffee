#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.CellView extends Backbone.View
  initialize: (options) ->
    @gameView = options.gameView
    
    @gameView.bind          'select',             @render, this
    @gameView.appView.bind  'change:localPlayer', @render, this
    @model.bind             'change',             @render, this
    
    #@el = document.createElementNS("http://www.w3.org/2000/svg", "circle")
    #
      
    @el = @gameView.el.circle @model.get('x'), @model.get('y'), 0
    #@el.addClass 'cell'
    #console.error @el
    @el.attr
      fill: 'black'
      #r: @model.get 'size'
    @el.animate
      r: @model.get('size')
    , 700, 'bounce'
    
    console.log "hi, "
    console.error @el.node
    
    $(@el.node).click =>
      @trigger 'click'
    
  render: ->
    if @gameView.appView.localPlayer && @gameView.appView.localPlayer == @model.get('owner')
      @el.attr
        stroke: 'green'
        strokeWidth: '2px'
    else
      @el.attr stroke: 'none'
    
    if @model.get('owner') && @model.get('owner').get('color')
      @el.attr fill: @model.get('owner').get('color')
    else
      @el.attr fill: 'grey'
    
    if @gameView.selectedCell == this
      console.log "draw selection"
      @el.attr
        fill: 'orange'
        stroke: 'black'
    
    this