//**********************************************************************
// Program name      : .pde
// Author            : Bryan Costanza (GitHub: TravelByRocket)
// Date created      : 
// Purpose           : 
// Revision History  : 
// 20190223 --  New file structure. Preparing to branch for leapmotion.
//**********************************************************************

// Y is inverted from physical so gravity is positive
// Angle is measured as pitch (0 to the right and positive CCW)

float x = random(50,700); //craft point of action X
float y = random(50,300); //craft point of action Y
float x1;
float y1;
float x2;
float y2;
float x3;
float y3;
float x4;
float y4;
float vy = random(0,1);
float vx = random(0,1);
float ax = 0;
float g = 0.002; // ositive is downward
float theta = 90; //deg, angular position, positive CCW
float omega = 0; //deg per (frame?) angular acceleration, positive CCW
float alpha = 0.02; // rotation power
float thrust = 0.01;
boolean[] keys = {false, false, false, false};
color space = #39393A;
color flamer = #CA054D;
color flamey = #FFB627;
color flameo = #FE4A49;
color highlight = #E6E6E6;
color rocket = #297373;
float ysurf[] = new float[800];

void setup() {
  size(800, 800);
  noStroke();
  moonGen();
}

void draw() {
  background(space);
  moonDraw();
  if (y<ysurf[int(x)]) { // craft is flying
    newtonian();
    craftControl();
    craftDraw();
  } else if (y>ysurf[int(x)] && (vy > 0.2 || vx > 0.1)) { // craft has hit the ground hard
    fill(flamer);
    ellipse(x, y, 25, 25);
  } else { // craft has hit the ground safely
    omega=0; // would keep spinning after touchdown
    craftDraw();
    fill(#00FF00);
    ellipse(width/2, height/2, 100, 100);
  }
  //println(vy);
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
  if (keys[0]) {
    vy = vy - thrust*sin(radians(theta));
    vx = vx + thrust*cos(radians(theta));
    //println("theta ", sin(radians(theta)));
  }
  if (keys[1]) {
    omega = omega + alpha;
  }
  if (keys[2]) {
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
  if (keys[0]) {
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
