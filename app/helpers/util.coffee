#= require <nanowar>

if exports?
  onServer = true
  root = exports
else
  Backbone  = window.Backbone
  Nanowar   = window.Nanowar
  root = Nanowar

root.util =
  distance: (a, b) ->
    dx = Math.abs a.x - b.x
    dy = Math.abs a.y - b.y
    
    return Math.sqrt( (dx^2)+(dy^2) )