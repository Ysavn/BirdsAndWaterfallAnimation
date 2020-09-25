//Vector Library
//CSCI 5611 Vector 2 Library [Example]
// Stephen J. Guy <sjguy@umn.edu>

public class Vec2 {
  public double x, y;
  
  public Vec2(double x, double y){
    this.x = x;
    this.y = y;
  }
  
  public String toString(){
    return "(" + x+ "," + y +")";
  }
  
  public double length(){
    return Math.sqrt(x*x+y*y);
  }
  
  public Vec2 plus(Vec2 rhs){
    return new Vec2(x+rhs.x, y+rhs.y);
  }
  
  public void add(Vec2 rhs){
    x += rhs.x;
    y += rhs.y;
  }
  
  public Vec2 minus(Vec2 rhs){
    return new Vec2(x-rhs.x, y-rhs.y);
  }
  
  public void subtract(Vec2 rhs){
    x -= rhs.x;
    y -= rhs.y;
  }
  
  public Vec2 times(double rhs){
    return new Vec2(x*rhs, y*rhs);
  }
  
  public void mul(double rhs){
    x *= rhs;
    y *= rhs;
  }
  
  public void clampToLength(double maxL){
    double magnitude = Math.sqrt(x*x + y*y);
    if (magnitude > maxL){
      x *= maxL/magnitude;
      y *= maxL/magnitude;
    }
  }
  
  public void setToLength(double newL){
    double magnitude = Math.sqrt(x*x + y*y);
    x *= newL/magnitude;
    y *= newL/magnitude;
  }
  
  public void normalize(){
    double magnitude = Math.sqrt(x*x + y*y);
    x /= magnitude;
    y /= magnitude;
  }
  
  public Vec2 normalized(){
    double magnitude = Math.sqrt(x*x + y*y);
    return new Vec2(x/magnitude, y/magnitude);
  }
  
  public double distanceTo(Vec2 rhs){
    double dx = rhs.x - x;
    double dy = rhs.y - y;
    return Math.sqrt(dx*dx + dy*dy);
  }
}

Vec2 interpolate(Vec2 a, Vec2 b, double t){
  return a.plus((b.minus(a)).times(t));
}

double interpolate(double a, double b, double t){
  return a + ((b-a)*t);
}

double dot(Vec2 a, Vec2 b){
  return a.x*b.x + a.y*b.y;
}

Vec2 projAB(Vec2 a, Vec2 b){
  return b.times(a.x*b.x + a.y*b.y);
}

double clamp(double f, double min, double max){
  if (f < min) return min;
  if (f > max) return max;
  return f;
}
