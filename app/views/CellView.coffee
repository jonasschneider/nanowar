#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.CellView extends Backbone.View
  initialize: (options) ->
    @gameView = options.gameView
    
    @gameView.bind          'select',             @render, this
    @gameView.appView.bind  'change:localPlayer', @render, this
    @model.bind             'change',             @render, this
    
    @el = document.createElementNS("http://www.w3.org/2000/svg", "circle")
    @el.addClass 'cell'
    
    $(@el).click _(@trigger).bind(this, 'click')
    
  render: ->
    if @gameView.selectedCell == this
      @el.addClass "selected"
    else
      @el.removeClass 'selected'
    
    @el.setAttributes
      cx: @model.get 'x'
      cy: @model.get 'y'
      r: @model.get 'size'
    
    #@el.setAttributes
    #  stroke: "green"
    #  'stroke-width': 2
    
    if @gameView.appView.localPlayer && @gameView.appView.localPlayer == @model.get('owner')
      @el.addClass 'allied'
    else
      @el.removeClass 'allied'
    
    if @model.get('owner') && @model.get('owner').get('color')
      @el.setAttribute("fill", @model.get('owner').get('color'))
      @el.removeClass("neutral")
    else
      @el.setAttribute("fill", 'grey')
      @el.addClass("neutral")
    
    this