define (require) ->
  Backbone = require('backbone')
  _                     = require 'underscore'

  class World
    constructor: (types) ->
      throw "Need types" unless types
      
      @ticks = 0

      @types = {}
      @nextEntityIds = {}
      @state = {}

      @entities = []
      @entitiesById = {}

      _(types).each (klass, name) =>
        @types[name] = klass
        @nextEntityIds[name] = 1

    spawn: (type, attributes) ->
      klass = @types[type] or throw "unknown entity type #{type}"
      attributes or (attributes = {})

      if attributes.id
        newId = attributes.id
        delete attributes.id
      else
        num = @nextEntityIds[type]++
        newId = type + '_' + num

      @_recordMutation ["spawned", type, {id: newId}]

      ent = new klass this, newId
      ent.entityTypeName = type
      
      throw "id #{newId} is in use" if @entitiesById[newId]
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

    getEntitiesOfType: (typename) ->
      klass = @types[typename]
      results = []
      for ent in @entities
        results.push ent if ent instanceof klass
      results

    enableStrictMode: ->
      @strictMode = true

    getEntityAttribute: (entId, attr) ->
      throw "unknown ent #{entId}" unless @get(entId)
      key = @_generateAttrKey(entId, attr)
      @state[key]

    setEntityAttribute: (entId, attr, value) ->
      ent = @get(entId)
      throw "unknown ent #{entId}" unless ent
      key = @_generateAttrKey(entId, attr)
      @state[key] = value
      ent.trigger 'change'
      @_recordMutation ["changed", key, value]
      value

    _generateAttrKey: (entId, attr) ->
      # TODO: here we can enum
      entId+'$'+attr

    _parseAttrKey: (key) ->
      key.split('$')

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
          # TODO: refactor this so we can also modify state that is not an entity attribute
          parsed = @_parseAttrKey(change[1])
          @setEntityAttribute parsed[0], parsed[1], change[2]
        else if change[0] == "spawned"
          @spawn change[1], change[2]
        else if change[0] == "removed"
          @remove change[1]
        else
          throw "unkown change type #{change[0]}"

    attributesChangedByMutation: (mutation) ->
      changed = {}
      for change in mutation
        if change[0] == "changed"
          changed[change[1]] = change[2]
      changed

    snapshotFull: ->
      world = []
      for ent in @entities
        spawn_attributes = { id: ent.id }
        for own k, v of @state # TODO: performance?
          parsed = @_parseAttrKey(k)
          if parsed[0] == ent.id
            spawn_attributes[parsed[1]] = v

        world.push [ent.entityTypeName, spawn_attributes]
      console.log @state
      world

    applySnapshot: (snapshot) ->
      for args in snapshot
        @spawn.apply(this, args)

    snapshotAttributes: ->
      _.clone(@state)

    restoreAttributeSnapshot: (snapshot) ->
      # TODO: notify changed world
      @state = snapshot

    _recordMutation: (mutation) ->
      if @currentMutationChanges
        @currentMutationChanges.push mutation
      else
        throw 'mutation outside mutate() in strict mode' if @strictMode

  _.extend(World.prototype, Backbone.Events)

  methods = ['forEach', 'each', 'map', 'reduce', 'reduceRight', 'find', 'detect',
    'filter', 'select', 'reject', 'every', 'all', 'some', 'any', 'include',
    'contains', 'invoke', 'max', 'min', 'sortBy', 'sortedIndex', 'toArray', 'size',
    'first', 'rest', 'last', 'without', 'indexOf', 'lastIndexOf', 'isEmpty', 'groupBy'];

  # Mix in each Underscore method as a proxy
  _.each methods, (method) ->
    World.prototype[method] = ->
      _[method].apply(_, [this.entities].concat(_.toArray(arguments)))

  return World