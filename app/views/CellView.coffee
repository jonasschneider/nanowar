#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.CellView extends Backbone.View
  initialize: (options) ->
    @gameView = options.gameView
    
    @gameView.bind          'select',             @render, this
    @gameView.appView.bind  'change:localPlayer', @render, this
    @model.bind             'change',             @render, this
    
    @el = @gameView.el.circle @model.get('x'), @model.get('y'), 0
    
    @el.attr
      fill: 'black'
    @el.animate
      r: @model.get('size')
    , 700, 'bounce'
    
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