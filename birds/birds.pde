import java.util.Iterator; //<>// //<>// //<>//
import java.util.Map;
import java.util.HashMap;

double r = 5;
double COR = 0.2;
double dt = 0.1;
double v_max = 15;
double grnd_height = 30;
PImage img,
rock_img,
tree_img,
water_img,
arrow_img;
boolean shootArrow = false;
boolean arrowActivated = false;
float birdD = 24;
Vec2 arrowPos;
double arrowTheta;
double arrowSpeed = 200;
int winWidth = 640;
int winHeight = 360;
Map < Integer,
Integer > waterfallBoarderDict = new HashMap < Integer,
Integer > ();
boolean waterfallBoarderFlag = true;
public class Particle {
  Vec2 loc;
  Vec2 vel;
  Vec2 acc;
  float lifespan;

  Particle(Vec2 l) {
    loc = l;
    vel = new Vec2( - 5 + random(10), -5 + random(10));
    acc = new Vec2(0, 0);
    lifespan = 255;
  }

  void update() {

    acc = new Vec2(0, 0);

    //wall obstacle avoidance
    Vec2 wallObsForce = new Vec2(0, 0);
    double wall_th = 25;
    double sepMag = 5000;
    double wallRandMag = -4 + random(8);
    if (loc.x < wall_th) wallObsForce.add(new Vec2(sepMag * 8 / Math.pow(loc.x, 2), wallRandMag));
    if (width - loc.x < wall_th) wallObsForce.add(new Vec2( - sepMag / Math.pow(width - loc.x, 2), wallRandMag));
    if (loc.y < wall_th) wallObsForce.add(new Vec2(wallRandMag, sepMag / Math.pow(loc.y, 2)));
    if (height - grnd_height - loc.y < wall_th) wallObsForce.add(new Vec2(wallRandMag, -sepMag / Math.pow(height - grnd_height - loc.y, 2)));
    acc.add(wallObsForce);

    //waterfall obstacle avoidance
    for (Map.Entry < Integer, Integer > set: waterfallBoarderDict.entrySet()) {
      Vec2 waterfallObsForce = new Vec2(0, 0);
      float waterfall_threshold = 35;
      float waterfallSepMag = 200000;
      float waterfallRandMag = -4 + random(8);
      if (sqrt(pow((int) loc.x - set.getValue(), 2) + pow((int) loc.y - set.getKey(), 2)) < waterfall_threshold) {
        waterfallObsForce.add(new Vec2(waterfallSepMag / pow((int) loc.x, 2), waterfallRandMag));
      }
      acc.add(waterfallObsForce);
    }

    //cohesion force
    Vec2 cohForce = new Vec2(0, 0);
    Vec2 avgPos = new Vec2(0, 0);
    Vec2 cohRandVec = new Vec2( - 10 + random(20), -10 + random(20));
    double cnt = 0;
    Iterator < Particle > it = particles.iterator();
    while (it.hasNext()) {
      Particle p = it.next();
      double dist = loc.distanceTo(p.loc);
      if (dist > 0 && dist < 200) {
        avgPos.add(p.loc);
        cnt++;
      }
    }
    if (cnt >= 1) {
      avgPos.mul(1 / cnt);
      avgPos.subtract(loc);
      cohForce.add(avgPos);
      cohForce.add(cohRandVec);
      cohForce.normalize();
      cohForce.mul(4);
    }
    acc.add(cohForce);

    //separation force
    Vec2 sepForce = new Vec2(0, 0);
    it = particles.iterator();
    while (it.hasNext()) {
      Particle p = it.next();
      double dist = loc.distanceTo(p.loc);
      if (dist < 0.01 || dist > 80) continue;
      Vec2 tmp = loc.minus(p.loc).normalized();
      tmp.setToLength(6000 / Math.pow(dist, 2));
      sepForce.add(tmp);
    }
    acc.add(sepForce);

    //alignment force
    Vec2 avgVel = new Vec2(0, 0);
    Vec2 alignForce = new Vec2(0, 0);
    cnt = 0;
    it = particles.iterator();
    while (it.hasNext()) {
      Particle p = it.next();
      double dist = loc.distanceTo(p.loc);
      if (dist > 0 && dist < 40) {
        avgVel.add(p.vel);
        cnt += 1;
      }
    }
    if (cnt >= 1) {
      avgVel.mul(1 / cnt);
      avgVel.subtract(vel);
      avgVel.normalize();
      alignForce = avgVel.times(2);
    }
    acc.add(alignForce);

    //Random Force (Wind)
    Vec2 randForce = new Vec2(1 - random(2), 1 - random(2)).times(8);
    acc.add(randForce);

    //Danger (arrow) force
    if (shootArrow) {
      Vec2 dangerForce = new Vec2(0, 0);
      Vec2 distVec = new Vec2(loc.x - arrowPos.x, loc.y - arrowPos.y);
      Vec2 arrowVel = new Vec2(arrowSpeed * (double) Math.sin(arrowTheta), -arrowSpeed * (double) Math.cos(arrowTheta));
      double dist = distVec.length();
      double arrowVelMag = arrowVel.length();
      if (dist < 100) {
        dist = dist + 0.01;
        Vec2 dProj = arrowVel.times(dot(distVec, arrowVel) / (arrowVelMag * arrowVelMag));
        Vec2 normal = distVec.minus(dProj);
        dangerForce.add(normal.times(10000000 / dist));
      }
      acc.add(dangerForce);
    }
    loc.add(vel.times(dt));
    loc.x = clamp(loc.x, 7, winWidth - 7);
    loc.y = clamp(loc.y, 7, winHeight - 25);
    vel.add(acc.times(dt));
    vel.clampToLength(v_max);

  }

  void display() {
    imageMode(CENTER);
    tint(255, lifespan);
    image(img, (float) loc.x, (float) loc.y, birdD, birdD);
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
ArrayList < Particle > particles;
ArrayList < WaterParticle > water_particles;

void mousePressed() {
  boolean outOfBounds = false;

  if (waterfallBoarderFlag) {

    Iterator < WaterParticle > water_it = water_particles.iterator();
    while (water_it.hasNext()) {
      WaterParticle p = water_it.next();
      if (waterfallBoarderDict.containsKey((int) p.loc.y)) {
        if ((int) p.loc.x > waterfallBoarderDict.get((int) p.loc.y)) {
          waterfallBoarderDict.replace((int) p.loc.y, (int) p.loc.x);
        }
      }
      else {
        waterfallBoarderDict.put((int) p.loc.y, (int) p.loc.x);
      }
    }
    waterfallBoarderFlag = false;
  }

  for (Map.Entry < Integer, Integer > set: waterfallBoarderDict.entrySet()) {
    float waterfall_threshold = 5; //changed thresold
    if (sqrt(pow(mouseX - set.getValue(), 2) + pow(mouseY - set.getKey(), 2)) < waterfall_threshold || (mouseX < set.getValue() && mouseY > set.getKey())) {
      outOfBounds = true;
    }
  }
  outOfBounds = outOfBounds || mouseY >= 330 ? true: false;
  if (!outOfBounds) {
    for (int i = 0; i < 1; i++) {
      particles.add(new Particle(new Vec2(mouseX, mouseY)));
    }
  }
}

boolean outsideWindow(Vec2 v) {
  if (v.x < 0 || v.x > width || v.y < 0 || v.y > height) return true;
  return false;
}
void update_arrow() {

  if (outsideWindow(arrowPos)) shootArrow = false;
  Vec2 arrowVel = new Vec2(arrowSpeed * Math.sin(arrowTheta), -arrowSpeed * Math.cos(arrowTheta));
  arrowPos.add(arrowVel.times(dt));
}

void setup() {
  size(640, 360, P2D);
  particles = new ArrayList < Particle > ();
  water_particles = new ArrayList < WaterParticle > ();
  img = loadImage("owl.png");
  arrow_img = loadImage("arrow.png");
  rock_img = loadImage("rock.png");
  tree_img = loadImage("tree.png");
  water_img = loadImage("water.png");
  noStroke();
  blendMode(BLEND);
}

void draw() {
  println(frameRate);
  background(255);
  imageMode(CENTER);
  tint(255);

  image(rock_img, 40, 350, 100, 40);
  image(rock_img, 130, 350, 100, 40);
  image(rock_img, 210, 350, 80, 40);
  image(rock_img, 300, 350, 130, 40);
  image(rock_img, 400, 350, 100, 40);
  image(rock_img, 490, 350, 100, 40);
  image(rock_img, 600, 350, 100, 40);
  image(tree_img, 550, 210, 180, 360);

  for (int i = 0; i < 30; i++)
  water_particles.add(new WaterParticle(new Vec2(random(15), 40 + random(20))));
  Iterator < WaterParticle > water_it = water_particles.iterator();
  while (water_it.hasNext()) {
    WaterParticle p = water_it.next();
    p.run();
    if (p.isDead()) {
      water_it.remove();
    }
  }

  Iterator < Particle > it = particles.iterator();
  while (it.hasNext()) {
    Particle p = it.next();
    p.run();
    if (p.isDead()) {
      it.remove();
    }
  }

  if (arrowActivated || shootArrow) {
    pushMatrix();
    translate((float) arrowPos.x, (float) arrowPos.y);
    rotate((float) arrowTheta);
    image(arrow_img, 0, 0, 20, 40);
    popMatrix();
    if (shootArrow) update_arrow();
  }

  //Think
  // Arrow through waterfall ? 
  // Repel arrow when in rest ? 
}
