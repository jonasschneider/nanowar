if exports?
  onServer = true
  Backbone = require('../vendor/backbone')
  
  root = exports
  Nanowar = {}
  _               = require 'underscore'
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

# BUG: .getType does not respect anonymous subclasses - copying code doesn't help ;)

class root.SuperModel extends Backbone.Model
  @getType: ->
    this.toString().match(/^function (.*)\(\)/)[1]

  constructor: (attributes) ->
    attributes ||= {}
    nameGiver = this.__proto__
    nameGiver = nameGiver.__proto__ while nameGiver.anonymousSubclass? && nameGiver.anonymousSubclass

    type = nameGiver.constructor.toString().match(/^function (.*)\(\)/)[1]

    nameGiver.type = type

    if attributes.type && attributes.type != type
      throw "Tried to initialize a #{type} with type set to #{attributes.type}"
    attributes.type = type
    super attributes