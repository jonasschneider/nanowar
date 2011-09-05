SuperModel = require('../../app/helpers/SuperModel.coffee').SuperModel

class Blog extends SuperModel

MySite = {}
class MySite.Header extends SuperModel

describe 'Nanowar.SuperModel', ->
  it 'sets the model name as an attribute', ->
    expect(new Blog().get 'type').toBe 'Blog'
  
  it 'ignores namespaces', -> # should it?
    expect(new MySite.Header().get 'type').toBe 'Header'
    
  it 'does not overwrite attributes', ->
    expect(new Blog(name: 'My Site').get 'name').toBe 'My Site'

  it 'ignores the type when already set', ->
    expect(new Blog(type: 'Blog').get 'type').toBe 'Blog'
    
  it 'throws when a different type is already set', ->
    expect ->
      new Blog(type: 'Post')
    .toThrow 'Tried to initialize a Blog with type set to Post'