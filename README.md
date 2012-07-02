Up next: rework entity state preservation so no instance variables are used, but all state is passed explicitely

Retained mode  ^= DOM
Immediate mode ^= <canvas>

Sync issues
- chrome pauses js in background tabs
- timing, nondeterminism -> schedule at start of function if possible
see extrapolation below

Evented web model is inappropriate for parts of this task, because it makes certain aspects nondeterministic.
have to work around them in queues. for example, as server processes commands, entity updates have to be captured
in order to slice them up into discrete updates (ticks).
on the other hand, it saves work for independent messages (for example, although not entirely, user input), to be sent
to the server very timely on HTML events (button press)

Client Side Prediction
======================
- feasible entity-wide (representation of state as immutable dict)
- infeasible game-wide (have to deal with creation of predicted entities, map them to server prediction results etc)
=> That's how Source does it
  player position is within entity, player movemoent never modifies game state outside the player entity (gooba-stomping?)
=> No CSP for nanowar, for now
links game input and rendering together

Entity Interpolation
====================
- is still necessary, especially with 10 ticks/sec -> need to get at least to 30
entity interpolation works best if the renderer is stateless, that way we can feed it stuff without messing with the real entity
see: http://www.johno.se/book/pitch.html
for web games: since we run logic every frame, interpolation is only feasible for immediate mode graphics (canvas)
-> retained mode fails: if we change SVG properties every frame (x/y), we could as well use a canvas directly with better performance
the alternative: just let the browser do the interpolation with SVG animations that each last one tick

Entity Extrapolation
====================
assuming constant network latency, the clients are always a constant time behind the server (the difference coming from the time it took for the 'start' command to reach the client)
-> in theory, the clients should always have the current server data.
in practice this fails: network congestion, non-realtime-ness of TCP/Websockets etc
So, what to do when the client misses an update?
1. we could just pause the client until we have data agan.
  quite easy, makes for visible lag (which is probably acceptable for small delays)
  but once the info is there we are in the exact same state again.
  sounds almost too good to be true, and it is because we get out of sync with the server, which is catastrophic.
  this is somewhat noticeable: after "lagging" for 100 ticks, the results of user input are always 100 ticks behind what they should be, because the client will always be behind the server after a lag, and since it does not tick faster, it will never 'catch up',
  because the server just goes on ticking.
  there are 2 workarounds:
    a) it would work if we also pause the server when clients fail to acknowledge updates. see wc3. but this is infeasible for action games
    b) we could 'tick faster' after the lag
2. in order to keep the client running, we have to make up some data, by extrapolating the data we have.

in practice, a combination of these is probably the way to go; extrapolate data to compensate for small network hiccups, and freeze the client when the connection seems to drop entirely.

extrapolation is similar to client prediction; we make assumptions about the game state in the 'future' (i.e. no data available) that the server may or may not confirm.
however, contrary to prediction, we can deterministically know *when* we know whether we were wrong. that is, when predicting a delta for ticks 19->20, as soon as we get the real 19->20 delta, we can confirm or undo our predictions as told by the server.

the extrapolation algorithm takes previous deltas or states as input, and produces a delta.

approach to extrapolation:
- delta 12->13 arrives
- ticking to 13: apply 12->13 delta
- delta 13->14 arrives
- ticking to 14: apply 13->14 delta
- [network lag occurs]
- ticking to 15: - cannot apply 14->15 delta because it has not arrived yet
                 - create artificial 14->15 delta
                 - apply artificial 14->15 delta
- delta 14->15 arrives
- delta 15->16 arrives
- ticking to 16: - revert all the changes made by the artificial 14->15 delta
                 - apply 14->15 delta
                 - apply 15->16 delta

this will only become problematic if the lag also comes with a permanent change of latency, because then we will have to predict all the time:
- delta 12->13 arrives
- ticking to 13: apply 12->13 delta
- delta 13->14 arrives
- ticking to 14: apply 13->14 delta
- [network lag occurs]
- ticking to 15: extrapolate
- delta 14->15 arrives
- ticking to 16: - apply 14->15 delta
                 - now our prediction is corrected, but we need to make a new one

so how does the extrapolation work precisely?
  we create artificial 14->15 delta by extrapolating changes that were both in the 12->13 and the 13->14 delta
  this should naively prevent us from screwing up one-time changes
  naive linear extrapolation: x15 = x14 + (x14 - x13)
    that is, take the previous value and add to it the change from the value before that.



game modelling ideas:
'Evented Gaming' = don't update attributes in every update step, instead, set parameters that allow inferring of the updated attributes
    i.e. position of fleet vs start/end time of flight
  pro: lower update bandwith, con: possible sync issues

# client actions can take at worst 2*tickLength to propagate (command on server, results on client),
# not even counting for processing and network latency!