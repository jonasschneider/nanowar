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

      @bind 'update', (data) =>
        if data.add?
          @add data.add
          
        if data.changedEntityId?
          unless ent = @get(data.changedEntityId)
            throw "Could not find entity with id #{data.changedEntityId}"
          ent.trigger 'update', data.changeDelta
          @lastDelta = data.changeDelta
          @lastDelta.id = data.changedEntityId
        else
          @lastDelta = null


        if data.destroyedEntityId?
          unless ent = @get(data.destroyedEntityId)
            throw "Could not find entity with id #{data.destroyedEntityId}"
          @remove ent

      if @game.get('onServer')
        @bind 'add', (entity) =>
          @trigger 'publish', { add: entity }
          
        @bind 'change', (entity) =>
          if delta = entity.changedAttributes()
            @trigger 'publish', changedEntityId: entity.id, changeDelta: delta

        @bind 'remove', (entity) =>
          @trigger 'publish', destroyedEntityId: entity.id

    spawn: (type, attributes) ->
      klass = @types[type]

      if attributes.id
        newId = attributes.id
        delete attributes.id
      else
        num = @nextEntityIds[type]++
        newId = type + '_' + num

      @_recordMutation ["spawned", type, newId]

      ent = new klass this, newId

      @add ent

      ent.set attributes
      
      ent

    add: (entity) ->
      console.log 'adding', entity
      if _(@types).any((type) -> entity instanceof type ) # real entity
        model = entity
      else # serialized entity
        klass = @types[entity.type]

        unless klass
          typeNames = _(@types).map (klass, name) -> name
          throw "I dont know what to do with #{JSON.stringify entity}. Known types are [#{typeNames.join(', ')}]"
        entity.game = @game
        entityObj = new klass entity
        model = entityObj
      
      unless model.id # give it an id
        num = @nextEntityIds[model.type]++
        newId = model.type + '_' + num
        model.set id: newId

      for own k,v of entity.attributes
        @entityAttributes.push [entity.id, k, v]

      throw "id #{model.id} is in use" if @entitiesById[model.id]

      @entities.push model
      @entitiesById[model.id] = model

    get: (id) ->
      @entitiesById[id]

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
      @_recordMutation ["changed", entId, attr, value]
      value

    mutate: (mutator) ->
      throw 'already mutating' if @currentMutations
      @currentMutations = []

      mutator()

      d = @currentMutations
      @currentMutations = undefined
      d

    _recordMutation: (mutation) ->
      if @currentMutations
        @currentMutations.push mutation
      else
        throw 'mutation outside mutate() in strict mode' if @strictMode

  _.extend(EntityCollection.prototype, Backbone.Events)
  return EntityCollection