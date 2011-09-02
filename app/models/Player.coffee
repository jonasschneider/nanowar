#= require <nanowar>

Nanowar = window.Nanowar

# String name
class Nanowar.Player extends Backbone.Model
  defaults:
    name: 'anonymous coward'