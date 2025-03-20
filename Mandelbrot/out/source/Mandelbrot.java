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

public class Mandelbrot extends PApplet {

PGraphics mbSet;
int maxIterations = 100;
float zoom = 1.3f;
float xOffset = -200;
float aspectRatio;
float scaleFactor = 1.0f; // Dynamic zoom factor

public void setup() {
    /* size commented out by preprocessor */;
    mbSet = createGraphics(width, height, P2D);
    
    aspectRatio = PApplet.parseFloat(width) / PApplet.parseFloat(height);
    createMandelbrot();
}

public void draw() {
    background(0);
    
    // Adjust scale based on mouse movement
    scaleFactor = map(mouseX, 0, width, 0.5f, 2.5f); // MouseX controls zoom
    translate(width / 2, height / 2); // Center the zoom effect
    scale(scaleFactor); // Apply scaling
    translate(-width / 2, -height / 2); // Revert translation
    
    image(mbSet, 0, 0);
}

public void createMandelbrot() {
    mbSet.beginDraw();
    mbSet.loadPixels();
    
    for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
            float a = map(x + xOffset, 0, width, -zoom * aspectRatio, zoom * aspectRatio);
            float b = map(y, 0, height, -zoom, zoom);

            float ca = a;
            float cb = b;

            int n;
            for (n = 0; n < maxIterations; n++) {
                float re = a * a - b * b;
                float im = 2 * a * b;
                a = re + ca;
                b = im + cb;
                if (a * a + b * b > 16) break;
            }

            float bright = map(n, 0, maxIterations, 0, 255);
            if (n == maxIterations) bright = 0;

            mbSet.pixels[x + y * width] = color(bright);
        }
    }

    mbSet.updatePixels();
    mbSet.endDraw();
}


  public void settings() { fullScreen(P2D); }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Mandelbrot" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
