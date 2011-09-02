#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.GameView extends Backbone.View
  events:
    'click': 'handleClick'
  
  initialize: ->
    console.log("hello thar")
    console.log(@model.cells)
    @model.cells.bind 'add', @addCell, this
        
    @fps_container = document.createElementNS("http://www.w3.org/2000/svg", "text")
    @fps_container.setAttribute("x", 700-200)
    @fps_container.setAttribute("y", 500-480)
    @fps_text = document.createTextNode("my fps display")
    @fps_container.appendChild(@fps_text)
    @el.appendChild(@fps_container)

      
    @selectedCell = null
      
  render: ->
    #@el.text("sup")
    console.log("rendering game")
    
    #@fps_text.nodeValue = @fps_info()
    this
  
  addCell: (cell) ->
    @el.appendChild(new Nanowar.views.CellView({model: cell, gameView: this}).render().el)
    @el.appendChild(new Nanowar.views.CellDataView({model: cell}).render().el)
  
  select: (cell) ->
    @selectedCell = cell
    @trigger 'select'
  
  handleClick: ->
    window.console.log("click event")