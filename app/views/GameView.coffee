#= require <nanowar>

Nanowar = window.Nanowar

class Nanowar.views.GameView extends Backbone.View
  events:
    'click': 'handleClick'
  
  initialize: ->
    console.log("hello thar")
    console.log(@model.cells)
    @model.cells.bind 'add', @addCell, this
        
    @fps_container = document.createElementNS("http://www.w3.org/2000/svg", "text")
    @fps_container.setAttribute("x", 700-200)
    @fps_container.setAttribute("y", 500-480)
    @fps_text = document.createTextNode("my fps display")
    @fps_container.appendChild(@fps_text)
    @el.appendChild(@fps_container)
    
    @running = false
    @halt = false
    @selectedCell = null
    
    
    @objects = new Backbone.Collection
    @objects.bind 'change', @updateObjects, this
    
    @desired_tick_length = 1000/10
  
  updateObjects: ->
    console.log 'update call'
    console.log(arguments)
  
  fps_info: ->
    @last_tick_length = new Date().getTime() - @last_tick
    fps = Math.round(1000 / @last_tick_length)
    
    "#{fps} fps (#{@last_tick_length} ms/frame) #{@objects.length}"
  
  render: ->
    console.log("rendering game")
    
    #@fps_text.nodeValue = @fps_info()
    this
  
  addCell: (cell) ->
    @objects.add cell
    view = new Nanowar.views.CellView({model: cell, gameView: this})
    @el.appendChild(view.render().el)
    @el.appendChild(new Nanowar.views.CellDataView({model: cell}).render().el)
    
    view.bind 'click', _.bind(@handleClickOnCellView, this, view)
  
  select: (cell) ->
    @selectedCell = cell
    @trigger 'select'
    
  handleClick: ->
    unless @currentClickIsInCell
      @select null
    
    @currentClickIsInCell = false
  
  handleClickOnCellView: (cellClickedOn, e) ->
    @currentClickIsInCell = true
    
    if @selectedCell?
      @send_fleet @selectedCell.model, cellClickedOn.model
    else
      @select cellClickedOn
  
  send_fleet: (from, to) ->
    
    fleet = new Nanowar.models.Fleet 
      from: from
      to: to
      game: this.model
      
    @objects.add fleet
    
    if fleet.is_valid()
      fleet.launch()
      fleetView = new Nanowar.views.FleetView({model: fleet})
      @el.appendChild(fleetView.render().el)
  
  run: ->
    return if @running
    @running = true
    console.log "GOGOGOG"
    #object.setup(this) for object in @objects
    

    @schedule()
    
  schedule: ->
    window.setTimeout =>
      @tick()
    , @desired_tick_length
    
  tick: ->
    #console.log "tick"
    #try
    @model.tick()
    #catch error
    #console.log error
    @schedule() unless @halt