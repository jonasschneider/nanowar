define (require) ->
  Game = require('./Game')
  Backbone = require('backbone')

  return class App extends Backbone.Model
    urlRoot: '/app'
    
    initialize: ->
      @game = new Game onServer: @get('onServer')
      
      @game.bind 'publish', (e) =>
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