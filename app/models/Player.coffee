#= require <nanowar>

if exports?
  onServer = true
  Backbone = require('../vendor/backbone')
  
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

