define (require) ->
  app = require('dyz/Peer')
  appview = require('nanowar/views/AppView')
  window.App = new app
  window.AppView = new appview model: window.App