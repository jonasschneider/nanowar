define (require) ->
  Cell = require('nanowar/models/Cell')
  Fleet = require('nanowar/models/Fleet')
  Entity = require('nanowar/models/Entity')

  return class SendFleetCommand extends Entity
    relationSpecs:
      from:
        relatedModel: Cell
        directory: 'game.entities'
      to:
        relatedModel: Cell
        directory: 'game.entities'
        
    initialize: ->
      
    run: ->
      fleet = new Fleet 
        from: @get('from')
        to: @get('to')
        game: @game
      
      if fleet.launch()
        @game.entities.add fleet