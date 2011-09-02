#= require <nanowar>

if exports?
  onServer = true
  Backbone = require('backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.Players = require('./Players').Players
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

class root.Player extends Backbone.Model
  defaults:
    name: 'anonymous coward'
  
  initialize: ->
    root.Player.dir ||= new Nanowar.Players
    root.Player.dir.add this

