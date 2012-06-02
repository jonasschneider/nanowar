define (require) ->
  Backbone = require('backbone')
  _                     = require 'underscore'

  return class EntityCollection extends Backbone.Collection
    initialize: (models, options) ->
      unless options && options.types?
        throw "Need types"
      
      @types = {}
      @nextEntityIds = {}

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

    _add: (entity) ->
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

      super model