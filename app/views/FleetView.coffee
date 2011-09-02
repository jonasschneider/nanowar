#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.FleetView extends Backbone.View
  initialize: ->
    @model.bind 'change', @render, this
    @model.bind 'destroy', @remove, this
    
    @el = document.createElementNS( "http://www.w3.org/2000/svg", "circle" )
    @el.setAttribute "stroke", "none"
    
    @interval = setInterval _(@render).bind(this), 500
  
  start_position: ->
    Nanowar.util.nearest_border(@model.get('from').position(), @model.get('from').get('size'), @model.get('to').position())
  
  end_position: ->
    Nanowar.util.nearest_border(@model.get('to').position(), @model.get('to').get('size'), @model.get('from').position())
  
  position: ->
    startpos = @start_position()
    endpos = @end_position()
    
    posx = startpos.x + (endpos.x - startpos.x) * @model.fraction_done()
    posy = startpos.y + (endpos.y - startpos.y) * @model.fraction_done()
    { x: posx, y: posy }
  
  render: ->
    pos = @position()
    
    @el.setAttributes
      r:  @model.get 'strength'
      cx: Math.round pos.x
      cy: Math.round pos.y
    
    this
    
  remove: ->
    @el.parentNode.removeChild @el
    clearInterval @interval