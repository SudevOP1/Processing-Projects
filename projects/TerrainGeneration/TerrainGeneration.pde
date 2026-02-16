import peasy.*;

PeasyCam cam;
float[][] terrain;
int cols, rows;
int scl = 10;
float flying = 0;
boolean paused = false;

void setup() {
    fullScreen(P3D);
    textSize(32);
    textAlign(RIGHT, TOP);
    
    cols = width  / scl;
    rows = height / scl;
    cam = new PeasyCam(this, 1500);
    terrain = new float[cols+1][rows+1];
}

void draw() {
    if(!paused) {
        background(0);
        translate(-cols*scl*0.5, -rows*scl*0.5, 0);
        rotateX(PI/4);

        setupTerrain();
        showTerrain();
        showFrameRate();
    }
}

void keyPressed() {
    if(key == ' ') {
        paused = !paused;
    }
}

void setupTerrain() {
    flying -= 0.1;
    float yOff = flying;
    
    for(int y = 0; y < rows + 1; y++) {
        float xOff = 0;
        for(int x = 0; x < cols + 1; x++) {
            terrain[x][y] = map(noise(xOff, yOff), 0, 1, -50, 50);
            xOff += 0.2;
        }
        yOff += 0.2;
    }
}

void showTerrain() {
    stroke(255, 100);
    noFill();

    for(int y = 0; y < rows; y++) {
        beginShape(TRIANGLE_STRIP);
        for(int x = 0; x < cols; x++) {
            vertex(x * scl, y * scl, terrain[x][y]);
            vertex(x * scl, (y+1) * scl, terrain[x][y+1]);
        }
        endShape();
    }
}

void showFrameRate() {
    pushMatrix();
    pushStyle();
    cam.beginHUD();

    fill(0, 255, 0);
    text("FPS: " + int(frameRate), width - 20, 20);

    cam.endHUD();
    popStyle();
    popMatrix();
}
