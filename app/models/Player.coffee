#= require <nanowar>
#= require "Entity"

if exports?
  onServer = true
  root = exports
  
  Nanowar = {}
  Nanowar.Entity = require('./Entity').Entity
else
  Nanowar   = window.Nanowar
  root = Nanowar

class root.Player extends Nanowar.Entity
  
  defaults:
    name: 'anonymous coward'

