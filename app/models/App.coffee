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
    
    @is_publishing = true
    
    @game.bind 'publish', (e) =>
      return unless @is_publishing
      @trigger 'publish',
        game: e
    
    @bind 'publish', (e) =>
      console.log("app sending update: "+JSON.stringify e)
    
    @bind 'update', (e) => 
      console.log("app getting update: "+JSON.stringify e)
      
      @is_publishing = false
      @game.trigger 'update', e.game if e.game?
      @is_publishing = true