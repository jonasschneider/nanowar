#= require <vendor/backbone.js>
window.NanoWar = {}
window.Nanowar = { views: {}, models: {}, util: {} }

Log = NanoWar.Log = Nanowar.Log = (msg) ->
  if window? && window.console?
    window.console.log(msg)