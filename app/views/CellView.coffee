#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.CellView extends Backbone.View
  initialize: ->
    #@game.add new NanoWar.CellData(this)
    
    @el = document.createElementNS("http://www.w3.org/2000/svg", "circle")
    
  render: ->
    console.log @model
    @el.setAttributes
      cx: @model.get 'x'
      cy: @model.get 'y'
      r: @model.get 'size'
      class: "cell"
    
    console.log @model.get 'owner'
    if @model.get('owner') && @model.get('owner').color
      @el.setAttribute("fill", @model.get('owner').color)
      @el.removeClass("neutral")
    else
      @el.setAttribute("fill", 'grey')
      @el.addClass("neutral")
        
    this
  
  draw: ->
    console.log("drawing cell")