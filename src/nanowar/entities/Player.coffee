define (require) ->
  Entity = require('nanowar/Entity')

  return class Player extends Entity
    type: 'Player'

    attributeSpecs:
      color: ''
      name: 'anonymous coward'

    colors: ["red", "blue", "green", "yellow"]
    
    initialize: ->
      unless @get 'color'
        @set { color: @colors[@collection.getEntitiesOfType('Player').length-1] }, silent: true

    toString: ->
      if @get('name')
        "[object Player '#{@get('name')}']"
      else
        super