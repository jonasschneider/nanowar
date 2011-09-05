SuperModel = require('../../app/helpers/SuperModel.coffee').SuperModel

class Blog extends SuperModel

class SpecialBlog extends Blog

class ThrowingInitializer extends SuperModel
  initialize: ->
    throw "I am evil"

class AnonymousBlog extends Blog
  anonymousSubclass: true

class BlackHatBlog extends AnonymousBlog
  anonymousSubclass: true

MySite = {}
class MySite.Header extends SuperModel

describe 'Nanowar.SuperModel', ->
  describe '.getType()', ->
    it 'works', ->
      expect(Blog.getType()).toBe 'Blog'
      expect(SpecialBlog.getType()).toBe 'SpecialBlog'
      #expect(AnonymousBlog.getType()).toBe 'Blog' # bug!
      #expect(BlackHatBlog.getType()).toBe 'Blog'


    it 'does not call initializer', ->
      expect(ThrowingInitializer.getType()).toBe 'ThrowingInitializer'


  
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



  describe 'subclasses', ->
    it 'also names subclasses', ->
      expect(new SpecialBlog().get 'type').toBe 'SpecialBlog'
    
    it 'makes subclasses anonymous when anonymousSubclass is set', ->
      expect(new AnonymousBlog().get 'type').toBe 'Blog'
  
    it 'works with nested anonymous subclasses', ->
      expect(new BlackHatBlog().get 'type').toBe 'Blog'