import peasy.*;
import processing.sound.*;
FFT fft;
AudioIn in;
int bands = 512;
float[] spectrum = new float[bands];

PeasyCam cam;

PVector[][] globe;

int total = 100;

void setup() {
  fullScreen(P3D, 2); 
  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);
  in.start();
  fft.input(in);
  cam = new PeasyCam(this, 200);
  
  globe = new PVector[total+1][total+1];
  colorMode(HSB);
  noStroke();
}

float t1,t2,t3,t4,t5,t6,t7,t8,t9,t10;
float amp = 0.0;
float a = 1.0;
float b = 1.0;

float supershape(float theta, float m, float n1, float n2, float n3) {
 //a = amp;
 float t1 = abs((1/a)*cos(m * theta / 4));
 t1 = pow(t1,n2);
 float t2 = abs((1/b)*sin(m*theta/4));
 t2 = pow(t2, n3);
 float t3 = t1 + t2;
 float r = pow(t3, -1/n1);
 
 return r;
}


float t = 0;

////supershape control values////
//min value
float s1mN = 1.0;
float s1n1N = 0.5;
float s1n2N = 1.0;
float s1n3N = 1.0;
float s2mN = 1.0;
float s2n1N = 1.0;
float s2n2N = 0.5;
float s2n3N = 1.5;
//magnitude
float s1mM = 10.0;
float s1n1M = 0.25;
float s1n2M = 5.0;
float s1n3M = 3.0;
float s2mM = 10.0;
float s2n1M = 5.0;
float s2n2M = 5.0;
float s2n3M = 3.0;

//how quick errything goes
float speed = 0.0001;
boolean pause = false;
boolean DAmp = true;

//control shape color
boolean fillIt = false;
boolean strokeIt = true;
float colorRange = 25;

void draw() {
  background(0);
  fill(255);
  lights();
  float r = 200;
  rotateX(t/20);
  rotateY(t/10);
  fft.analyze(spectrum);
  if (DAmp)
    scale(amp*100+1);
  
  //supershape 1 values
  float s1m = abs(cos(t/10.0) * s1mM) + s1mN;
  float s1n1 = abs(sin(t/11.0) * s1n1M) + s1n1N;
  float s1n2 = abs(cos(t/20.0) * s1n2M) + s1n2N;
  float s1n3 = abs(sin(t/17.0) * s1n3M) + s1n3N;
  
  //supershape 2 values
  float s2m = abs(cos(t/9.0) * s2mM) + s2mN;
  float s2n1 = abs(sin(t/5.0)* s2n1M) + s2n1N;
  float s2n2 = abs(sin(t/16.0) * s2n2M) + s2n2M;
  float s2n3 = abs(cos(t/19.0) * s2n1M) + s2n3M;
  
  //show me the values
  fill(255);
  //System.out.println("SuperShape 1 " + s1m + " " + s1n1 + " " + s1n2 + " " + s1n3);
  //System.out.println("SuperShape 2 " + s2m + " " + s2n1 + " " + s2n2 + " " + s2n3);

  
  
  for(int i = 0; i < total + 1; i++) {
    float lat = map(i, 0, total, -HALF_PI, HALF_PI);
    float r2 = supershape(lat, 
      s1m, //spikes
      s1n1,      //smooth vs spikey
      s1n2,            //shape of spike
      s1n3);           //shape of other spike
    for(int j = 0; j < total + 1; j++) {
       float lon = map(j, 0, total, -PI, PI);
       float r1 = supershape(lon, 
       s2m, //spikes
       s2n1,             //smooth vs spikey
       s2n2,            //shape of spike
       s2n3);           //shape of other spike
       float x = r * r1 * cos(lon) * r2 * cos(lat);
       float y = r * r1 * sin(lon) * r2 * cos(lat);
       float z = r * r2 * sin(lat);
       globe[i][j] = new PVector(x,y,z);
       
    }
  }
  //stroke(255);
  //noFill();
  for(int i = 0; i < total; i++) {
    beginShape(TRIANGLE_STRIP);
    float hu = map(i, 0, total, 0+t*10, colorRange+t*10);
    if (fillIt)
      fill(hu % 255, 255, 255);
    else
      noFill();
    if (strokeIt)
      stroke(hu % 255, 255, 255);
    else
      noStroke();
    for(int j = 0; j < total + 1; j++) {
      PVector v1 = globe[i][j];
      vertex(v1.x,v1.y,v1.z);
      PVector v2 = globe[i+1][j];
      vertex(v2.x, v2.y, v2.z);
        
    }
    endShape();
    
  }
  
  
  //control time
  if ( !pause)
    t += speed;
  
  float totalFFT = 0;
  for(int i = 0; i < bands; i ++) {
    totalFFT = totalFFT + spectrum[i];
  }
  float aver = totalFFT/bands;
  //smooth out size by averaging last 5 values
  t10 = t9;
  t9 = t8;
  t8 = t7;
  t7 = t6;
  t6 = t5;
  t5 = t4;
  t4 = t3;
  t3 = t2;
  t2 = t1;
  t1 = aver;
  amp = (t1 + t2 + t3 +t4 + t5 + t6 + t7 + t8 + t9 + t10)/2;
  //System.out.println(amp);
}


void keyPressed() {
  //shape 1 min
  if (key == '1')
    s1mN++;
  if (key == '2')
    s1mN--;
  if (key == 'q')
    s1n1N = s1n1N + .1;
  if (key == 'w')
    s1n1N = s1n1N - .1;
  if (key == 'a')
    s1n2N = s1n2N + .1;
  if (key == 's')
    s1n2N = s1n2N - .1;
  if (key == 'z')
    s1n3N = s1n3N + .1;
  if (key == 'x')
    s1n3N = s1n3N - .1;
    
  //shape 2 min
  if (key == '3')
    s2mN++;
  if (key == '4')
    s2mN--;
  if (key == 'e')
    s2n1N = s2n1N + .1;
  if (key == 'r')
    s2n1N = s2n1N - .1;
  if (key == 'd')
    s2n2N = s2n2N + .1;
  if (key == 'f')
    s2n2N = s2n2N - .1;
  if (key == 'c')
    s2n3N = s2n3N + .1;
  if (key == 'v')
    s2n3N = s2n3N - .1;
    
  //shape 1 magnitude
  if (key == '5')
    s1mM++;
  if (key == '6')
    s1mM--;
  if (key == 't')
    s1n1M = s1n1M + .1;
  if (key == 'y')
    s1n1M = s1n1M - .1;
  if (key == 'g')
    s1n2M = s1n2M + .1;
  if (key == 'h')
    s1n2M = s1n2M - .1;
  if (key == 'b')
    s1n3M = s1n3M + .1;
  if (key == 'n')
    s1n3M = s1n3M - .1;
    
  //shape 2 magnitude
  if (key == '7')
    s2mM++;
  if (key == '8')
    s2mM--;
  if (key == 'u')
    s2n1M = s2n1M + .1;
  if (key == 'i')
    s2n1M = s2n1M - .1;
  if (key == 'j')
    s2n2M = s2n2M + .1;
  if (key == 'k')
    s2n2M = s2n2M - .1;
  if (key == 'm')
    s2n3M = s2n1M + .1;
  if (key == ',')
    s2n3M = s2n3M - .1;
    
  //control a and b
  if (key == '9')
    a = a + .1;
  if (key == '(')
    a = a - .1;
  if (key == '0')
    b = b + .1;
  if (key == ')')
    b = b - .1;
    
  //control speed
  if (key == '[')
    speed = speed + .005;
  if (key == ']')
    speed = speed - .005;
  if (key == 'p') {
    if (pause)
      pause = false;
    else
      pause = true;
  }
  //toggle noise control
  if (key == 'o') {
    if (DAmp)
      DAmp = false;
    else
      DAmp = true;
  } 
  PrintInfo();
  
  //color control
  if (key == 'l') {
    if (fillIt)
      fillIt = false;
    else
      fillIt = true;
  } 
  if (key == ';') {
    if (strokeIt)
      strokeIt = false;
    else
      strokeIt = true;
  } 
  if (key == '.')
    colorRange = colorRange + 10;
  if (key == '/')
    colorRange = colorRange - 10;
    
  //resolution control
  if (key == '-')
    total = total + 5;
  if (key == '=')
    total = total - 5;
}

void PrintInfo() {
   System.out.println("Shape 1: " + s1mN + " " + s1n1N + " " + s1n2N + " " + s1n3N + "\t" + "Shape 2: " + s2mN + " " + s2n1N + " " + s2n2N + " " + s2n3N); 
}