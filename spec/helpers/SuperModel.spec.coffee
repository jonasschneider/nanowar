SuperModel = require('../../app/helpers/SuperModel.coffee').SuperModel

class Blog extends SuperModel

MySite = {}
class MySite.Header extends SuperModel

describe 'Nanowar.SuperModel', ->
  it 'sets the model name', ->
    expect(new Blog().type).toBe 'Blog'
  
  it 'ignores namespaces', -> # should it?
    expect(new MySite.Header().type).toBe 'Header'