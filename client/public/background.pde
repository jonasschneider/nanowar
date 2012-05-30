/* @pjs preload="/images/particles/spark.png, /images/particles/glowsphere.png"; */


float curTime = 0.0;
float timeStep = 0.01;
int frames = 0;

boolean pressed = false;
int mouseDownSince;
int mouseDownFor = 0;
float attractionImportance = 0;
PVector mousePos;

ParticleSystem ps;
PImage[] particleImages;
PImage[] explosiveImages;

void setup() {
  adjustSize = function() { // TODO: debounce
    size($(window).width(), $(window).height())
  }

  require(['underscore'], function(_) {
    $(window).resize(_.debounce(_.bind(adjustSize, 300)));
  })
  
  adjustSize();
  
  
  frameRate(20);
  
  colorMode(RGB, 255, 255, 255, 100);
  
  particleImages = [loadImage("/images/particles/spark.png")];
  explosiveImages = particleImages
  //explosiveImages = [loadImage("/images/particles/glowsphere.png")];
  
  ps = new ParticleSystem(0, new PVector(width/2,height/2,0));
  imageMode(CENTER);
}
 
void draw() {
  start = new Date().getTime()
  curTime += timeStep;
  mousePos = new PVector(mouseX, mouseY);
  
  background(0,0,0,0);
  
  text(frames.toString()+ ", " +width+"x"+height, 10,10);
  text(ps.particles.size() + " particles", 10, 20);
  
  ps.run();

  //var defaultAux = [{x: 100, y:200, r:50}, {x: 300, y:200, r:50}, {x: 200, y:200, r:50}]
  var defaultAux = []

  var src = window.processingAuxSources || defaultAux
  
  src.forEach(function(aux) {
    ps.addParticle(new ExplosiveParticle(new PVector(aux.x, aux.y), aux.r, ps.n++));
  })
  
  ps.addParticle();
  
  text((new Date().getTime() - start).toString() + "ms", 10,30);
}

void mousePressed() {
  //pressed = true;
}

void mouseReleased()
{
  pressed = false;
}




class ParticleSystem {

  ArrayList particles;    // An arraylist for all the particles
  PVector origin;        // An origin point for where particles are born
  int n;

  ParticleSystem(int num, PVector v) {
    particles = new ArrayList();              // Initialize the arraylist
    origin = v.get();                        // Store the origin point
    for (int i = 0; i < num; i++) {
      particles.add(new Particle(origin, n++));    // Add "num" amount of particles to the arraylist
    }
  }

  void run() {
    // Cycle through the ArrayList backwards b/c we are deleting
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = (Particle) particles.get(i);
      
      if (p.dead())
        particles.remove(i);
      else
        p.run();
    }
  }

  void addParticle() {
    particles.add(new Particle(null, n++));
  }
  
  void addParticle(float x, float y) {
    particles.add(new Particle(new PVector(x,y), n++));
  }

  void addParticle(Particle p) {
    particles.add(p);
  }

  // A method to test if the particle system still has particles
  boolean dead() {
    if (particles.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }

}



// A simple Particle class

class Particle {
  PVector loc;
  PVector vel;
  PVector acc;
  PVector origin;
  float r;
  float timer;
  int n;
  
  PImage myImg;
  
  // Another constructor (the one we are using here)
  Particle(PVector l, int newN) {
    n = newN;
    myImg = particleImages[n % particleImages.length];
    r = 0.0;
    timer = 50.0;
    if(l)
      loc = l;
    else
      loc = new PVector(random(width), random(height));
    origin = loc;
    if(loc.x < 0 || loc.y < 0)
      timer = 0
    
    vel = new PVector(0,0);
  }

  void run() {
    update();
    render();
  }

  // Method to update location
  void update() {
    vel.add(new PVector((noise(n*10, curTime)-0.5)/2, (noise(n*100+50, curTime)-0.5)/2));
    
    if(timer > 40.0)
      r += 1;
    if(timer < 10.0)
      r -= 1;
    loc.add(vel);
    timer -= 1.0;
  }

  // Method to display
  void render() {
    pushMatrix(); 
    
    translate(loc.x, loc.y)
    scale(r/10*(noise(n*10)));
    
    image(myImg, 0,0);
    
    popMatrix();
  }
  
  // Is the particle still useful?
  boolean dead() {
    if (timer <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
}



class ExplosiveParticle {
  PVector loc;
  PVector vel;
  PVector acc;
  PVector origin;
  float r;
  float timer;
  int n;
  
  PImage myImg;
  
  // Another constructor (the one we are using here)
  ExplosiveParticle(PVector l, float requestedR, int newN) {
    
    n = newN;
    myImg = explosiveImages[n % explosiveImages.length];
    r = 0.0;
    timer = 20.0;
    if(l)
      loc = l;
    else
      loc = new PVector(random(width), random(height));
    origin = loc;
    
    float rFactor = (60+Math.pow(requestedR/2-30, 1.3)/4 )/ 20;
    
    // http://www.wolframalpha.com/input/?i=solve+v*20%2B1%2F2*a*20^2%3Dr+for+a
    vx = (random(1)-0.5)*requestedR/5;
    vy = (random(1)-0.5)*requestedR/5;
    vel = new PVector(vx, vy);
    
    acc = PVector.mult(vel, -.03);
  }

  void run() {
    update();
    render();
  }

  // Method to update location
  void update() {
    vel.add(acc);
    
    if(timer > 10.0)
      r += 1;
    if(timer < 10.0)
      r -= 1;
    loc.add(vel);
    timer -= 1.0;
  }

  // Method to display
  void render() {
    pushMatrix(); 
    
    translate(loc.x, loc.y)
    scale(r/10*(noise(n*10)));
    
    image(myImg, 0,0);
    //image(myImg, loc.x, loc.y)
    
    popMatrix();
  }
  
  // Is the particle still useful?
  boolean dead() {
    if (timer <= 0.0) {
      return true;
    } else {
      return false;
    }
  }
}


