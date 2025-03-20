class Particle {
    PVector pos, vel;
    int r;
    color col;

    Particle(float x, float y, float vx, float vy, float r, color col) {
        this.pos = new PVector(x, y);
        this.vel = new PVector(vx, vy);
        this.r = (int) r;
        this.col = col;
    }

    void update() {
        this.pos.add(this.vel);
    }

    void show() {
        fill(this.col);
        circle(this.pos.x, this.pos.y, 2*this.r);
    }

    void bounceEdges() {
        if(this.pos.x < this.r) {
            this.vel.x *= -1;
            this.pos.x = this.r;
        }
        if(this.pos.x > width - this.r) {
            this.vel.x *= -1;
            this.pos.x = width - this.r;
        }
        if(this.pos.y < this.r) {
            this.vel.y *= -1;
            this.pos.y = this.r;
        }
        if(this.pos.y > height - this.r) {
            this.vel.y *= -1;
            this.pos.y = height - this.r;
        }
    }

    void checkCollisionWith(Particle other) {
        float distance = dist(this.pos.x, this.pos.y, other.pos.x, other.pos.y);
        if (distance >= this.r + other.r) return; // No collision

        PVector posDiff = PVector.sub(other.pos, this.pos);
        PVector vDiff = PVector.sub(other.vel, this.vel);
        float dotProduct = vDiff.dot(posDiff);

        if (dotProduct > 0) return;

        float thisMass = this.r * this.r;
        float otherMass = other.r * other.r;
        float massSum = thisMass + otherMass;

        float scale1 = (2 * otherMass * dotProduct) / (massSum * distance * distance);
        float scale2 = (2 * thisMass * dotProduct) / (massSum * distance * distance);

        PVector deltaV1 = posDiff.copy().mult(scale1);
        PVector deltaV2 = posDiff.copy().mult(-scale2);

        this.vel.add(deltaV1);
        other.vel.add(deltaV2);

        float overlap = (this.r + other.r - distance) / 2;
        PVector separation = posDiff.copy().normalize().mult(overlap);
        this.pos.sub(separation);
        other.pos.add(separation);
    }

}