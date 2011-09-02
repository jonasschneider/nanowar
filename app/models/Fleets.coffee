#= require <nanowar>
#= require "Fleet"

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Fleet = require('./Fleet').Fleet
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root      = Nanowar

class root.Fleets extends Backbone.Collection
  model: Nanowar.Fleet
  
  initialize: ->
    @bind 'add', (player) =>
      @trigger 'publish', { add: player }
      
    @bind 'update', (data) =>
      console.log 'i see dat fleet: ' + JSON.stringify data.add
      @add data.add if data.add