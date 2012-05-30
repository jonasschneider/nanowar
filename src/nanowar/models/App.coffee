define (require) ->
  Game = require('./Game')
  Backbone = require('backbone')

  return class App extends Backbone.Model
    urlRoot: '/app'
    
    initialize: ->
      @game = new Game
      
      console.log @get('onServer')
      if @get('onServer')
        @is_publishing = true
      else
        @is_publishing = false
        @game.bind 'start', =>
          @is_publishing = true
      
      @game.bind 'publish', (e) =>
        return unless @is_publishing
        @trigger 'publish',
          game: e
      
      @bind 'publish', (e) =>
        console.log("app sending update: "+JSON.stringify e)
      
      @bind 'update', (e) => 
        console.log("app getting update: "+JSON.stringify e)
        
        #@is_publishing = false
        @game.trigger 'update', e.game if e.game?
        @set e.set if e.set?
        #@is_publishing = true