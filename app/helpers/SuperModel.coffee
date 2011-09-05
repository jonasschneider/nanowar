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
  constructor: ->
    @type = this.__proto__.constructor.toString().match(/^function (.*)\(\)/)[1]
    super