define (require) ->
  RelationalModel = require('nanowar/helpers/RelationalModel')

  return class Entity extends RelationalModel
    constructor: (attributes, options) ->
      if attributes && attributes.game
        @game = attributes.game
        delete attributes.game
      else
        throw "Entity needs game"
      
      @bind 'update', (data) ->
        @set data
      
      super

    toString: ->
      @id || super
