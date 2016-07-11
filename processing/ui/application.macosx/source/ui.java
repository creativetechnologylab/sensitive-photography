import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import netP5.*; 
import oscP5.*; 
import ddf.minim.*; 
import ddf.minim.analysis.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ui extends PApplet {






PImage img; 
float adjustTarget = 0.0f;
float current = 0.0f;
int c;

float speed = 0.05f;
boolean easing = false;

OscP5 oscP5;
NetAddress location;
OscMessage message;

int messageId = 0;
boolean processing = false;
boolean recording = false;
boolean pausing = true ;  // start 'true'
boolean debug = false; 
boolean initing = true; // start 'true'

int recordTimer = millis()/1000;
int initTimer;

int audioThresholdTimer = millis()/1000;
FloatList audioThresholdData = new FloatList();
float threshold = 99999;
float average;

FFT fft;
Minim minim;
AudioInput in;
int bufferSize = 1024;
int sampleRate = 5512;

float dRatio = 1.0f;

public void setup() {
  
  //size(1200, 800);
  colorMode(HSB, 360, 100, 100, 1.0f);

  oscP5 = new OscP5(this, 13000);
  location = new NetAddress("127.0.0.1", 12000);

  //int dd = displayDensity();
  
  img = loadImage("final_2400x1600.jpg");  // Load the image into the program
  //dRatio = float(height)/float(img.height);
  dRatio = PApplet.parseFloat(width)/PApplet.parseFloat(img.width);
  c = color(358, 0, 75);

  minim = new Minim(this);

  // use the getLineIn method of the Minim object to get an AudioInput
  in = minim.getLineIn( Minim.MONO, bufferSize, sampleRate );
  fft = new FFT( bufferSize, sampleRate );  

  // Kill any existing recordings.
  send("/kill", 0);
  //delay(5000);

  // Start init and threshold timers.
  initTimer = (millis()/1000) + 30;
  audioThresholdTimer = (millis()/1000) + 10;
}

public void send(String topic, int id) {
  message = new OscMessage(topic);
  message.add(id);
  oscP5.send(message, location);
}

public void showMessage(String msg, int offsetX, int offsetY) {
  textSize(24);
  textAlign(LEFT);
  fill(0, 0, 99);
  text(msg, 20+offsetX, 29+offsetY);
}

public void showPaused() {
  showMessage("What do you think of me?", 0, 0);
}

public void showRecording() {
  int now = millis()/1000;
  int count = 10 - (now-recordTimer);
  showMessage("I'm listening", 32, 5);
 
  showCircle(1);
  if (count > 0) {
    fill(0, 0, 99, 0.7f);
    textAlign(CENTER);
    textSize(14);
    text(count, 25, 30);
  }
}

public void showCircle(int state) {

  int cwidth = 30;
  int cheight = 30;

  switch(state) {
  case 1:
    // Recording.
    fill(0, 99, 99, 0.75f);
    cwidth = cwidth+PApplet.parseInt(30*in.left.level());
    cheight = cwidth;
    break;
  case 2:
    // Processing file.
    fill(0, 99, 99, 0);
    stroke(0, 99, 99);
    break;
  case 3:
    // Hidden.
    fill(50, 99, 99, 0); 
    break;
  }
  ellipseMode(CENTER);
  //smooth();
  ellipse(25, 25, cwidth, cheight);
}

public void startRecording() {
  println("Start recording");
  recordTimer = millis()/1000;
  messageId++;
  send("/record", messageId);
  recording = true;
}

public void draw() {

  fft.forward(in.left);
  average = getAverage();

  //delay(250);
  background(0);

  int c1 = color(51, 65, 80); // yellow
  int c2 = color(214, 56, 80);  // blue

  if (adjustTarget != current) {

    float dTarget = adjustTarget-current;
    if (easing == true) {
      current += dTarget*speed;
    } else {

      speed = (current < adjustTarget) ? abs(speed) : 0-abs(speed);
      println( "current:" + current );
      println( "target:" + adjustTarget );
      println( "speed:" + speed );

      if ( (speed > 0 && current+speed > adjustTarget) || (speed < 0 && current+speed < adjustTarget) ) {
        //println("blocked");
        current = adjustTarget;
      } else {
        current += speed;
      }
      println("current:" + current);
    }
    current = constrain(current, -1, 1);

    println("=========");

    int brightnessCentre = 75;
    int brightDiff;
    if (current > 0) {
      brightDiff = abs(PApplet.parseInt(brightnessCentre-brightness(c1)));
      //println("bright:" + int(brightnessCentre+int(current*brightDiff)));
      c = color(hue(c1), PApplet.parseInt(current*saturation(c1)), PApplet.parseInt(brightnessCentre+PApplet.parseInt(current*brightDiff)));
    } else {
      brightDiff = PApplet.parseInt(brightnessCentre-brightness(c2));
      //println("bright:" + int(brightnessCentre+int(current*brightDiff)));
      c = color(hue(c2), PApplet.parseInt(abs(current)*saturation(c2)), PApplet.parseInt(brightnessCentre+PApplet.parseInt(current*brightDiff)));
    }
  }

  tint(hue(c), saturation(c), brightness(c));

  imageMode(CENTER);
  println(dRatio);
  image(img, width/2, height/2, img.width*dRatio, img.height*dRatio);

  if (debug == false && pausing == false && recording == false && processing == false) {
    startRecording();
  } else if (recording == true) {
    showRecording();
  } else if (processing == true) {
    showMessage("I'm thinking, please wait.", 0, 0);
  } else if (pausing == true) {
    if (average > threshold) {
      pausing = false;
    } else {
      showPaused();
    }
  } else if (debug == true) {
    //showMessage(str(average), 0, 20);
    showRecording();
  }

  checkThreshold();
  int now = millis()/1000;
  if (initing == true) {
    if (initTimer > now) {
      showMessage("Current levels:" + str(average) + ". Threshold: " + str(threshold), 0, 20);
    } else {
      pausing = false; 
      initing = false;
    }
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
public void oscEvent(OscMessage theOscMessage) {

  if (theOscMessage.checkAddrPattern("/recordingcomplete") == true) {
    recording = false;
    processing = true;
    showCircle(2);
  }

  if (theOscMessage.checkAddrPattern("/processingcomplete") == true) {
    recording = false;
    processing = false;
    pausing = true;
    showCircle(3);

    if (theOscMessage.checkTypetag("i")) {
      int score = theOscMessage.get(0).intValue();
      if(score > 0 && score < 3){
        score = 4;
      }
      if(score < 0 && score > -3){
        score = -4;
      }
      adjustTarget = map(score, -5, 5, -1, 1);
    }
  }
}

public float getAverage() {
  float avg = 0;
  for (int i=0; i<fft.specSize(); i++) {
    float value = fft.getBand(i);
    avg += value;
  }
  avg /= fft.specSize();
  return avg;
}

public void checkThreshold() {
  int now = millis()/1000;

  if (audioThresholdTimer > now) {
    audioThresholdData.append(getAverage());
  } else if (audioThresholdData.size() > 0) {
    threshold = 0;
    for (int i = 0, count = audioThresholdData.size(); i < count; i++) {
      threshold += audioThresholdData.get(i);
    }
    threshold = (threshold/audioThresholdData.size())*3;
    audioThresholdData = new FloatList();
  }
}

public void keyPressed() {

  if (key == 'q') {
    audioThresholdTimer = (millis()/1000) + 5;
  }

  int _key = 0;
  switch(key) {
  case 'r':
    _key = 0;
    break;
  case '1':
    _key = 1;
    break;
  case '2':
    _key = 2;
    break;
  case '3':
    _key = 3;
    break;
  case '4':
    _key = 4;
    break;
  case '5':
    _key = 5;
    break;
  case '6':
    _key = -1;
    break;
  case '7':
    _key = -2;
    break;
  case '8':
    _key = -3;
    break;
  case '9':
    _key = -4;
    break;
  case '0':
    _key = -5;
    break;
  default:
    _key = -99;
    break;
  }

  if (debug == true && _key != -99) {
    adjustTarget = map(_key, -5, 5, -1, 1);
  }
} 
  public void settings() {  fullScreen();  pixelDensity(displayDensity()); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ui" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
