int minV = 5;
int maxV = 10;
int minR = 5;
int maxR = 10;
int numOfPlanets = 500;
Planet[] planets = new Planet[numOfPlanets];

void drawPlanets() {
    for(int i=0; i<numOfPlanets; i++) {
        planets[i].draw();
    }
}

void createPlanets() {
    for(int i=0; i<numOfPlanets; i++) {
        planets[i] = new Planet(
            random(width), random(height),
            random(minV, maxV), random(minV, maxV),
            random(minR, maxR),
            color(random(255), random(255), random(255))
        );
    }
}

void updatePlanets() {
    for(int i=0; i<numOfPlanets; i++) {
        for(int j=0; j<numOfPlanets; j++) {
            if(i != j) {
                planets[i].attract(planets[j]);
            }
        }
    }
    for(int i=0; i<numOfPlanets; i++) {
        planets[i].update();
    }
}

void setup() {
    // size(800, 800);
    fullScreen();
    createPlanets();
    noStroke();
}

void draw() {
    background(0);
    updatePlanets();
    drawPlanets();
    // System.out.println(frameRate);
}