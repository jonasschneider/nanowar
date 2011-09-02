#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.GameView extends Backbone.View
  events:
    'click': 'handleClickInGameArea'
  
  initialize: ->
    @model.cells.bind 'add', @addCell, this
    @model.bind       'end', @halt, this
    
    @selectedCell = null
    
    @objects = new Backbone.Collection
    @objects.bind 'change', @updateObjects, this
  
  updateObjects: ->
    console.log 'update call'
    console.log(arguments)
  
  addCell: (cell) ->
    @objects.add cell
    view = new Nanowar.views.CellView({model: cell, gameView: this})
    @el.appendChild(view.render().el)
    @el.appendChild(new Nanowar.views.CellDataView({model: cell}).render().el)
    
    view.bind 'click', _.bind(@handleClickOnCellView, this, view)
  
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
      game: this.model
      
    @objects.add fleet
    
    if fleet.is_valid()
      fleet.launch()
      fleetView = new Nanowar.views.FleetView({model: fleet})
      @el.appendChild(fleetView.render().el)