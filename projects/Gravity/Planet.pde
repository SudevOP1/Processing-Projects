class Planet {
    PVector pos, vel;
    float r;
    color col;
    static final float G = 2;
    static final float softening = 20; // to prevent infinite acceleration

    Planet(float x, float y, float vx, float vy, float r, color col) {
        this.pos = new PVector(x, y);
        this.vel = new PVector(0, 0);
        this.r = r;
        this.col = col;
    }

    void draw() {
        fill(this.col);
        circle(this.pos.x, this.pos.y, 2 * this.r);
    }

    void update() {
        this.pos.add(this.vel);
    }

    void attract(Planet other) {
        PVector direction = PVector.sub(this.pos, other.pos);
        float distance = direction.mag();
        if(distance == 0) return; // prevent infinite acceleration
        direction.normalize();
        float force = (G * this.r) / (distance * distance + softening);
        PVector acceleration = direction.mult(force);
        other.vel.add(acceleration);
    }
}