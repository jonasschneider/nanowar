define (require) ->
  Backbone = require('backbone')

  return class SuperModel extends Backbone.Model
    constructor: (attributes) ->
      attributes ||= {}
      nameGiver = this
      nameGiver = nameGiver.__proto__ while nameGiver.anonymousSubclass? && nameGiver.anonymousSubclass

      type = nameGiver.constructor.toString().match(/^function (.*)\(/)[1]

      nameGiver.type = type

      if attributes.type && attributes.type != type
        throw "Tried to initialize a #{type} with type set to #{attributes.type}"
      attributes.type = type
      super attributes
      @_previousAttributes.type = type
      
    toString: ->
      "[object #{@type}]"