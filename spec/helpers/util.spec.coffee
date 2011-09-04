util = require('../../app/helpers/util.coffee').util

describe 'util', ->
  describe '#distance', ->
    it 'is right', ->
      expect(util.distance({x:0,y:0}, {x:0, y:0})).toBe 0

      expect(util.distance({x:0,y:0}, {x:10, y:0})).toBe 10
      expect(util.distance({x:0,y:0}, {x:0, y:10})).toBe 10

      expect(util.distance({x:0,y:0}, {x:-10, y:0})).toBe 10
      expect(util.distance({x:0,y:0}, {x:0, y:-10})).toBe 10

      expect(util.distance({x:0,y:0}, {x:3, y:4})).toBe 5
      expect(util.distance({x:0,y:0}, {x:-3, y:-4})).toBe 5