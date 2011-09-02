#= require "../models/Game"
onServer = false

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  _ = require('underscore')
  uuid = require('node-uuid');
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar
  
class root.IdentifyingCollection extends Backbone.Collection
  _add: (model, options) ->
    model = @_prepareModel model, options
    if onServer && !model.id
      model.set 
        id: uuid()
    super model, options