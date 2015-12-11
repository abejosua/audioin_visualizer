import processing.sound.*;

AudioIn input;
Amplitude analyzer;

ParticleSystem ps;

float randomModifier;
float accelerationZ;
float INITIAL_Z_POSITION = 695;
float size;

float volume;

void setup() {
  fullScreen(P3D, 1);
  ps = new ParticleSystem(new PVector(width/2, height/2, INITIAL_Z_POSITION));
  randomModifier = 0.03;
  accelerationZ = 0.005;
  size = 8;
  
  // Start listening to the microphone
  // Create an Audio input and grab the 1st channel
  input = new AudioIn(this, 0);

  // start the Audio Input
  input.start();

  // create a new Amplitude analyzer
  analyzer = new Amplitude(this);

  // Patch the input to an volume analyzer
  analyzer.input(input);
}  

void draw() {
  volume = analyzer.analyze();
  accelerationZ = 0.005 + volume;
  ps.origin.z = INITIAL_Z_POSITION - (volume*1000);
  randomModifier = 0.01 + (volume*5);
  size = 8 + volume*100;
  
  background(255);
  ps.addParticle();
  ps.run();
} 

class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;

  ParticleSystem(PVector location) {
    origin = location;
    particles = new ArrayList<Particle>();
  }

  void addParticle() {
    particles.add(new Particle(origin));
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}

class Particle {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float lifespan;

  Particle(PVector l) {
    acceleration = new PVector(0, 0, accelerationZ);
    velocity = new PVector(random(-(randomModifier), randomModifier), 
                random(-randomModifier,randomModifier), 0);
    location = l.get();
    lifespan = 0.0;
  }

  void run() {
    update();
    display();
  }

  // Method to update location
  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    lifespan += 0.5;
  }

  // Method to display
  void display() {
    stroke(0,lifespan);
    fill(0,lifespan);
    pushMatrix();
    translate(location.x, location.y, location.z);
    sphereDetail(5);
    sphere(size);
    popMatrix();
  }
  
  // Is the particle still useful?
  boolean isDead() {
    if (lifespan > 255.0) {
      return true;
    } else {
      return false;
    }
  }
}