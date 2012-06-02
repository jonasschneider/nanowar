require ['nanowar/models/Game', 'nanowar/models/Cell', 'nanowar/models/Player'], (Game, Cell, Player) ->
  describe 'Game', ->
    describe '#getCells', ->
      it 'works', ->
        game = new Game
        cell = new Cell game: game

        game.entities.add cell
        game.entities.add new Player game: game

        expect(game.getCells().length).toBe 1
        expect(game.getCells()[0]).toBe cell

    describe '#tellSelf', ->
      it 'can tick without tells', ->
        game = new Game
        game.tick()

      it 'runs a tell when ticking', ->
        game = new Game
        ran = false

        game.ahoy = ->
            ran = true

        game.tellSelf 'ahoy'
        expect(ran).toBe false

        game.tick()
        expect(ran).toBe true

      it 'runs tells in order', ->
        game = new Game
        first = null
        hissed = false
        ahoy = false

        game.hiss = ->
          first = first || 'hiss'
          hissed = true

        game.ahoy = ->
          first = first || 'ahoy'
          ahoy = true

        game.tellSelf 'hiss'
        game.tellSelf 'ahoy'

        game.tick()

        expect(hissed).toBe true
        expect(ahoy).toBe true
        expect(first).toBe 'hiss'

      it 'runs a tell with an argument', ->
        game = new Game
        got = null

        game.ahoy = (arg)->
          got = arg

        game.tellSelf 'ahoy', 'set sails'
        game.tick()

        expect(got).toBe 'set sails'

    describe '#tick', ->
      it 'publishes the tells', ->
        game = new Game
        output = false

        game.bind 'publish', (arg) ->
          output = arg

        game.ahoy = ->

        game.tellSelf 'ahoy'
        game.tick()

        game2 = new Game
        called = false
        game2.ahoy = ->
          called = true
        
        game2.trigger 'update', output

        expect(called).toBe true
       

    describe '#getPlayers', ->
      it 'works', ->
        game = new Game
        player = new Player game: game, name: 'ohai'

        game.entities.add new Cell game: game
        game.entities.add player

        expect(game.getPlayers().length).toBe 1
        expect(game.getPlayers()[0]).toBe player


    describe '#getWinner', ->
      it 'returns 0 when there are multiple players remaining', ->
        game = new Game
        game.entities.add p1 = new Player game: game
        game.entities.add p2 = new Player game: game
        game.entities.add new Cell game: game, owner: p1
        game.entities.add new Cell game: game, owner: p2

        expect(game.getWinner()).toBe null

      it 'returns the winner when there is only one player remaining', ->
        game = new Game
        game.entities.add p1 = new Player game: game
        game.entities.add p2 = new Player game: game
        game.entities.add new Cell game: game, owner: p2
        game.entities.add new Cell game: game, owner: p2

        expect(game.getWinner()).toBe p2