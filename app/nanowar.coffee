#= require <vendor/backbone.js>
window.NanoWar = {}
window.Nanowar = { views: {}, models: {} }

Log = NanoWar.Log = Nanowar.Log = (msg) ->
  if window? && window.console?
    window.console.log(msg)