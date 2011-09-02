#= require <nanowar>

Element.prototype.addClass = (klass) ->
  classes = (@getAttribute("class") || "").split(" ")
  classes = [] if classes[0] == " "
  return if classes.indexOf(klass) != -1
  classes.push klass
  @setAttribute "class", classes.join(" ")

Element.prototype.removeClass = (klass) ->
  classes = (@getAttribute("class") || "").split(" ")
  classes = [] if classes[0] == " "
  classes.splice(classes.indexOf(klass), 1) if classes.indexOf(klass) != -1
  @setAttribute "class", classes.join(" ")

Element.prototype.setAttributes = (attrs) ->
  @setAttribute k, v for k, v of attrs
  
Nanowar.util.nearest_border = (centerPosition, radius, otherPosition) ->
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
  
  return { x: centerPosition.x+x, y: centerPosition.y-y}