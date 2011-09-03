#= require_tree models
#= require_tree views
#= require_tree helpers

$(document).ready ->
  window.App = new Nanowar.App
  window.AppView = new Nanowar.views.AppView model: window.App