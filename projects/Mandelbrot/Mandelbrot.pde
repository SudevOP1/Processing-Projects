PGraphics mbSet;
int maxIterations = 100;
float zoom = 1.3;
float xOffset = -200;
float aspectRatio;

void setup() {
    fullScreen(P2D);
    mbSet = createGraphics(width, height, P2D);
    aspectRatio = float(width) / float(height);
    createMandelbrot();
}

void draw() {
    background(0);
    image(mbSet, 0, 0);
}

void createMandelbrot() {
    mbSet.beginDraw();
    mbSet.loadPixels();
    
    for(int x = 0; x < width; x++) {
        for(int y = 0; y < height; y++) {
            float a = map(x + xOffset, 0, width, -zoom*aspectRatio, zoom*aspectRatio);
            float b = map(y, 0, height, -zoom, zoom);

            float ca = a;
            float cb = b;

            int n;
            for(n = 0; n < maxIterations; n++) {
                float re = a*a - b*b;
                float im = 2*a*b;
                a = re + ca;
                b = im + cb;
                if(a*a + b*b > 16) break;
            }

            float bright = map(n, 0, maxIterations, 0, 255);
            if(n == maxIterations) bright = 0;

            mbSet.pixels[x + y*width] = color(bright);
        }
    }

    mbSet.updatePixels();
    mbSet.endDraw();
}
