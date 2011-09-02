#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.CellDataView extends Backbone.View
  initialize: ->
    @el = document.createElementNS( "http://www.w3.org/2000/svg", "text" )
    
    @el.setAttributes
      x: @model.get 'x'
      y: @model.get 'y'
      transform: "translate(0,5)"
      "class": "cell-data"
    
    @text = document.createTextNode("0")
    @el.appendChild(@text)
  
  render: ->
    @text.nodeValue = Math.floor @model.units
    this