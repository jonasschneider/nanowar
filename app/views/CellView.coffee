#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.CellView extends Backbone.View
  initialize: ->
    console.log("hello thar cell")
    #@game.add new NanoWar.CellData(this)
    
    @el = document.createElementNS("http://www.w3.org/2000/svg", "circle")
    
  render: ->
    console.log @model
    @el.setAttributes
      cx: @model.get 'x'
      cy: @model.get 'y'
      r: @model.get 'size'
      class: "cell"
    
    
    if @model.owner && @model.owner.color
      @el.setAttribute("fill", @model.owner.color)
      @el.removeClass("neutral")
    else
      @el.setAttribute("fill", 'grey')
      @el.addClass("neutral")
        
    this
  
  draw: ->
    console.log("drawing cell")