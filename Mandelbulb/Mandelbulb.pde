import peasy.*;

int gridSize = 128;
int n = 8;
int maxIterations = 10;

PeasyCam cam;
ArrayList<PVector> mandelbulb = new ArrayList<PVector>();

class Spherical {
    float r, theta, phi;
    Spherical(float r, float theta, float phi) {
        this.r = r;
        this.theta = theta;
        this.phi = phi;
    }
}

Spherical getSphericalCoords(float x, float y, float z) {
    float r     = sqrt(x*x + y*y + z*z);
    float theta = atan2(sqrt(x*x + y*y), z);
    float phi   = atan2(y, x);
    return new Spherical(r, theta, phi);
}

void calcMandelBulb() {
    for(int i=0; i<gridSize; i++) {
        for (int j=0; j<gridSize; j++) {
            boolean edge = false;
            for(int k=0; k<gridSize; k++) {

                float x = map(i, 0, gridSize, -1, 1);
                float y = map(j, 0, gridSize, -1, 1);
                float z = map(k, 0, gridSize, -1, 1);

                PVector zeta = new PVector(0, 0, 0);
                int iteration = 0;
                while(true) {
                    Spherical c = getSphericalCoords(zeta.x, zeta.y, zeta.z);

                    float newx = pow(c.r, n) * sin(c.theta*n) * cos(c.phi*n);
                    float newy = pow(c.r, n) * sin(c.theta*n) * sin(c.phi*n);
                    float newz = pow(c.r, n) * cos(c.theta*n);

                    zeta.x = newx + x;
                    zeta.y = newy + y;
                    zeta.z = newz + z;

                    iteration++;
                    if(c.r > 2) {
                        if(edge) {
                            edge = false;
                        }
                        break;
                    }
                    if(iteration > maxIterations) {
                        if(!edge) {
                            edge = true;
                            mandelbulb.add(new PVector(x*100, y*100, z*100));
                        }
                        break;
                    }
                }
            }
        }
    }
}

void setup() {
    fullScreen(P3D);
    cam = new PeasyCam(this, 500);
    calcMandelBulb();
    stroke(255);
}

void draw() {
    background(0);
    for(PVector pv: mandelbulb) {
        point(pv.x, pv.y, pv.z);
    }
}
