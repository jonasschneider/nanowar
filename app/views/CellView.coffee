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
    
    @el = @gameView.el.circle @model.get('x'), @model.get('y'), 0
    
    @el.attr
      fill: 'black'
    @el.animate
      r: @model.get('size')
    , 700, 'bounce'
    
    $(@el.node).click =>
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
      @el.attr fill: @model.get('owner').get('color')
    else
      @el.attr fill: 'grey'
    
    if @gameView.selectedCell == this
      @el.attr
        fill: 'orange'
        stroke: 'black'
    
    this
    
  pop: ->
    @el.animate r: @model.get('size')+7, 50, 'bounce', => 
      @el.animate r: @model.get('size'), 60