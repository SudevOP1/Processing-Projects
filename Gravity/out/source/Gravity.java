/* autogenerated by Processing revision 1297 on 2025-03-20 */
import processing.core.*;
import processing.data.*;
import processing.event.*;
import processing.opengl.*;

import java.util.HashMap;
import java.util.ArrayList;
import java.io.File;
import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;

public class Gravity extends PApplet {

int minV = 5;
int maxV = 10;
int minR = 5;
int maxR = 10;
int numOfPlanets = 500;
Planet[] planets = new Planet[numOfPlanets];

public void drawPlanets() {
    for(int i=0; i<numOfPlanets; i++) {
        planets[i].draw();
    }
}

public void createPlanets() {
    for(int i=0; i<numOfPlanets; i++) {
        planets[i] = new Planet(
            random(width), random(height),
            random(minV, maxV), random(minV, maxV),
            random(minR, maxR),
            color(random(255), random(255), random(255))
        );
    }
}

public void updatePlanets() {
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

public void setup() {
    // size(800, 800);
    /* size commented out by preprocessor */;
    createPlanets();
    noStroke();
}

public void draw() {
    background(0);
    updatePlanets();
    drawPlanets();
    System.out.println(frameRate);
}
class Planet {
    PVector pos, vel;
    float r;
    int col;
    static final float G = 2;
    static final float softening = 20; // to prevent infinite acceleration

    Planet(float x, float y, float vx, float vy, float r, int col) {
        this.pos = new PVector(x, y);
        this.vel = new PVector(0, 0);
        this.r = r;
        this.col = col;
    }

    public void draw() {
        fill(this.col);
        circle(this.pos.x, this.pos.y, 2 * this.r);
    }

    public void update() {
        this.pos.add(this.vel);
    }

    public void attract(Planet other) {
        PVector direction = PVector.sub(this.pos, other.pos);
        float distance = direction.mag();
        if(distance == 0) return; // prevent infinite acceleration
        direction.normalize();
        float force = (G * this.r) / (distance * distance + softening);
        PVector acceleration = direction.mult(force);
        other.vel.add(acceleration);
    }
}


  public void settings() { fullScreen(); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Gravity" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
