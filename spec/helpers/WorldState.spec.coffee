WorldState = require('dyz/helpers/WorldState')

describe 'WorldState', ->
  beforeEach ->
    #@world = new World { MyEntity: MyEntity, MyOtherEntity: MyOtherEntity }
    #@anotherWorld = new World { MyEntity: MyEntity, MyOtherEntity: MyOtherEntity }
    @state = new WorldState
    @anotherState = new WorldState

  describe '#unset', ->
    it 'leaves no trace', -> 
      m = @state.mutate =>
        @state.set 'a', 'b'
        @state.unset 'a'

      expect(@state.get('a')).toBe undefined

      @anotherState.applyMutation(m)
      expect(@anotherState.get('a')).toBe undefined
  
  describe '#interpolate', ->
    it 'returns values in between the last set ones', -> 
      @state.set 'a', 4
      @state.set 'a', 5
      
      expect(@state.interpolate('a', 0)).toBe 4
      expect(@state.interpolate('a', 0.5)).toBe 4.5
      expect(@state.interpolate('a', 1)).toBe 5

      @state.set 'a', 10

      expect(@state.interpolate('a', 0.5)).toBe 7.5

    it 'does not interpolate when there is only one value', -> 
      @state.set 'a', 5
      
      expect(@state.interpolate('a', 0)).toBe 5
      expect(@state.interpolate('a', 0.5)).toBe 5
      expect(@state.interpolate('a', 1)).toBe 5

  describe '#mutate', ->
    it 'works', -> 
      m = @state.mutate =>
        @state.set 'a', 'b'

      expect(@state.get('a')).toBe 'b'

      @anotherState.applyMutation(m)

      expect(@anotherState.get('a')).toBe 'b'

    it 'also handles events', -> 
      called = false

      @state.registerEvent 'ohai', ->
        called = true

      m = @state.mutate =>
        @state.recordEvent 'ohai', {c: 'd'}, 5

      d1 = null
      d2 = null
      expect(called).toBe false

      @anotherState.registerEvent 'ohai', (arg1, arg2) ->
        d1 = arg1
        d2 = arg2

      @anotherState.applyMutation(m)
      expect(d1.c).toBe 'd'
      expect(d2).toBe 5

  describe '#_attributesChangedByMutation', ->
    it "returns only changes", ->
      mut = @state.mutate =>
        @state.set 'myattr', 1337

      a = @state._attributesChangedByMutation(mut)

      expect(JSON.stringify(a)).toBe JSON.stringify({"myattr": 1337})
