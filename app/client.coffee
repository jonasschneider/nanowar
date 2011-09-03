#= require_tree models
#= require_tree views
#= require_tree helpers

$(document).ready ->
  
  #configure({viewBox: '0 0 500 700'}, true);
  #
  window.App = new Nanowar.App
  window.AppView = new Nanowar.views.AppView model: window.App