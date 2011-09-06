#= require <helpers/SuperModel>

onServer = false
if exports?
  onServer = true
  Backbone = require('../vendor/backbone')
  
  root = exports
  Nanowar = {}
  _ = require('underscore')
  uuid = require('node-uuid');
  Nanowar.SuperModel = require('./SuperModel').SuperModel
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar
  _ = window._


# 1. Don't forget to call super (after setting directory)
# Directory API: get(id) => model
# Related models have to be SuperModels (or RelationalModels) because #toJSON fetches the type

class root.RelationalModel extends Nanowar.SuperModel
  toJSON: ->
    json = super

    _(@relationSpecs).each (options, name) =>
      if related = @get(name)
        json[name] = { type: 'serializedRelation', model: related.get('type'), id: related.id, toJSON: ->
          this
        }

    json

  constructor: (attrs) ->
    @bind 'beforeInitialSet', =>
      _(@relationSpecs).each (options, name) =>
        options.relatedModelName ||= options.relatedModel.toString().match(/function (.+)\(\)/)[1]
        
        if(options.directory)
          # traverse path to directory
          segments = options.directory.split '.'
          options.directoryObject = this
          options.directoryObject = options.directoryObject[segments.shift()] until segments.length == 0
    
    super

  set: (attrs, options) ->
    thisType = @get('type') || attrs.type # for initial set
    
    _(@relationSpecs).each (options, name) =>
      attrs[name] = @_fetchRelation(name, attrs[name], thisType) if typeof attrs[name] != 'undefined'

    super

  _fetchRelation: (name, value, thisType) ->
    options = @relationSpecs[name]
    return null if value == null

    if value instanceof Backbone.Model
      id = value.get('id')
    else if value.type? && value.type == 'serializedRelation'
      if value.model != options.relatedModelName
        throw "While instantiating #{thisType}: Expected serialized relation of a #{options.relatedModelName} model, not a #{value.model} model"
      id = value.id
    else
      debug = try
          value = JSON.stringify value
        catch e
          value
      throw "While instantiating #{thisType}: Expected an instance of #{options.relatedModelName}, not #{debug}"

    if id && options.directoryObject && inDir = options.directoryObject.get id
      inDir
    else
      throw "While instantiating #{thisType}: #{options.relatedModelName} is not registered in this.#{options.directory}"


  changedAttributesToJSON: ->
    allJson = @toJSON()
    changedJson = {}
    _(@changedAttributes()).each (rawVal, name) ->
      changedJson[name] = allJson[name]
    changedJson