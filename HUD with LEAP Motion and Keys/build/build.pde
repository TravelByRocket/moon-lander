// Author            : Bryan Costanza (GitHub: TravelByRocket)
// Date created      : 
// Purpose           : Every aerospace engineer that makes a game has to have a moon lander
//**********************************************************************

import de.voidplus.leapmotion.*;

LeapMotion leap;

// Y is inverted from physical so gravity is positive
// Angle is measured as pitch (0 to the right and positive CCW)

color space = #39393A;
float deadbandhalf = 8; // degrees to ignore around 0 when using Leap Motion controller 

Moon moon;
Spacecraft spacecraft;

void settings(){
  size(800, 800);
}

void setup() {
  leap = new LeapMotion(this);

  noStroke();

  float xloc = random(50,700); //craft point of action X
  float yloc = random(50,300); //craft point of action Y
  float xvel = random(0,1) - 0.5;
  float yvel = random(0,1) - 0.5;

  moon = new Moon();
  spacecraft = new Spacecraft(xloc,yloc,xvel,yvel);
}

void draw() {
  background(space);
  updateLeapMotionInputs();
  moon.draw();
  spacecraft.update();
  spacecraft.draw();
  spacecraft.drawHUD();
}

void keyPressed() {
  if (keyCode == UP){
    spacecraft.mainEngine(true);
  } 
  if (keyCode == LEFT){
    spacecraft.thrustLeft(true);
  }
  if (keyCode == RIGHT){
    spacecraft.thrustRight(true);
  }
  if (key == ' '){
    spacecraft = new Spacecraft();
  }
}

void keyReleased() {
  if (keyCode == UP){
    spacecraft.mainEngine(false);
  }
  if (keyCode == LEFT){
    spacecraft.thrustLeft(false);
  }
  if (keyCode == RIGHT){
    spacecraft.thrustRight(false);
  }
}

float handRoll;
void updateLeapMotionInputs() {
  for (Hand hand : leap.getHands ()) {
    if (hand.isRight()) {

      handRoll = hand.getRoll();
      if (handRoll < -deadbandhalf) {
        spacecraft.thrustLeft(true);
      } else {
        spacecraft.thrustLeft(false);
      }

      if (handRoll > deadbandhalf) {
        spacecraft.thrustRight(true);
      } else {
        spacecraft.thrustRight(false);
      }

      float handGrab = hand.getGrabStrength();
      if (handGrab > 0.8){
        spacecraft.mainEngine(true);
      } else {
        spacecraft.mainEngine(false);
      }
    }
  }
}

class Moon{
  float ysurf[] = new float[width];
  PShape moonSurface;
  color highlight = #E6E6E6;

  Moon(){
    moonCreate();
  }

  void moonCreate() {
    moonSurface = createShape();
    moonSurface.beginShape();
    moonSurface.noStroke();
    moonSurface.fill(highlight);
    moonSurface.vertex(0,height);
    for (int j=0; j<width; j++) {
      ysurf[j] = height-noise(j*.02)*height*.25-height/20;
      moonSurface.vertex(j, ysurf[j]);
    }
    moonSurface.vertex(width,height);
    moonSurface.vertex(0,height);
    moonSurface.endShape();
  }

  void draw() {
    shape(moonSurface);
  }

  boolean hasCollided(float x, float y){
    if (ysurf[(int) x] > y) { // if the y val of the surface of the moon at that x is less that the y val of the checked point
      return false; // then the collision is false
    } else {
      return true;
    }
  }
}

class Spacecraft{
  float xloc,yloc;
  float xvel,yvel;
  float accelGravity = 0.002; // positive is downward
  float theta = 90; // deg, angular position, positive CCW
  float omega = 0;  // deg per (frame?) angular acceleration (actually rate?, positive CCW
  float alpha = 0.02; // rotation power (acceleration?)
  float thrust = 0.01;
  boolean thrustingMain = false;
  boolean thrustingLeft = false;
  boolean thrustingRight = false;
  color flameRed = #CA054D;
  color flameYellow = #FFB627;
  color flameOrange = #FE4A49;
  color rocket = #297373;
  boolean isDestroyed = false;
  boolean isLanded = false;
  float hudSpin = 0;
  float thrustscroll = 0;

  Spacecraft(){
    randomlySetSpacecraft();
  }

  Spacecraft(float _xloc, float _yloc, float _xvel, float _yvel){
    xloc = _xloc;
    yloc = _yloc;
    xvel = _xvel;
    yvel = _yvel;
  }

  void draw(){
    if (!isDestroyed) {
      craftDraw();
    } else {
      fill(200,50,50);
      ellipse(xloc, yloc, 40, 40);
    }
      
    if (isLanded) {
      fill(50,200,50,50);
      ellipse(width/2, height/2, width/2, width/2);
    }
  }

  void update(){
    if (moon.hasCollided(xloc,yloc) && !isLanded && !isDestroyed) {
      if (abs(xvel) > 0.2 || abs(yvel) > 0.1) {
        isDestroyed = true;
      } else {
        isLanded = true;
      }
    }

    if (!isDestroyed && !isLanded) {
      newtonian();
      engineForces();
    } else {
      stopRates();
    }

    if(xloc <= 0){
      xloc = width;
    } else if (xloc >= width) {
      xloc = 0;
    }
  }

  void randomlySetSpacecraft(){
    xloc = random(width/5, width*4/5);
    yloc = random(height/5, height*2/5);
    xvel = random(1) - 0.5;
    yvel = random(1) - 0.5;
    theta = 90;
    omega = 0;
  }

  void engineForces(){
    if (thrustingMain){ // apply thrust if pressing UP or if hand grasped
      xvel = xvel + thrust * cos(radians(theta));
      yvel = yvel - thrust * sin(radians(theta));
    }
    if (thrustingLeft) {
      omega = omega + alpha;
    }
    if (thrustingRight) {
      omega = omega - alpha;
    }
  }

  void newtonian() {
    yvel = yvel + accelGravity;
    yloc = yloc + yvel;
    xloc = xloc + xvel;
  }

  void stopRates(){
    xvel = 0;
    yvel = 0;
    omega = 0;
  }

  void mainEngine(boolean engineIsOn){
    thrustingMain = engineIsOn;
  }

  void thrustLeft(boolean _thrustingLeft){
    thrustingLeft = _thrustingLeft;
  }

  void thrustRight(boolean _thrustingRight){
    thrustingRight = _thrustingRight;
  }

  void craftDraw() {
    float x1 = xloc + 30*cos(radians(theta)); // top of rocket
    float y1 = yloc - 30*sin(radians(theta));
    float x2 = xloc + 10*sin(radians(theta)); // right of rocket
    float y2 = yloc + 10*cos(radians(theta));
    float x3 = xloc - 10*sin(radians(theta)); // left of rocket
    float y3 = yloc - 10*cos(radians(theta));
    float x4 = xloc - 6*cos(radians(theta)); // flame center
    float y4 = yloc + 6*sin(radians(theta));
    theta = theta + omega;
    fill(rocket);
    triangle(x1, y1, x2, y2, x3, y3);
    if (thrustingMain) {
      fill(flameRed);
      triangle(x2, y2, x3, y3, x4, y4);
    }
    fill(flameYellow);
    ellipse(xloc, yloc, 4, 4);
  }

  void drawHUD() {
    hudSpin = hudSpin + omega;
    thrustscroll++;
    float linelength = 200;
    stroke(#ff0000);
    line(width*3/4+linelength/2*cos(radians(handRoll)),height/4+linelength/2*sin(radians(handRoll)),
      width*3/4-linelength/2*cos(radians(handRoll)),height/4-linelength/2*sin(radians(handRoll))); // show hand roll
    stroke(#00ff00);
    line(width*3/4+linelength/2*cos(radians(deadbandhalf)),height/4+linelength/2*sin(radians(deadbandhalf)),
      width*3/4-linelength/2*cos(radians(deadbandhalf)),height/4-linelength/2*sin(radians(deadbandhalf))); // show roll deadand
    line(width*3/4+linelength/2*cos(radians(-deadbandhalf)),height/4+linelength/2*sin(radians(-deadbandhalf)),
      width*3/4-linelength/2*cos(radians(-deadbandhalf)),height/4-linelength/2*sin(radians(-deadbandhalf))); // show roll deadband
    stroke(#ffff00);
    line(width*3/4,height/2,
      width*3/4+xvel*70,height/2); // show x velocity*scale
    line(width*3/4,height/2,
      width*3/4,height/2+yvel*70); // show y velocity*scale
    stroke(#00ffff);
    line(width/2+200-80*cos(radians(theta)),height/2-80*sin(radians(-theta)),
      width/2+200-120*cos(radians(theta)),height/2-120*sin(radians(-theta))); // show craft roll
    fill(#ffffff);
    ellipse(width*3/4+100*cos(radians(-4*hudSpin)), height/2+100*sin(radians(-4*hudSpin)), 10, 10);
    ellipse(width*3/4+100*cos(radians(-4*hudSpin+90)), height/2+100*sin(radians(-4*hudSpin+90)), 10, 10);
    ellipse(width*3/4+100*cos(radians(-4*hudSpin+180)), height/2+100*sin(radians(-4*hudSpin+180)), 10, 10);
    ellipse(width*3/4+100*cos(radians(-4*hudSpin+270)), height/2+100*sin(radians(-4*hudSpin+270)), 10, 10);
    fill(#E26100);
    noStroke();
    if (handRoll < -deadbandhalf) {
      rect(width*3/4-100+(10*thrustscroll)%200,height/2+140, 5, 20); // scroll right below
      rect(width*3/4-100+(10*thrustscroll+40)%200,height/2+140, 5, 20); // scroll right below
      rect(width*3/4-100+(10*thrustscroll+80)%200,height/2+140, 5, 20); // scroll right below
      rect(width*3/4-100+(10*thrustscroll+120)%200,height/2+140, 5, 20); // scroll right below
      rect(width*3/4-100+(10*thrustscroll+160)%200,height/2+140, 5, 20); // scroll right below
      rect(width*3/4+100+(-10*thrustscroll)%200,height/2-140, 5, 20); // scroll left above
      rect(width*3/4+100+(-10*thrustscroll+40)%200,height/2-140, 5, 20); // scroll left above
      rect(width*3/4+100+(-10*thrustscroll+80)%200,height/2-140, 5, 20); // scroll left above
      rect(width*3/4+100+(-10*thrustscroll+120)%200,height/2-140, 5, 20); // scroll left above
      rect(width*3/4+100+(-10*thrustscroll+160)%200,height/2-140, 5, 20); // scroll left above
    }
    if (handRoll > deadbandhalf) {
      rect(width*3/4+100+(-10*thrustscroll)%200,height/2+140, 5, 20); //scroll left below
      rect(width*3/4+100+(-10*thrustscroll+40)%200,height/2+140, 5, 20); //scroll left below
      rect(width*3/4+100+(-10*thrustscroll+80)%200,height/2+140, 5, 20); //scroll left below
      rect(width*3/4+100+(-10*thrustscroll+120)%200,height/2+140, 5, 20); //scroll left below
      rect(width*3/4+100+(-10*thrustscroll+160)%200,height/2+140, 5, 20); //scroll left below
      rect(width*3/4-100+(10*thrustscroll)%200,height/2-140, 5, 20); // scroll right above
      rect(width*3/4-100+(10*thrustscroll+40)%200,height/2-140, 5, 20); // scroll right above
      rect(width*3/4-100+(10*thrustscroll+80)%200,height/2-140, 5, 20); // scroll right above
      rect(width*3/4-100+(10*thrustscroll+120)%200,height/2-140, 5, 20); // scroll right above
      rect(width*3/4-100+(10*thrustscroll+160)%200,height/2-140, 5, 20); // scroll right above
    }
  }

}