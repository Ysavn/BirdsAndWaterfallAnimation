public class WaterParticle {
  Vec2 loc;
  Vec2 vel;
  Vec2 acc;
  float lifespan;
  boolean bounced;

  WaterParticle(Vec2 l) {
    loc = l;
    vel = new Vec2(1.5 + random(2), -2 + random(2));
    acc = new Vec2(0, 0.3);
    lifespan = 255;
  }

  void update() {
    loc.add(vel);
    vel.add(acc);
    if (bounced) {
      lifespan -= 6;
    }

    else {
      lifespan -= 5;
    }

    if (loc.y > height - r - 5) {
      bounced = true;

      lifespan = 120;

      loc.y = height - r - 25 - random(5);
      vel.y *= -0.15 - random(0.3);
      if (random(2) < 1) {
        vel.x *= 1 + random(1);
      }
      else {
        vel.x *= -(1.75 + random(1));
      }

    }

  }

  void display() {

    imageMode(CENTER); {
      tint(255, lifespan);
      image(water_img, (float) loc.x, (float) loc.y, 20, 20);
    }
  }

  void run() {
    update();
    display();
  }

  boolean isDead() {
    if (lifespan < 0) {
      return true;
    }
    return false;
  }
}

void keyPressed() {

  if (key == 's' && shootArrow == false) {
    arrowActivated = true;
    arrowPos = new Vec2(610, 310);
    Iterator < Particle > it = particles.iterator();
    Vec2 avgPos = new Vec2(0, 0);
    float cnt = 0;
    while (it.hasNext()) {
      Particle p = it.next();
      avgPos.add(p.loc);
      cnt += 1;
    }
    if (cnt > 0) avgPos.mul(1 / cnt);
    arrowTheta = (float) - Math.acos(avgPos.minus(arrowPos).normalized().x) + PI / 2;
  }
}

void keyReleased() {

  if (key == 's') {
    arrowActivated = false;
    shootArrow = true;
  }
}
