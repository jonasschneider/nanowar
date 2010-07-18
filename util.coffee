Element.prototype.addClass: (klass) ->
  classes = (@getAttribute("class") || "").split(" ")
  classes = [] if classes[0] == " "
  return if classes.indexOf(klass) != -1
  classes.push klass
  @setAttribute "class", classes.join(" ")

Element.prototype.removeClass: (klass) ->
  classes = (@getAttribute("class") || "").split(" ")
  classes = [] if classes[0] == " "
  classes.splice(classes.indexOf(klass), 1) if classes.indexOf(klass) != -1
  @setAttribute "class", classes.join(" ")

Element.prototype.setAttributes: (attrs) ->
  @setAttribute k, v for k, v of attrs