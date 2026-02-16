import peasy.*;

class CartesianPoint {
    float x, y, z;
    
    CartesianPoint(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
    
    // get the octant number (1-8) for this point
    int getOctant() {
        // octant numbering:
        // 1: +x, +y, +z
        // 2: -x, +y, +z
        // 3: -x, -y, +z
        // 4: +x, -y, +z
        // 5: +x, +y, -z
        // 6: -x, +y, -z
        // 7: -x, -y, -z
        // 8: +x, -y, -z
        
        int octant = 1;
        if (x < 0) octant += 1;
        if (y < 0) octant += 2;
        if (z < 0) octant += 4;
        return octant;
    }
    
    PolarPoint toPolar() {
        float r     = sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
        float theta = atan(this.y / this.x);
        float phi   = atan(sqrt(this.x * this.x + this.y * this.y) / z);
        return new PolarPoint(r, theta, phi);
    }
}

class PolarPoint {
    float r, theta, phi;
    
    PolarPoint(float r, float theta, float phi) {
        this.r = r;
        this.theta = theta;
        this.phi = phi;
    }
    
    CartesianPoint toCartesian() {
        float[] cartesianCoords = this.toCartesianCoords();
        return new CartesianPoint(cartesianCoords[0], cartesianCoords[1], cartesianCoords[2]);
    }
    
    float[] toCartesianCoords() {
        float x = this.r * sin(this.phi) * cos(this.theta);
        float y = this.r * sin(this.phi) * sin(this.theta);
        float z = this.r * cos(this.phi);
        return new float[] {x, y, z};
    }
    
    // get the octant number for this polar point
    int getOctant() {
        return toCartesian().getOctant();
    }
    
    // check if this point is in any of the specified octants
    boolean isInOctants(int[] octants) {
        int pointOctant = getOctant();
        for (int oct : octants) {
            if (pointOctant == oct) {
                return true;
            }
        }
        return false;
    }
    
    void draw() {
        float[] cartesianCoords = this.toCartesianCoords();
        point(cartesianCoords[0], cartesianCoords[1], cartesianCoords[2]);
    }
}

PeasyCam cam;
PolarPoint[] polarPoints;
int numPoints = 60000;

int n = 5;
int l = 1;
int m = 0;
float a0 = 20.0; // bohr radius in pixels

int[] visibleOctants = {1, 2, 3, 4, 5, 6, 7, 8};

// calculate Laguerre polynomial
float laguerreL(int n, int alpha, float x) {
    if (n == 0) {
        return 1.0;
    } else if (n == 1) {
        return 1.0 + alpha - x;
    }
    
    float Lm2 = 1.0;
    float Lm1 = 1.0 + alpha - x;
    float L = 0;
    
    for (int k = 2; k <= n; k++) {
        L = ((2 * k - 1 + alpha - x) * Lm1 - (k - 1 + alpha) * Lm2) / k;
        Lm2 = Lm1;
        Lm1 = L;
    }
    return Lm1;
}

// calculate Legendre polynomial
float legendreP(int l, int m, float x) {
    if (m < 0 || m > l) {
        return 0;
    }
    
    float pmm = 1.0;
    if (m > 0) {
        float somx2 = sqrt((1.0 - x) * (1.0 + x));
        float fact = 1.0;
        for (int i = 1; i <= m; i++) {
            pmm *= -fact * somx2;
            fact += 2.0;
        }
    }
    
    if (l == m) {
        return pmm;
    }
    
    float pmmp1 = x * (2 * m + 1) * pmm;
    if (l == m + 1) {
        return pmmp1;
    }
    
    float pll = 0;
    for (int ll = m + 2; ll <= l; ll++) {
        pll = (x * (2 * ll - 1) * pmmp1 - (ll + m - 1) * pmm) / (ll - m);
        pmm = pmmp1;
        pmmp1 = pll;
    }
    return pll;
}

// radial probability density for hydrogen atom
float radialProbability(float r, int n, int l) {
    float rho = 2.0 * r / (n * a0);
    int k = n - l - 1;
    int alpha = 2 * l + 1;
    
    float L = laguerreL(k, alpha, rho);
    
    float normalization = sqrt(
        pow(2.0 / (n * a0), 3) * 
        exp(lnGamma(n - l)) / 
       (2.0 * n * exp(lnGamma(n + l + 1)))
       );
    
    float radialPart = normalization * exp( -rho / 2.0) * pow(rho, l) * L;
    
    return r * r * radialPart * radialPart; // r^2 * R^2 for probability density
}

// sample r using rejection sampling
float sampleR(int n, int l, int m) {
    float maxR = n * n * a0 * 3; // maximum radius to consider
    float maxProb = 0;
    
    // find maximum probability for rejection sampling
    for (float r = 0.1; r < maxR; r += maxR / 1000.0) {
        float prob = radialProbability(r, n, l);
        if (prob > maxProb) {
            maxProb = prob;
        }
    }
    
    // rejection sampling
    while(true) {
        float r = random(maxR);
        float prob = radialProbability(r, n, l);
        if (random(maxProb) < prob) {
            return r;
        }
    }
}

// sample theta (azimuthal angle) - uniform on [0, 2PI]
float sampleTheta(int n, int l, int m) {
    return random(TWO_PI);
}

// sample phi (polar angle) using angular probability
float samplePhi(int n, int l, int m) {
    int absM = abs(m);
    float maxProb = 0;
    
    // find maximum probability
    for (float phi = 0; phi < PI; phi += PI / 1000.0) {
        float cosTheta = cos(phi);
        float prob = sq(legendreP(l, absM, cosTheta)) * sin(phi);
        if (prob > maxProb) {
            maxProb = prob;
        }
    }
    
    // rejection sampling
    while(true) {
        float phi = random(PI);
        float cosTheta = cos(phi);
        float prob = sq(legendreP(l, absM, cosTheta)) * sin(phi);
        if (random(maxProb) < prob) {
            return phi;
        }
    }
}

// logarithm of gamma function (approximation)
float lnGamma(float x) {
    if (x <= 0) {
        return 0;
    }
    float z = x;
    float g = 1;
    while(z < 8) {
        g *= z;
        z++;
    }
    float r = 1.0 / z;
    return log(sqrt(TWO_PI / z) * pow(z / exp(1), z) / g);
}

PolarPoint[] generatePolarPoints(int numPoints, int n, int l, int m) {
    PolarPoint[] polarPoints = new PolarPoint[numPoints];
    
    for (int i = 0; i < numPoints; i++) {
        float r     = sampleR(n, l, m);
        float theta = sampleTheta(n, l, m);
        float phi   = samplePhi(n, l, m);
        polarPoints[i] = new PolarPoint(r, theta, phi);
    }
    
    return polarPoints;
}

// draw points filtered by octants
void drawPolarPoints(PolarPoint[] polarPoints, int[] octants) {
    int drawnPoints = 0;
    
    // if octants array is empty, draw all points
    if (octants.length == 0) {
        for (PolarPoint pp : polarPoints) {
            if (pp != null) {
                pp.draw();
                drawnPoints++;
            }
        }
    } else {
        // draw only points in specified octants
        for (PolarPoint pp : polarPoints) {
            if (pp != null && pp.isInOctants(octants)) {
                pp.draw();
                drawnPoints++;
            }
        }
    }
    lastDrawnPoints = drawnPoints;
}

int lastDrawnPoints = 0;

void setup() {
    fullScreen(P3D);
    cam = new PeasyCam(this, 500);
    polarPoints = generatePolarPoints(numPoints, n, l, m);
    
    textSize(32);
    textAlign(RIGHT, TOP);
    strokeWeight(1);
}

void draw() {
    background(0);
    
    // drawing filtered polarPoints
    stroke(255);
    drawPolarPoints(polarPoints, visibleOctants);
    
    // drawing textual info
    cam.beginHUD();
    fill(0, 255, 0);
    text("FPS: " + int(frameRate), width - 20, 20);
    text("n=" + n + ", l=" + l + ", m=" + m, width - 20, 60);
    text("numPoints=" + numPoints, width - 20, 100);
    cam.endHUD();
}

// keyboard controls for octants toggling
void keyPressed() {
    if (key >= '1' && key <= '8') {
        int octant = key - '0';
        toggleOctant(octant);
    } else if (key == '0') {
        visibleOctants = new int[0];
    }
}

// toggle a specific octant
void toggleOctant(int octant) {
    boolean found = false;
    int foundIndex = -1;
    
    for (int i = 0; i < visibleOctants.length; i++) {
        if (visibleOctants[i] == octant) {
            found = true;
            foundIndex = i;
            break;
        }
    }
    
    if (found) {
        // remove octant
        int[] newOctants = new int[visibleOctants.length - 1];
        int idx = 0;
        for (int i = 0; i < visibleOctants.length; i++) {
            if (i != foundIndex) {
                newOctants[idx++] = visibleOctants[i];
            }
        }
        visibleOctants = newOctants;
    } else {
        // add octant
        int[] newOctants = new int[visibleOctants.length + 1];
        for (int i = 0; i < visibleOctants.length; i++) {
            newOctants[i] = visibleOctants[i];
        }
        newOctants[visibleOctants.length] = octant;
        visibleOctants = newOctants;
    }
}
