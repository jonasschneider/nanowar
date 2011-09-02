#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.CellDataView extends Backbone.View
  initialize: ->
    
    @model.bind 'change', @render, this
    
    @el = document.createElementNS( "http://www.w3.org/2000/svg", "text" )
    
    @el.setAttributes
      x: @model.get 'x'
      y: @model.get 'y'
      transform: "translate(0,5)"
      "class": "cell-data"
    
    @text = document.createTextNode("0")
    @el.appendChild(@text)
    
    setInterval _(@render).bind(this), 500
  
  render: ->
    @text.nodeValue = @model.getCurrentStrength()
    this