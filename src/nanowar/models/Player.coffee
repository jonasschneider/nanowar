define (require) ->
  Entity = require('./Entity')

  return class Player extends Entity
    type: 'Player'

    attributeSpecs:
      color: ''
      name: 'anonymous coward'

    colors: ["red", "blue", "green", "yellow"]
    
    initialize: ->
      unless @get 'color'
        @set { color: @colors[@collection.getAllOfType('Player').length-1] }, silent: true

    toString: ->
      if @get('name')
        "[object Player '#{@get('name')}']"
      else
        super