import peasy.*;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.IOException;

class CartesianPoint {
    float x, y, z;
    
    CartesianPoint(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
    
    void set(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
    
    void set(CartesianPoint other) {
        this.x = other.x;
        this.y = other.y;
        this.z = other.z;
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
        float theta = atan2(this.y, this.x);
        float phi   = (r == 0) ? 0 : acos(this.z / r);
        return new PolarPoint(r, theta, phi);
    }
    
    void add(CartesianPoint other) {
        this.x += other.x;
        this.y += other.y;
        this.z += other.z;
    }
}

class PolarPoint {
    float r, theta, phi;
    
    PolarPoint(float r, float theta, float phi) {
        this.r = r;
        this.theta = theta;
        this.phi = phi;
    }
    
    void set(float r, float theta, float phi) {
        this.r = r;
        this.theta = theta;
        this.phi = phi;
    }
    
    void set(PolarPoint other) {
        this.r = other.r;
        this.theta = other.theta;
        this.phi = other.phi;
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
    
    void add(PolarPoint other) {
        CartesianPoint resultCartesianPoint = this.toCartesian();
        resultCartesianPoint.add(other.toCartesian());
        PolarPoint resultPolarPoint = resultCartesianPoint.toPolar();
        this.r = resultPolarPoint.r;
        this.theta = resultPolarPoint.theta;
        this.phi = resultPolarPoint.phi;
    }
    
    void add(CartesianPoint other) {
        CartesianPoint resultCartesianPoint = this.toCartesian();
        resultCartesianPoint.add(other);
        PolarPoint resultPolarPoint = resultCartesianPoint.toPolar();
        this.r = resultPolarPoint.r;
        this.theta = resultPolarPoint.theta;
        this.phi = resultPolarPoint.phi;
    }
}

class Electron {
    PolarPoint pos;
    CartesianPoint vel;
    
    Electron(float r, float theta, float phi) {
        this.pos = new PolarPoint(r, theta, phi);
        this.vel = new CartesianPoint(0, 0, 0);
    }
    
    Electron(float r, float theta, float phi, float vx, float vy, float vz) {
        this.pos = new PolarPoint(r, theta, phi);
        this.vel = new CartesianPoint(vx, vy, vz);
    }
    
    void update() {
        this.pos.add(this.vel);
    }
    
    void draw() {
        float[] cartesianCoords = this.pos.toCartesianCoords();
        point(cartesianCoords[0], cartesianCoords[1], cartesianCoords[2]);
    }
}

PeasyCam cam;
Electron[] electrons;
int numElectrons = 40000;

int n = 6;
int l = 1;
int m = 1;
float a0 = 20.0; // bohr radius in pixels
float speedScale = 20.0;
float hBar = 50.0;
float electronMass = 1.0;

color bgColor          = #000000;
color electronColor    = #00ffff;
color axisColor        = #ffffff;
color textColor        = #00ff00;

int electronSize = 2;
float maxR = n * n * a0 * 3; // max radius to consider

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
float sampleR(int n, int l, int m, float maxR) {
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

CartesianPoint calcProbabilityFlow(Electron electron, int n, int l, int m) {
    float r = electron.pos.r;
    float theta = electron.pos.theta;
    float phi = electron.pos.phi;
    if (r < 0.000001) {
        return new CartesianPoint(0, 0, 0);
    }
    
    // compute mag
    float sinPhi = sin(phi);
    sinPhi = max(abs(sinPhi), 0.001);
    float velMag = speedScale * hBar * m / (electronMass * r * sinPhi);
    
    // convert to cartesian
    float vx = -velMag * sin(theta);
    float vy = velMag * cos(theta);
    float vz = 0;
    
    return new CartesianPoint(vx, vy, vz);
}

Electron[] generateElectrons(int numPoints, int n, int l, int m, float maxR) {
    Electron[] electrons = new Electron[numPoints];
    
    for (int i = 0; i < numPoints; i++) {
        float r     = sampleR(n, l, m, maxR);
        float theta = sampleTheta(n, l, m);
        float phi   = samplePhi(n, l, m);
        electrons[i] = new Electron(r, theta, phi);
    }
    
    return electrons;
}

// draw electrons filtered by octants
void drawElectrons(Electron[] electrons, int[] octants) {
    
    // if octants array is empty, draw all points
    if (octants.length == 0) {
        for (Electron electron : electrons) {
            if (electron != null) {
                electron.draw();
            }
        }
    } else {
        // draw points in only specified octants
        for (Electron electron : electrons) {
            if (electron != null && electron.pos.isInOctants(octants)) {
                electron.draw();
            }
        }
    }
}

void setup() {
    fullScreen(P3D);
    cam = new PeasyCam(this, 500);
    electrons = generateElectrons(numElectrons, n, l, m, maxR);
    
    textSize(32);
    textAlign(RIGHT, TOP);
    strokeWeight(electronSize);
}

void draw() {
    background(bgColor);
    
    // draw axes
    stroke(axisColor);
    line(maxR, 0, 0, -maxR, 0, 0);
    line(0, maxR, 0, 0, -maxR, 0);
    line(0, 0, maxR, 0, 0, -maxR);
    
    // updating electrons
    for (Electron electron : electrons) {
        electron.vel.set(calcProbabilityFlow(electron, n, l, m));
        electron.update();
    }

    // drawing filtered electrons
    stroke(electronColor);
    drawElectrons(electrons, visibleOctants);
    
    // drawing textual info
    cam.beginHUD();
    fill(textColor);
    text("FPS: " + int(frameRate), width - 20, 20);
    text("n=" + n + ", l=" + l + ", m=" + m, width - 20, 60);
    text("numElectrons=" + numElectrons, width - 20, 100);
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
