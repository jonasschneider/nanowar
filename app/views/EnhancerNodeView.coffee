#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.EnhancerNodeView extends Backbone.View
  initialize: (options) ->
    @gameView = options.gameView
    window.lastCellView = this
    
    @gameView.bind  'select',               @render,              this
    @model.bind     'change',               @render,              this
    @model.bind     'affectedCells:add',    @addConnectionTo,     this
    @model.bind     'affectedCells:remove', @removeConnectionTo,  this
    
    @el = document.createElementNS("http://www.w3.org/2000/svg", "use")
    @el.setAttributeNS("http://www.w3.org/1999/xlink", "href", "#EnhanceNodeIconBlue")
    @el.setAttribute("transform", "translate(#{@model.get 'x'},#{@model.get 'y'}), scale(.2)")
    @el.setAttribute("filter", "url(#compShadow)")
    
    @gameView.svg.appendChild(@el)
    @gameView.paper.rect(440,120,100,100)
    
    @connections = {}
    
    _(@model.affectedCells()).each (cell) =>
      @addConnectionTo cell
    
    $(@el).click =>
      @trigger 'click'

  render: ->
    this
    
  addConnectionTo: (cell) ->
    me = @model.position()
    cpos = cell.position()
    @connections[cell.id] = @gameView.paper.path "M#{me.x} #{me.y}L#{cpos.x} #{cpos.y}"
  
  removeConnectionTo: (cell) ->
    @connections[cell.id].remove()
    delete @connections[cell.id]