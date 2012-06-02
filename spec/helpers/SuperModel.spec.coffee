require ['nanowar/helpers/SuperModel'], (SuperModel) ->
  class Blog extends SuperModel

  class BlogWithConstructor extends SuperModel
    constructor: (param) ->
      super

  class SpecialBlog extends Blog

  class AnonymousBlog extends Blog
    anonymousSubclass: true

  class BlackHatBlog extends AnonymousBlog
    anonymousSubclass: true

  MySite = {}
  class MySite.Header extends SuperModel

  describe 'Nanowar.SuperModel', ->
    describe 'class naming', ->
      it 'sets the model name as an attribute', ->
        expect(new Blog().get 'type').toBe 'Blog'
    
      it 'does not mark the type as a changed attribute', ->
        b = new Blog title: 'My Page'
        expect(JSON.stringify b.changedAttributes()).toBe '{"title":"My Page"}'
      
      it 'ignores namespaces', -> # should it?
        expect(new MySite.Header().get 'type').toBe 'Header'

      it 'does not overwrite attributes', ->
        expect(new Blog(name: 'My Site').get 'name').toBe 'My Site'

      it 'ignores the type when already set', ->
        expect(new Blog(type: 'Blog').get 'type').toBe 'Blog'
      
      it 'also works when the class constructor takes arguments', ->
        expect(new BlogWithConstructor().get 'type').toBe 'BlogWithConstructor'
    
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

    describe '#toString()', ->
      it 'returns class name', ->
        expect(new Blog().toString()).toBe '[object Blog]'
        expect(new SpecialBlog().toString()).toBe '[object SpecialBlog]'