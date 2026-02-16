int numOfParticles = 1000;
int minR = 10;
int maxR = 20;
int minV = 2;
int maxV = 5;
boolean paused;
Particle[] particles = new Particle[numOfParticles];

color getBrightColor() {
    colorMode(HSB, 360, 100, 100);
    color c = color(random(360), 100, 100);
    colorMode(RGB, 255, 255, 255);
    return c;
}

void createParticles() {
    for(int i=0; i<numOfParticles; i++) {

        float v = random(minV, maxV);
        float a = random(2 * PI);

        particles[i] = new Particle(
            random(width), random(height),
            v*cos(a), v*sin(a),
            random(minR, maxR),
            getBrightColor()
        );
    }
}

void updateParticles() {
    for(int i=0; i<numOfParticles; i++) {
        particles[i].update();
        particles[i].bounceEdges();
    }
    for(int i=0; i<numOfParticles; i++) {
        for(int j=i+1; j<numOfParticles; j++) {
            particles[i].checkCollisionWith(particles[j]);
        }
    }
}

void showParticles() {
    for(int i=0; i<numOfParticles; i++) {
        particles[i].show();
    }
}

void setup() {
    // size(800, 800);
    fullScreen();
    createParticles();
}

void draw() {
    if(!paused) {        
        background(0);
        updateParticles();
        showParticles();
    }
}

void mousePressed() {
    if(
        mouseButton == LEFT &&
        mouseX >= 0 && mouseX <= width &&
        mouseY >= 0 && mouseY <= height
    ) {
        paused = !paused;
    }
}