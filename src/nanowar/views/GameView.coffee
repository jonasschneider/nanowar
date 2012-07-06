define (require) ->
  Backbone = require 'backbone'
  CellView = require './CellView'
  FleetView = require './FleetView'
  Fleet = require '../models/Fleet'
  EnhancerNodeView = require './EnhancerNodeView'
  GameNetGraphView = require './GameNetGraphView'
  SendFleetCommand = require '../commands/SendFleetCommand'
  Raphael = require 'raphael'
  _                 = require 'underscore'
  
  return class GameView extends Backbone.View
    initialize: (options)->
      @appView = options.appView
      throw "need app view" unless @appView
      
      @model.world.bind 'add', @addEntity,  this
      
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

      @fleetvs = []

      #setInterval =>
      #  v.render() for v in @fleetvs
      #  v.render() for v in @fleetvs
      #, 1000/30

      ng = new GameNetGraphView model: @model, gameView: this
      @container.appendChild(ng.render().el)

    updateObjects: ->
      console.log 'update call'
      console.log(arguments)
    
    addEntity: (e) ->
      switch e.type
        when 'Cell'
          cellView = new CellView model: e, gameView: this
          cellView.render()
          
          cellView.bind 'click', =>
            @handleClickOnCellView cellView
        
        when 'Fleet'
          @fleetvs.push new FleetView model: e, gameView: this
          
        when 'Player'
          'asdf'
        
        when 'EnhancerNode'
          new EnhancerNodeView model: e, gameView: this
        
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
          @model.fleetclicktime = new Date().getTime()

          @model.tellSelf 'sendFleet', @selectedCell.model, cellClickedOn.model
          #@model.tick()
          #@model.trigger 'publish', sendFleetCommand: new SendFleetCommand(game: @model, )
          @model.sendClientTells()
      else
        # only select cells owned by local player
        if (owner = cellClickedOn.model.getRelation('owner')) && @appView.localPlayerId == owner.id
          @select cellClickedOn
    
    
    select: (cell) ->
      @selectedCell = cell
      @trigger 'select'