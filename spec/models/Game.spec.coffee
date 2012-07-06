require ['nanowar/models/Game', 'nanowar/models/Cell', 'nanowar/models/Player'], (Game, Cell, Player) ->
  describe 'Game', ->
    describe '#getCells', ->
      it 'works', ->
        game = new Game
        cell =  game.world.spawn 'Cell'
        game.world.spawn 'Player'

        expect(game.getCells().length).toBe 1
        expect(game.getCells()[0]).toBe cell

    describe '#tellSelf', ->
      it 'can tick without tells', ->
        game = new Game onServer: true
        game.tick()

      it 'runs a tell when ticking', ->
        game = new Game onServer: true
        ran = false

        game.ahoy = ->
            ran = true

        game.tellSelf 'ahoy'
        expect(ran).toBe false

        game.tick()
        expect(ran).toBe true

      it 'runs tells in order', ->
        game = new Game onServer: true
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
        game = new Game onServer: true
        got = null

        game.ahoy = (arg)->
          got = arg

        game.tellSelf 'ahoy', 'set sails'
        game.tick()

        expect(got).toBe 'set sails'

    describe '#tick', ->
      it 'publishes entity mutations', ->
        game = new Game onServer: true
        output = false

        game.bind 'publish', (arg) ->
          output = arg

        p = game.world.spawn 'Player'

        game.ahoy = ->
          p.set color: 'yell'

        game.tellSelf 'ahoy'
        game.tick()

        expect(JSON.stringify(output)).toBe '{"tick":1,"entityMutation":[["changed","Player_1","color","yell"]]}'
       

    describe '#getPlayers', ->
      it 'works', ->
        game = new Game
        player = game.world.spawn 'Player', name: 'ohai'

        game.world.spawn 'Cell'

        expect(game.getPlayers().length).toBe 1
        expect(game.getPlayers()[0]).toBe player


    describe '#getWinner', ->
      it 'returns 0 when there are multiple players remaining', ->
        game = new Game
        p1 = game.world.spawn 'Player'
        p2 = game.world.spawn 'Player'
        c1 = game.world.spawn 'Cell'
        c1.setRelation 'owner', p1
        
        c2 = game.world.spawn 'Cell'
        c2.setRelation 'owner', p2

        expect(game.getWinner()).toBe null

      it 'returns the winner when there is only one player remaining', ->
        game = new Game
        p1 = game.world.spawn 'Player'
        p2 = game.world.spawn 'Player'
        c1 = game.world.spawn 'Cell'
        c1.setRelation 'owner', p2
        
        c2 = game.world.spawn 'Cell'
        c2.setRelation 'owner', p2

        expect(game.getWinner()).toBe p2