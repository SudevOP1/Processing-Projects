PGraphics mbSet;
int maxIterations = 100;
float zoom = 1.3;
float xOffset = -200;
float aspectRatio;
PFont font;

void setup() {
    fullScreen(P2D);
    aspectRatio = float(width) / float(height);
    textAlign(RIGHT, TOP);
    fill(0, 255, 0);
    noStroke();
    font = createFont("Consolas", 32);
    textFont(font);

    mbSet = createGraphics(width, height, P2D);
}

void draw() {
    float c_a = map(mouseX, 0, width , -2, 2);
    float c_b = map(mouseY, 0, height, 2, -2);
    createJuliaSet(c_a, c_b);
    image(mbSet, 0, 0);
    showC(c_a, c_b);
}

void createJuliaSet(float c_a, float c_b) {
    mbSet.beginDraw();
    mbSet.loadPixels();
    
    for(int x = 0; x < width; x++) {
        for(int y = 0; y < height; y++) {
            float a = map(x, 0, width, -zoom*aspectRatio, zoom*aspectRatio);
            float b = map(y, 0, height, -zoom, zoom);

            int n;
            for(n = 0; n < maxIterations; n++) {
                float re = a*a - b*b;
                float im = 2*a*b;
                a = re + c_a;
                b = im + c_b;
                if (a*a + b*b > 4) break;
            }

            float bright = map(n, 0, maxIterations, 0, 255);
            if(n == maxIterations) bright = 0;

            mbSet.pixels[x + y*width] = color(bright);
        }
    }

    mbSet.updatePixels();
    mbSet.endDraw();
}

void showC(float c_a, float c_b) {
    char c_aSign = c_a < 0 ? '-' : ' ';
    char c_bSign = c_b < 0 ? '-' : '+';
    String cText = String.format("c = %c %.8f %c %.8fi", c_aSign, abs(c_a), c_bSign, abs(c_b));
    text(cText, width, 0);
}
