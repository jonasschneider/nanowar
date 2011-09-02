#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.GameView extends Backbone.View
  initialize: ->
    console.log("hello thar")
    console.log(@model.cells)
    @model.cells.bind 'add', @addCell, this
        
    @fps_container = document.createElement( "text" )
    @fps_container.setAttribute("x", 700-200)
    @fps_container.setAttribute("y", 500-480)
    @fps_text = document.createTextNode("asdf")
    @fps_container.appendChild(@fps_text)
    @el.appendChild(@fps_container)

    $(@el).click (event) =>
      window.console.log("click event")
      @events.unshift event
      
  render: ->
    #@el.text("sup")
    console.log("rendering game")
    
    #@fps_text.nodeValue = @fps_info()
    this
  
  addCell: (cell) ->
    @el.appendChild(new Nanowar.views.CellView({model: cell}).render().el)