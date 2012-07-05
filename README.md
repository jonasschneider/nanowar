Retained mode  ^= DOM
Immediate mode ^= <canvas>

Sync issues
- chrome pauses js in background tabs
- timing, nondeterminism -> schedule at start of function if possible
see extrapolation below

Evented web model is inappropriate for parts of this task, because it makes certain aspects nondeterministic.
have to work around them in queues. for example, as server processes commands, entity updates have to be captured
in order to slice them up into discrete updates (ticks).
-> policy: bind() only in views. so no game state ever depends on events.
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
the alternative: just let the browser do the interpolation with SVG animations that each last one tick.
can be called cheating, but works well for retained-mode graphics.

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
  this is somewhat noticeable: after "lagging" for 10 ticks, the results of user input are always 10 ticks behind what they should be, because the client will always be behind the server after a lag
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

this will only become problematic if the lag also comes with a permanent change of latency, because then we will have to predict at every tick.
so how does the extrapolation work precisely?
  we create artificial 14->15 delta by extrapolating changes that were both in the 12->13 and the 13->14 delta
  this should naively prevent us from screwing up one-time changes
  naive linear extrapolation: x15 = x14 + (x14 - x13)
    that is, take the previous value and add to it the change from the value before that.




game modelling ideas:
the complexity of the entity data structure.
there are quite a lot of considerations that play into the design of the entitiy data structure:
- permanent interfaces for evented access - that is, views can bind to changes for one specific entity (like a fleet)
- computed attributes - 'pure' computations that only involve the state should be easily accesible for the views
- server/client synchronisation - we don't want client and server to ever disagree about the state
- access to the state both from a selected 'view' role (single attributes) and from an internal 'networking' role (bulk updates)
- temporary client autonomy - in order to apply extrapolation and (possibly later) client side prediction, clients need to be able to mutate the world state temporarily, in order to update the view. however, those changes have to be easily discardable (when the authoritative update arrives).

two fairly obvious solutions fail at one of these requirements:
- the classic object-oriented Backbone.js-powered model with persistent objects that keep state in instance variables. this works great for views that can simply bind to changes within observed models. however, this approach fails at client autonomy & synchronisation; it is very tedious to keep track of changes that are made, and what has to be undone when reverting the client-made changes. intial implementations used this approach.
- storing the entire purely in a single & simple javascript object ("POJO"). this approach provides easy synchronisation, and after screwing around with the game the client can just 'hammer-reset' the entire world by overwriting the one state variable. while probably the holy grail of functional purists, a lot of overhead is needed for evented access and computed attributes, as the attributes have to be copied around on demand in order to have both attributes and computed values at hand.
also, since the state is essentially discarded every time the state is updated, event-based subscriptions have to be made at a much higher level, which in turn is more error-prone when updating the state object. for example, the game has to keep track of coming and going entities, in order to create DOM elements accordingly (assuming 'retained mode' DOM). even in immediate graphics mode, if the drawing only depends on a single state (making it pure), all client-side-only information is essentially a hack. all character animations, particles etc. have to be stored inside the object, leading to infeasibly high bandwidth.

(aside: (un-)surprisingly, these two approaches can be compared to the immediate and retained graphics modes)

to come to an agreeable solution, an additional constraint is imposed: all client autonomy (prediction, extrapolation, possibly interpolation) is restricted to the data of an existing entity. (source engine: player positioning)

with this constraint, a possible solution becomes obvious: store all the entity data centrally, but also keep the dedicated entity objects, the entity collection etc., and redirect all access to entity attributes to the central collection. the collection notifies the entity when its data has changed, and the entity in turn notifies bound views.

this is not perfect, as it by definition forbids the spawning of new entities autonomously (case in point: sending fleets in nanowar, creating bullet entity when shooting in FPS games). these concerns will have to be addressed later, probably by keeping an seprate collection of temporary entities that have to be matched up when later server updates arrive.

aside: an initial approach consisted of augmenting the pure-data-gamestate with the functions an entity has. this had to be repeated every time the game state was updated. besides being brittle, this turned out to just be upside-down to the real conditions; the dynamic data was stored in a static position, and the static functions were added dynamically.

the current entity implementation:
- does not use Backbone.Model anymore, but is fundamentally API-compatible (views are still Backbone.View)
- knows 3 types of state representation:
  1. Full Snapshots generated by EntityCollection::snapshotFull
    These contain a complete snapshot of the collective entity state, and can therefore be used to create the entire game
    world from scratch.
    they are however infeasible to be used as the mechanism for dynamic updates (even with delta compression)
    because the client acts in a retained-mode way; it would have to manually guess which entities were deleted and which new ones were spawned.
    
    They are sent at load time to push map and player entities to the client.
  
  2. Attribute snapshots generated by EntityCollection::snapshotAttributes
    These contain only the attributes of all currently spawned entities.
    they can be used to easily manipulate the game state without causing havoc by creating or removing entities.
    
    These snapshots are used for entity extrapolation.

  3. Mutations
    These are proprietary delta formats that can transform one snapshot into another. What sets them apart from a snapshot delta is that in addition to changing entity attribute values, they can also contain messages passed between entities, giving them a procedural and temporal dimension. They can basically replay a slice of game time.

    This is the only state representation ever sent over the network, as it is the only one using a form of delta compression.


implementation details:
- static entity objects that can be bound to, but do not store any state
  they act as placeholders so views do not have to consider the game internals

'Evented Gaming' = don't update attributes in every update step, instead, set parameters that allow inferring of the updated attributes
    i.e. position of fleet vs start/end time of flight
  pro: lower update bandwith, con: possible sync issues, fails when additional logic is involved (i.e. merging fleets that 'collide')

# client actions can take at worst 2*tickLength to propagate (command on server, results on client),
# not even counting for processing and network latency!


TODO:
  - reduce mutations so multiple changes to a single attribute during a mutate() call do not produce redundant data
  - notify an entity if its attributes are changed behind the scenes
  - completely separate the spawning/persistentobject system from the raw attribute/mutation storage
  - try out how drawing fleets in a canvas affects performance