define (require) ->
  require('processing-1.3.0')

  app = require('nanowar/models/App')
  appview = require('nanowar/views/AppView')
  window.App = new app
  window.AppView = new appview model: window.App