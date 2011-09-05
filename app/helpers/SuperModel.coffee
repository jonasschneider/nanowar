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

class root.SuperModel extends Backbone.Model
  @getType: ->
    checker = new this __justSetType: true
    checker.type

  constructor: (attributes) ->
    attributes ||= {}
    nameGiver = this.__proto__
    nameGiver = nameGiver.__proto__ while nameGiver.anonymousSubclass? && nameGiver.anonymousSubclass

    type = nameGiver.constructor.toString().match(/^function (.*)\(\)/)[1]

    if attributes.__justSetType
      @type = type
    else
      nameGiver.type = type
  
      if attributes.type && attributes.type != type
        throw "Tried to initialize a #{type} with type set to #{attributes.type}"
      attributes.type = type
      super attributes