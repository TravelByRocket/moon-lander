//**********************************************************************
// Program name      : .pde
// Author            : Bryan Costanza (GitHub: TravelByRocket)
// Date created      : 
// Purpose           : 
// Revision History  : 
// 20190223 -- New file structure. Preparing to branch for leapmotion.
// 20190223 -- addapting for LEAP Motion control
//**********************************************************************

import de.voidplus.leapmotion.*;

LeapMotion leap;

// Y is inverted from physical so gravity is positive
// Angle is measured as pitch (0 to the right and positive CCW)

float x = random(50,700); //craft point of action X
float y = random(50,300); //craft point of action Y
float x1, y1; // top of rocket
float x2, y2; // right of rocket
float x3, y3; // left of rocket
float x4, y4; // flame center
float vy = random(0,1);
float vx = random(0,1);
float ax = 0;
float g = 0.002; // positive is downward
float theta = 90; //deg, angular position, positive CCW
float omega = 0; //deg per (frame?) angular acceleration (actually rate?, positive CCW
float alpha = 0.02; // rotation power (acceleration?)
float thrust = 0.01;
boolean[] keys = {false, false, false, false};
color space = #000000;
color flamer = #CA054D;
color flamey = #FFB627;
color flameo = #FE4A49;
color highlight = #E6E6E6;
color rocket = #297373;
float ysurf[] = new float[800];
float handRoll = 0;
float handGrab = 0;
float hudspin = 0;
float thrustscroll = 0;
float deadbandhalf = 8;

void setup() {
  leap = new LeapMotion(this);
  size(800, 800);
  // fullScreen();
  noStroke();
  moonGen();
}

void draw() {
  pushMatrix();
  translate(width,0);
  rotate(PI/2);
  background(space);
  runleap();
  moonDraw();
  if (y < ysurf[int(x)]) { // craft is flying
    newtonian();
    craftControl();
    craftDraw();
  } else if (y > ysurf[int(x)] && (vy > 0.2 || vx > 0.1)) { // craft has hit the ground hard
    fill(flamer);
    ellipse(x, y, 25, 25);
    noLoop();
  } else { // craft has hit the ground safely
    omega=0; // would keep spinning after touchdown
    craftDraw();
    fill(#00FF00);
    ellipse(width/2, height/2, 100, 100);
    noLoop();
  }
  drawhud();
  //println(vy);
  popMatrix();
}

void keyPressed() {
  if (keyCode == UP)
    keys[0]=true;
  if (keyCode == LEFT)
    keys[1]=true;
  if (keyCode == RIGHT)
    keys[2]=true;
  if (keyCode == DOWN)
    keys[3]=true;
}

void keyReleased() {
  if (keyCode == UP)
    keys[0]=false;
  if (keyCode == LEFT)
    keys[1]=false;
  if (keyCode == RIGHT)
    keys[2]=false;
  if (keyCode == DOWN)
    keys[3]=false;
} 

void craftControl() {
  if (keys[0] || handGrab > 0.8){
    vy = vy - thrust*sin(radians(theta));
    vx = vx + thrust*cos(radians(theta));
    //println("theta ", sin(radians(theta)));
  }
  if (keys[1] || handRoll < -deadbandhalf) {
    omega = omega + alpha;
  }
  if (keys[2] || handRoll > deadbandhalf) {
    omega = omega - alpha;
  }
  if (keys[3]) {
  }
}

void craftDraw() {
  x1 = x + 30*cos(radians(theta)); // top of rocket
  y1 = y - 30*sin(radians(theta));
  x2 = x + 10*sin(radians(theta)); // right of rocket
  y2 = y + 10*cos(radians(theta));
  x3 = x - 10*sin(radians(theta)); // left of rocket
  y3 = y - 10*cos(radians(theta));
  x4 = x - 6*cos(radians(theta)); // flame center
  y4 = y + 6*sin(radians(theta));
  theta = theta + omega;
  fill(rocket);
  triangle(x1, y1, x2, y2, x3, y3);
  if (keys[0] || handGrab > 0.8) {
    fill(flamer);
    triangle(x2, y2, x3, y3, x4, y4);
  }
  fill(flamey);
  ellipse(x, y, 4, 4);
}

void moonGen() {
  for (int j=0; j<width; j++) {
    ysurf[j] = height-noise(j*.02)*height*.3;
  }
}

void moonDraw () {
  stroke(highlight);
  for (int i=0; i<width; i++) {
    line(i, height, i, ysurf[i]);
  }
  noStroke();
}

void newtonian() {
  vy = vy + g;
  y = y + vy;
  x = x + vx;
}

void runleap() {
    for (Hand hand : leap.getHands ()) {
      if (hand.isRight()) {
        // PVector handPosition       = hand.getPosition();
        handRoll            = hand.getRoll();
        handGrab            = hand.getGrabStrength();
        // println("handRoll: "+handRoll);
        }
    }
  }

void drawhud() {
  hudspin = hudspin + omega;
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
    width*3/4+vx*70,height/2); // show x velocity*scale
  line(width*3/4,height/2,
    width*3/4,height/2+vy*70); // show y velocity*scale
  stroke(#00ffff);
  line(width/2+200-80*cos(radians(theta)),height/2-80*sin(radians(-theta)),
    width/2+200-120*cos(radians(theta)),height/2-120*sin(radians(-theta))); // show craft roll
  fill(#ffffff);
  ellipse(width*3/4+100*cos(radians(-4*hudspin)), height/2+100*sin(radians(-4*hudspin)), 10, 10);
  ellipse(width*3/4+100*cos(radians(-4*hudspin+90)), height/2+100*sin(radians(-4*hudspin+90)), 10, 10);
  ellipse(width*3/4+100*cos(radians(-4*hudspin+180)), height/2+100*sin(radians(-4*hudspin+180)), 10, 10);
  ellipse(width*3/4+100*cos(radians(-4*hudspin+270)), height/2+100*sin(radians(-4*hudspin+270)), 10, 10);
  // println("hudspin: "+hudspin);
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