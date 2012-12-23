Backbone = require 'backbone'
_        = require 'underscore'

module.exports = class EnhancerNodeView extends Backbone.View
  initialize: (options) ->
    @gameView = options.gameView
    window.lastCellView = this
    
    @gameView.bind  'select',               @render,              this
    @model.bind     'change', @updateStrength, this
    @model.bind     'change', @updateColor, this
    @model.bind     'affectedCells:add',    @addConnectionTo,     this
    @model.bind     'affectedCells:remove', @removeConnectionTo,  this
    
    @el = document.createElementNS("http://www.w3.org/2000/svg", "use")
    @el.setAttribute("transform", "translate(#{@model.get 'x'},#{@model.get 'y'}), scale(.2)")
    @el.setAttribute("filter", "url(#compShadow)")
    
    @gameView.svg.appendChild(@el)
    
    @connections = {}

    @textview = @gameView.paper.text @model.get('x'), @model.get('y')+17, ''
    
    @textview.attr
      font: '12px Arial'
      stroke:   'none'
      fill:     'white'
      opacity: 0.6

    @updateColor()      
    @updateStrength()
    
    $(@el).click =>
      @trigger 'click'

  updateColor: ->
    c = @model.getRelation('owner')
    c = c && c.get('color')

    if c == 'red'
      link = '#EnhanceNodeIconRed'
    else if c == 'blue'
      link = '#EnhanceNodeIconBlue'
    else
      link = '#EnhanceNodeIconGrey'
    
    @el.setAttributeNS("http://www.w3.org/1999/xlink", "href", link)

  updateStrength: ->
    @textview.attr
      text: @model.get('strength')

  render: ->
    this
    
  addConnectionTo: (id) ->
    me = @model.position()
    cell = @model.collection.get(id)
    @connections[cell.id] = @gameView.paper.path "M#{me.x} #{me.y}L#{cell.get('x')} #{cell.get('y')}"
    console.log "enlarging #{id}"
  
  removeConnectionTo: (id) ->
    @connections[id] && @connections[id].remove()
    delete @connections[id]