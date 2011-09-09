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
    
    @container = $('#nanowar')[0]
    @paper = Raphael @container, 700, 500
    @svg = $('#nanowar svg')[0]
    @ready = 0
    window.$.get '/images/defs.svg', (defsSVG) =>
      @svg.appendChild defsSVG.getElementById 'nanowarDefs'
      @ready += 1
      @trigger 'ready' if @ready == 2
    
    window.$.get '/images/icons.svg', (iDefsSVG) =>
      iconDefs = iDefsSVG.getElementById "NanowarIcons"
      iconDefs.setAttribute "opacity", "0"
      @svg.appendChild iconDefs
      @ready += 1
      @trigger 'ready' if @ready == 2
    
    
    $(@paper.canvas).click =>
      @handleClickInGameArea()
    
  
  updateObjects: ->
    console.log 'update call'
    console.log(arguments)
  
  addEntity: (e) ->
    switch e.type
      when 'Cell'
        cellView = new Nanowar.views.CellView model: e, gameView: this
        cellView.render()
        
        cellView.bind 'click', =>
          @handleClickOnCellView cellView
      
      when 'Fleet'
        new Nanowar.views.FleetView model: e, gameView: this
        
      when 'Player'
        'asdf'
      
      when 'EnhancerNode'
        new Nanowar.views.EnhancerNodeView model: e, gameView: this
      
      else
        console.error "wtf is a #{e.type}? - #{JSON.stringify e}"

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