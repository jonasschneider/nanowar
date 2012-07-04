define (require) ->
  Backbone = require('backbone')
  _                     = require 'underscore'

  class EntityCollection
    constructor: (models, options) ->
      unless options && options.types?
        throw "Need types"
      
      @types = {}
      @nextEntityIds = {}
      @entityAttributes = []

      @entities = []
      @entitiesById = {}

      _(options.types).each (klass, name) =>
        @types[name] = klass
        @nextEntityIds[name] = 1
        
      unless @game = options.game
        throw "Need game" 

    spawn: (type, attributes) ->
      klass = @types[type]
      attributes or (attributes = {})

      if attributes.id
        newId = attributes.id
        delete attributes.id
      else
        num = @nextEntityIds[type]++
        newId = type + '_' + num

      @_recordMutation ["spawned", type, {id: newId}]

      ent = new klass this, newId
      
      throw "id #{model.id} is in use" if @entitiesById[newId]
      @entities.push ent
      @entitiesById[newId] = ent
      

      ent._initialize()
      ent.set attributes

      @trigger 'add', ent

      ent

    get: (id) ->
      @entitiesById[id]

    remove: (entOrId) ->
      if entOrId.id?
        ent = entOrId
      else
        ent = @get(entOrId)

      ent.trigger 'remove'

      idx = @entities.indexOf(ent)
      @entities.splice(idx, 1)
      delete @entitiesById[ent.id]

      @_recordMutation ["removed", ent.id]
      null

    getAllOfType: (type) ->
      results = []
      for ent in @entities
        results.push ent if ent.type == type
      results

    enableStrictMode: ->
      @strictMode = true

    getEntityAttribute: (entId, attr) ->
      throw "unknown ent #{entId}" unless @get(entId)
      storedAttr = _(@entityAttributes).detect (storedAttr) ->
        storedAttr[0] == entId and storedAttr[1] == attr
      if storedAttr
        storedAttr[2]
      else
        undefined

    ticks: ->
      @game.ticks

    setEntityAttribute: (entId, attr, value) ->
      storedAttr = _(@entityAttributes).detect (storedAttr) ->
        storedAttr[0] == entId and storedAttr[1] == attr
      if storedAttr
        storedAttr[2] = value
      else
        @entityAttributes.push [entId, attr, value]
      @get(entId).trigger 'change'
      @_recordMutation ["changed", entId, attr, value]
      value

    mutate: (mutator) ->
      throw 'already mutating' if @currentMutations
      @currentMutationChanges = []

      mutator()

      d = @currentMutationChanges
      @currentMutationChanges = undefined
      d

    applyMutation: (mutation) ->
      for change in mutation
        if change[0] == "changed"
          @setEntityAttribute change[1], change[2], change[3]
        else if change[0] == "spawned"
          @spawn change[1], change[2]
        else if change[0] == "removed"
          @remove change[1]
        else
          throw "unkown change type #{change[0]}"

    attributesChangedByMutation: (mutation) ->
      changed = []
      for change in mutation
        if change[0] == "changed"
          changed.push [change[1], change[2], change[3]]
      changed

    snapshotFull: ->
      entities = []
      for ent in @entities
        spawn_attributes = { id: ent.id }
        attributes = _(@entityAttributes).select (a) ->
          a[0] == ent.id
        for attr in attributes
          spawn_attributes[attr[1]] = attr[2]

        entities.push [ent.type, spawn_attributes]
      entities

    applySnapshot: (snapshot) ->
      for args in snapshot
        @spawn.apply(this, args)

    snapshotAttributes: ->
      _.clone(attr) for attr in @entityAttributes

    restoreAttributeSnapshot: (snapshot) ->
      # TODO: notify changed entities
      @entityAttributes = snapshot

    _recordMutation: (mutation) ->
      if @currentMutationChanges
        @currentMutationChanges.push mutation
      else
        throw 'mutation outside mutate() in strict mode' if @strictMode

  _.extend(EntityCollection.prototype, Backbone.Events)

  methods = ['forEach', 'each', 'map', 'reduce', 'reduceRight', 'find', 'detect',
    'filter', 'select', 'reject', 'every', 'all', 'some', 'any', 'include',
    'contains', 'invoke', 'max', 'min', 'sortBy', 'sortedIndex', 'toArray', 'size',
    'first', 'rest', 'last', 'without', 'indexOf', 'lastIndexOf', 'isEmpty', 'groupBy'];

  # Mix in each Underscore method as a proxy
  _.each methods, (method) ->
    EntityCollection.prototype[method] = ->
      _[method].apply(_, [this.entities].concat(_.toArray(arguments)))

  return EntityCollection