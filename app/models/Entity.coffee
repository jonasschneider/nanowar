#= require <nanowar>
#= require "Entity"
#= require <helpers/RelationalModel>

if exports?
  onServer = true
  Backbone = require('../vendor/backbone')
  
  root = exports
  Nanowar = {}
  Nanowar.RelationalModel = require('../helpers/RelationalModel').RelationalModel
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar


class root.Entity extends Nanowar.RelationalModel