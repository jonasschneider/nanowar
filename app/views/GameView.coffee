#= require <nanowar>
#= require <vendor/raphael.js>

Nanowar = window.Nanowar

class Nanowar.views.GameView extends Backbone.View
  initialize: (options)->
    @appView = options.appView
    throw "need app view" unless @appView
    
    @model.cells.bind   'add', @addCell,  this
    @model.fleets.bind  'add', @addFleet, this
    @model.bind       'end', @halt, this
    
    @selectedCell = null
    
    @el = Raphael $('#nanowar')[0], 700, 500
    
    $(@el.canvas).click =>
      @handleClickInGameArea()
    
  
  updateObjects: ->
    console.log 'update call'
    console.log(arguments)
  
  addCell: (cell) ->
    cellView = new Nanowar.views.CellView({model: cell, gameView: this})
    cellView.render()
    
    cellView.bind 'click', =>
      @handleClickOnCellView cellView
    
  addFleet: (fleet) ->
    @el.appendChild(new Nanowar.views.FleetView({model: fleet}).render().el)
  
  handleClickInGameArea: ->
    unless @currentClickIsInCell
      @select null
    
    @currentClickIsInCell = false
  
  handleClickOnCellView: (cellClickedOn, e) ->
    @currentClickIsInCell = true
    
    if @selectedCell?
      # don't send to itself
      if cellClickedOn != @selectedCell
        @send_fleet @selectedCell.model, cellClickedOn.model
    else
      # only select cells owned by local player
      if @appView.localPlayer == cellClickedOn.model.get('owner')
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