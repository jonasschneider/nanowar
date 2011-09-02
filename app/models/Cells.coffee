#= require <nanowar>
#= require "Cell"

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Cell = require('./Cell')
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

class root.Cells extends Backbone.Collection
  model: Nanowar.Cell
  
  initialize: ->
    @bind 'all', =>
      return if arguments[0] == "tick"
      console.log 'event: ' + JSON.stringify(arguments)
    @bind 'add', (cell) =>
      @trigger 'publish', { add: cell }
      
    @bind 'update', (data) =>
      @add data.add if data.add