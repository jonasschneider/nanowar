#= require "Game"
onServer = false

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Game = require('./Game').Game
  Nanowar.Players = require('./Players').Players
  _ = require('underscore')
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

class root.App extends Backbone.Model
  urlRoot: '/app'
  
  initialize: ->
    console.log "making app"
    
    @game = new Nanowar.Game
    @game.trigger 'lulz'
    
    @game.bind 'publish', (e) =>
      @trigger 'publish',
        game: e
    
        
    @bind 'update', (e) => 
      console.log("app got update")
      @game.trigger 'update', e.game if e.game?