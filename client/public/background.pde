/* @pjs preload="/images/particles/spark.png"; */


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

void setup() {
  adjustSize = function() { // TODO: debounce
    size($(window).width(), $(window).height())//document.body.clientWidth, document.body.clientHeight);
  }
  
  $(window).resize(_.debounce(adjustSize, 300));
  
  adjustSize();
  
  
  frameRate(20);
  
  colorMode(RGB, 255, 255, 255, 100);
  
  particleImages = [loadImage("/images/particles/spark.png")]
  
  ps = new ParticleSystem(1, new PVector(width/2,height/2,0));
}
 
void draw() {
  curTime += timeStep;
  mousePos = new PVector(mouseX, mouseY);
  
  background(0,0,0,0);
  
  text(frames.toString()+ ", " +width+"x"+height, 10,10);
  text(ps.particles.size() + " particles", 10, 20);
  
  ps.run();
  ps.addParticle();
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
    particles.add(new Particle(origin, n++));
  }
  
    void addParticle(float x, float y) {
    particles.add(new Particle(new PVector(x,y), n++));
  }

  void addParticle(Particle p) {
    particles.add(p, n++);
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
    //acc = new PVector((noise(n*150, curTime)-0.45)*2+1, noise(n*100+50, curTime)*2+1);

    n = newN;
    myImg = particleImages[n % particleImages.length];
    r = 0.0;
    timer = 100.0;
    
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
    
    if(pressed) {
      attraction = PVector.sub(mousePos, loc)
      attraction = PVector.mult(attraction, 1/1000)
      vel.add(attraction)
    }
     
    if(timer > 90.0)
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
    
    
    imageMode(CENTER);
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
  
  void displayVector(PVector v, float x, float y, float scayl) {
    pushMatrix();
    float arrowsize = 4;
    // Translate to location to render vector
    translate(x,y);
    stroke(255);
    // Call vector heading function to get direction (note that pointing up is a heading of 0) and rotate
    rotate(v.heading2D());
    // Calculate length of vector & scale it to be bigger or smaller if necessary
    float len = v.mag()*scayl;
    // Draw three lines to make an arrow (draw pointing up since we've rotate to the proper direction)
    line(0,0,len,0);
    line(len,0,len-arrowsize,+arrowsize/2);
    line(len,0,len-arrowsize,-arrowsize/2);
    popMatrix();
  } 

}
