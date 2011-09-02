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
    @bind 'add', (cell) =>
      @trigger 'publish', { add: cell }
      
    @bind 'update', (data) =>
      @add data.add if data.add