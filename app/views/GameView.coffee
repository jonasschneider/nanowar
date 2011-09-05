#= require <nanowar>
#= require <vendor/raphael.js>
#= require <commands/SendFleetCommand>

Nanowar = window.Nanowar

class Nanowar.views.GameView extends Backbone.View
  initialize: (options)->
    @appView = options.appView
    throw "need app view" unless @appView
    
    @model.entities.bind 'add', @addEntity,  this
    
    @selectedCell = null
    
    @el = Raphael $('#nanowar')[0], 700, 500
    
    $(@el.canvas).click =>
      @handleClickInGameArea()
    
  
  updateObjects: ->
    console.log 'update call'
    console.log(arguments)
  
  addEntity: (e) ->
    if e.type == 'Cell'
      console.log 'Yeah, thats a cell.'
      @addCell e
    
  addCell: (cell) ->
    cellView = new Nanowar.views.CellView({model: cell, gameView: this})
    cellView.render()
    
    cellView.bind 'click', =>
      @handleClickOnCellView cellView
    
  addFleet: (fleet) ->
    new Nanowar.views.FleetView({model: fleet, gameView: this})
  
  handleClickInGameArea: ->
    unless @currentClickIsInCell
      @select null
    
    @currentClickIsInCell = false
  
  handleClickOnCellView: (cellClickedOn, e) ->
    @currentClickIsInCell = true
    
    if @selectedCell?
      # don't send to itself
      if cellClickedOn != @selectedCell
        @model.trigger 'publish', sendFleetCommand: new Nanowar.SendFleetCommand(game: @model, from: @selectedCell.model, to: cellClickedOn.model)
    else
      # only select cells owned by local player
      if @appView.localPlayer == cellClickedOn.model.get('owner')
        @select cellClickedOn
  
  
  select: (cell) ->
    @selectedCell = cell
    @trigger 'select'