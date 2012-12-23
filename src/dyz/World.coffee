Backbone = require('backbone')
_                     = require 'underscore'
WorldState = require 'dyz/helpers/WorldState'

module.exports = class World
  constructor: (types) ->
    throw "Need types" unless types
    
    @ticks = 0

    @types = {}
    @nextEntityIds = {}
    @state = new WorldState

    @state.registerEvent 'remove', _(@remove).bind(this)
    @state.registerEvent 'spawn', _(@spawn).bind(this)
    @state.registerEvent 'entmsg', _(@sendEntityMessage).bind(this)
    @state.onChange = _(@_touchChangedEntity).bind(this)

    @entities = []
    @entitiesById = {}

    _(types).each (klass, name) =>
      @types[name] = klass
      @nextEntityIds[name] = 1

  enableStrictMode: ->
    @state.strictMode = true

  #
  # ENTITY HOUSEKEEPING
  # 

  spawn: (type, attributes) ->
    klass = @types[type] or throw "unknown entity type #{type}"
    attributes or (attributes = {})

    if attributes.id
      newId = attributes.id
      delete attributes.id
    else
      num = @nextEntityIds[type]++
      newId = type + '_' + num

    ent = new klass this, newId
    ent.entityTypeName = type
    
    throw "id #{newId} is in use" if @entitiesById[newId]
    @entities.push ent
    @entitiesById[newId] = ent

    @state.recordEvent 'spawn', type, {id: newId}
    
    ent._initialize()
    ent.set attributes

    @trigger 'spawn', ent

    ent

  get: (id) ->
    @entitiesById[id]

  remove: (entOrId) ->
    if entOrId.id?
      id = entOrId.id
    else
      id = entOrId

    ent = @get(id)
    ent.trigger 'remove'

    @state.recordEvent 'remove', id
    
    idx = @entities.indexOf(ent)
    @entities.splice(idx, 1)
    delete @entitiesById[ent.id]

    for attr in _(ent.attributeSpecs).keys()
      k = @_generateAttrKey(id, attr)
      @state.unset k

    null

  getEntitiesOfType: (typename) ->
    klass = @types[typename]
    results = []
    for ent in @entities
      results.push ent if ent instanceof klass
    results

  #
  # ENTITY ATTRIBUTES
  #

  getEntityAttribute: (entId, attr) ->
    throw "on get: unknown ent #{entId}" unless @get(entId)
    key = @_generateAttrKey(entId, attr)
    @state.get key

  setEntityAttribute: (entId, attr, value) ->
    ent = @get(entId)
    unless ent
      console.trace()
      throw "on set: unknown ent #{entId}" 
    key = @_generateAttrKey(entId, attr)
    @state.set key, value
    ent.trigger 'change'
    value

  _generateAttrKey: (entId, attr) ->
    # TODO: here we can enum
    entId+'$'+attr

  _parseAttrKey: (key) ->
    if key.indexOf('$') > 0
      key.split('$')
    else
      null

  _touchChangedEntity: (key) ->
    if [entId, attr] = @_parseAttrKey(key)
      @get(entId).trigger 'change'



  sendEntityMessage: (entId, name, data) ->
    if data && data.toJSON
      payload = data.toJSON()
    else
      payload = data
    @state.recordEvent 'entmsg', entId, name, payload
    if data && data.entId
      arg = @get(data.entId)
    else
      arg = data
    @get(entId).trigger name, arg


  #
  # STATE PROXIES, SNAPSHOTS
  #

  mutate: (mutator) ->
    @state.mutate mutator

  applyMutation: (mutation) ->
    @state.applyMutation mutation

  snapshotAttributes: ->
    @state.makeSnapshot()

  applyAttributeSnapshot: (snapshot) ->
    # TODO: notify changed world
    @state.applySnapshot(snapshot)

  snapshotFull: ->
    for ent in @entities
      attr = ent.attributes()
      attr.id = ent.id
      [ent.entityTypeName, attr]

  applyFullSnapshot: (fullSnapshot) ->
    console.log fullSnapshot
    for [type, attributes] in fullSnapshot
      @spawn type, attributes

_.extend(World.prototype, Backbone.Events)

methods = ['forEach', 'each', 'map', 'reduce', 'reduceRight', 'find', 'detect',
  'filter', 'select', 'reject', 'every', 'all', 'some', 'any', 'include',
  'contains', 'invoke', 'max', 'min', 'sortBy', 'sortedIndex', 'toArray', 'size',
  'first', 'rest', 'last', 'without', 'indexOf', 'lastIndexOf', 'isEmpty', 'groupBy'];

# Mix in each Underscore method as a proxy
_.each methods, (method) ->
  World.prototype[method] = ->
    _[method].apply(_, [this.entities].concat(_.toArray(arguments)))