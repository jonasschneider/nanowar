module.exports =
  distance: (a, b) ->
    dx = a.x - b.x
    dy = a.y - b.y
    
    return Math.sqrt( dx*dx+dy*dy )
    
  nearestBorder: (centerPosition, radius, otherPosition) ->
    dx = otherPosition.x - centerPosition.x
    dy = centerPosition.y - otherPosition.y
    
    alpha = Math.atan(dy/dx)
    
    x = Math.cos(alpha)*radius
    y = Math.sin(alpha)*radius
    
    # trial and error
    if(centerPosition.x > otherPosition.x || centerPosition.y < otherPosition.y)
      x = x * -1 
      y = y * -1
      
    if(centerPosition.x <= otherPosition.x && centerPosition.y < otherPosition.y)
      x = x * -1 
      y = y * -1
    
    { x: centerPosition.x+x, y: centerPosition.y-y}