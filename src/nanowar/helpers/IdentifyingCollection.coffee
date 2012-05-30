define (require) ->
  Backbone = require('backbone')
  uuid = require('uuid')

  return class IdentifyingCollection extends Backbone.Collection
    _add: (model, options) ->
      model = @_prepareModel model, options
      if !model.id
        console.log "Setting UUID"
        model.set 
          id: uuid()
      super model, options