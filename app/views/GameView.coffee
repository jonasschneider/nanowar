#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.GameView extends Backbone.View
  events:
    'click': 'handleClickInGameArea'
  
  initialize: ->
    @model.cells.bind   'add', @addCell,  this
    @model.fleets.bind  'add', @addFleet, this
    @model.bind       'end', @halt, this
    
    @selectedCell = null
    
  
  updateObjects: ->
    console.log 'update call'
    console.log(arguments)
  
  addCell: (cell) ->
    #@objects.add cell
    view = new Nanowar.views.CellView({model: cell, gameView: this})
    @el.appendChild(view.render().el)
    @el.appendChild(new Nanowar.views.CellDataView({model: cell}).render().el)
    
    view.bind 'click', _.bind(@handleClickOnCellView, this, view)
    
  addFleet: (fleet) ->
    @el.appendChild(new Nanowar.views.FleetView({model: fleet}).render().el)
  
  handleClickInGameArea: ->
    unless @currentClickIsInCell
      @select null
    
    @currentClickIsInCell = false
  
  handleClickOnCellView: (cellClickedOn, e) ->
    @currentClickIsInCell = true
    
    if @selectedCell?
      @send_fleet @selectedCell.model, cellClickedOn.model
    else
      @select cellClickedOn
  
  select: (cell) ->
    @selectedCell = cell
    @trigger 'select'
  
  send_fleet: (from, to) ->
    fleet = new Nanowar.Fleet 
      from: from
      to: to
      game: @model
      
    @model.fleets.add fleet