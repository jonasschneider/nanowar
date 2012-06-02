define (require) ->
  IdentifyingCollection = require('../helpers/IdentifyingCollection')
  _                     = require 'underscore'

  return class EntityCollection extends IdentifyingCollection
    initialize: (models, options) ->
      unless options && options.types?
        throw "Need types"
      
      @types = {}
      _(options.types).each (klass, name) =>
        @types[name] = klass
        
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
          console.log entity, this
          @trigger 'publish', destroyedEntityId: entity.id

    _add: (entity) ->
      if _(@types).any((type) ->
        entity instanceof type
      )
        super entity
      else
        klass = @types[entity.type]
        unless klass
          typeNames = _(@types).map (klass, name) -> name
          throw "I dont know what to do with #{JSON.stringify entity}. Known types are [#{typeNames.join(', ')}]"
        entity.game = @game
        entityObj = new klass entity
        super entityObj