ParticleSystem ps;
PImage[] particleImages;
PImage[] explosiveImages;

void setup() {
  size($(window).width(), 300)
  
  frameRate(20);
  
  colorMode(RGB, 255, 255, 255, 100);
  
  particleImages = [loadImage("/images/particles/collisionorb.png"),  loadImage("/images/particles/bigspark.png")];
  explosiveImages = particleImages
  
  ps = new ParticleSystem(0, new PVector(width/2,height/2,0));

  window.runExplosion = function() {
    for(var i = 0; i < 250; i++)
      ps.addParticle(new HorzExplosiveParticle(50, 20, ps.n++));
  }

  imageMode(CENTER);
}
 
void draw() {
  background(0,0,0,0);
  
  ps.run();
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

class HorzExplosiveParticle {
  PVector loc;
  PVector vel;
  PVector acc;
  PVector origin;
  float r;
  float timer;
  int n;
  float myangle;
  
  PImage myImg;
  
  // Another constructor (the one we are using here)
  HorzExplosiveParticle(float y, float requestedR, int newN) {
    
    n = newN;
    myImg = explosiveImages[n % explosiveImages.length];
    r = 11.0 + (Math.random()-0.5)*10;
    timer = 14.0+ (Math.random()-0.5)*10;
    loc = new PVector(random()*width, (height / 2));
    origin = loc;
    
    float rFactor = (60+Math.pow(requestedR/2-30, 1.3)/4 )/ 20;
    
    // http://www.wolframalpha.com/input/?i=solve+v*20%2B1%2F2*a*20^2%3Dr+for+a
    vx = (random(1)-0.5)*requestedR/5 / 4;
    vy = (random(1)-0.5)*requestedR/5 * 6;
    vel = new PVector(vx, vy);
    myangle = float(Math.PI/2+(Math.random()-0.5)*1.2);
    
    acc = new PVector(vx/5, Math.abs(vy/15)+0.7);
  }

  void run() {
    update();
    render();
  }

  // Method to update location
  void update() {
    vel.add(acc);
    
    loc.add(vel);
    timer -= 1.0;
  }

  // Method to display
  void render() {
    pushMatrix(); 
    
    translate(loc.x, loc.y)
    scale(r/10*(noise(n*10)));
    rotate(Math.PI/2+(noise(n*100)-0.5)*1.2)
    
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