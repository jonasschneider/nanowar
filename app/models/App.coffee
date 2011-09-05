#= require "Game"
onServer = false

if exports?
  onServer = true
  Backbone = require('../vendor/backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Game = require('./Game').Game
  _ = require('underscore')
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

class root.App extends Backbone.Model
  urlRoot: '/app'
  
  initialize: ->
    @game = new Nanowar.Game
    
    if onServer
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