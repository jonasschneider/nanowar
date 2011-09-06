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
  colors: ["#A0483E", "#666885", "green", "yellow"]
  
  defaults:
    name: 'anonymous coward'

  initialize: ->
    @bind 'add', ->
      unless @get 'color'
        @set { color: @colors[@game.getPlayers().length-1] }, silent: true

  toString: ->
    if @get('name')
      "[object Player '#{@get('name')}']"
    else
      super