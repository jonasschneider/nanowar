#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.CellDataView extends Backbone.View
  initialize: (options)->
    @gameView = options.gameView
    @cellView = options.cellView
    
    @model.bind 'change', @render, this
    
    @el = @gameView.paper.text @model.get('x'), @model.get('y'), "0"
    
    @el.attr
      font: '12px Arial'
      stroke:   'none'
      fill:     'white'
    
    setInterval _(@render).bind(this), 400
    
    $(@el.node).click =>
      @cellView.trigger 'click'
  
  render: ->
    @el.attr text: @model.getCurrentStrength()
    this