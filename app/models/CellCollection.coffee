#= require <nanowar>
#= require "Cell"

Nanowar = window.Nanowar

class Nanowar.models.CellCollection extends Backbone.Collection
  model: Nanowar.models.Cell