# BUG: .getType does not respect anonymous subclasses - copying code doesn't help ;)

define (require) ->
  Backbone = require('backbone')

  return class SuperModel extends Backbone.Model
    @getType: ->
      this.toString().match(/^function (.*)\(\)/)[1]

    constructor: (attributes) ->
      attributes ||= {}
      nameGiver = this
      nameGiver = nameGiver.__proto__ while nameGiver.anonymousSubclass? && nameGiver.anonymousSubclass

      console.log nameGiver.constructor.toString()
      type = nameGiver.constructor.toString().match(/^function (.*)\(/)[1]

      nameGiver.type = type

      if attributes.type && attributes.type != type
        throw "Tried to initialize a #{type} with type set to #{attributes.type}"
      attributes.type = type
      super attributes
      @_previousAttributes.type = type
      
    toString: ->
      "[object #{@type}]"