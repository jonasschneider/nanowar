require ['nanowar/models/Game', 'nanowar/entities/Cell', 'nanowar/entities/Player'], (Game, Cell, Player) ->
  describe 'Game', ->
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

        expect(output.tick).toBe 1
        expect(JSON.stringify(output.entityMutation)).toBe '[["changed","Player_1$color","yell"]]'

    describe '#getWinner', ->
      it 'returns null when there are multiple players remaining', ->
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

    describe 'lagging', ->
      it 'extrapolates', ->
        server = new Game onServer: true
        client = new Game onServer: false

        cell = null

        server.bind 'publish', (what) ->
          client.trigger 'update', what
          console.log what

        server.spawnIt = ->
          cell = server.world.spawn 'Cell', x: 0

        server.moveIt = ->
          curX = cell.get('x')
          cell.set x: curX+10

        server.moveItSlow = ->
          curX = cell.get('x')
          cell.set x: curX+5

        # first, spawn the cell
        server.tellSelf 'spawnIt'
        server.tick() # 1
        client.tick() # 1

        expect(client.lastAppliedUpdateTicks).toBe 1

        # start to move it
        server.tellSelf 'moveIt'
        server.tick() # 2
        client.tick() # 2

        expect(client.lastAppliedUpdateTicks).toBe 2

        # move it again, todo: test that one-time moves dont extrapolate
        server.tellSelf 'moveIt'
        server.tick() # 3 
        client.tick() # 3

        expect(client.lastAppliedUpdateTicks).toBe 3
        expect(client.world.get(cell.id).get('x')).toBe 20

        # now we lag.
        client.tick() # 4
        expect(client.lastAppliedUpdateTicks).toBe 3
        expect(client.world.get(cell.id).get('x')).toBe 30

        # lag again
        client.tick() # 5
        expect(client.world.get(cell.id).get('x')).toBe 40

        expect(client.lastAppliedUpdateTicks).toBe 3

        # here we produce a prediction error
        server.tellSelf 'moveItSlow'
        server.tick() # 4
        client.tick() # 6

        # correct result now: 25 (known server value at tick 4) + 2 (tick diff) * 5 (last known delta) = 35
        expect(client.world.get(cell.id).get('x')).toBe 35

        # now the 2 late updates arrive
        server.tellSelf 'moveItSlow'
        server.tick() # 5
        server.tellSelf 'moveItSlow'
        server.tick() # 6

        # and we are up to speed again, but the movement actually stopped now
        server.tick() # 6

        client.tick()

        expect(client.world.get(cell.id).get('x')).toBe cell.get('x')


      it 'resets attributes back to the server value when the lag ends', ->
        server = new Game onServer: true
        client = new Game onServer: false

        cell = null

        server.bind 'publish', (what) ->
          client.trigger 'update', what
          console.log what

        server.spawnIt = ->
          cell = server.world.spawn 'Cell', x: 0

        server.moveIt = ->
          curX = cell.get('x')
          cell.set x: curX+10

        server.moveItSlow = ->
          curX = cell.get('x')
          cell.set x: curX+5

        # first, spawn the cell
        server.tellSelf 'spawnIt'
        server.tick() # 1
        client.tick() # 1

        expect(client.lastAppliedUpdateTicks).toBe 1

        # start to move it
        server.tellSelf 'moveIt'
        server.tick() # 2
        client.tick() # 2

        expect(client.lastAppliedUpdateTicks).toBe 2

        # move it again, todo: test that one-time moves dont extrapolate
        server.tellSelf 'moveIt'
        server.tick() # 3 
        client.tick() # 3

        expect(client.lastAppliedUpdateTicks).toBe 3
        expect(client.world.get(cell.id).get('x')).toBe 20

        # now we lag.
        client.tick() # 4
        expect(client.lastAppliedUpdateTicks).toBe 3
        expect(client.world.get(cell.id).get('x')).toBe 30

        # we recover from the lag
        server.tick() # 4
        server.tick() # 5
        client.tick() # 5

        expect(client.world.get(cell.id).get('x')).toBe cell.get('x')

