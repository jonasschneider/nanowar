define (require) ->
  Entity = require('./Entity')

  return class Player extends Entity
    colors: ["red", "blue", "green", "yellow"]
    
    defaults:
      name: 'anonymous coward'

    initialize: ->
      @bind 'add', ->
        unless @get 'color'
          @set { color: @colors[@game.getPlayers().length-1] }, silent: true

    toString: ->
      if @get('name')
        "[object Player '#{@get('name')}']"
      else
        super