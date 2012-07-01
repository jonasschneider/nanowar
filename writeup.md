Retained mode  ^= DOM
Immediate mode ^= <canvas>

Client Side Prediction
- feasible entity-wide (representation of state as immutable dict)
- infeasible game-wide (have to deal with creation of predicted entities, map them to server prediction results etc)
=> No CSP for nanowar, for now

=> That's how Source does it
  player position is within entity, player movemoent never modifies game state outside the player entity (gooba-stomping?)