import netP5.*;
import oscP5.*;
import ddf.minim.*;

PImage img; 
float adjustTarget = 0.0;
float current = 0.0;
color c;

float speed = 0.08;
boolean easing = false;

OscP5 oscP5;
NetAddress location;
OscMessage message;

int messageId = 0;
boolean processing = false;
boolean recording = false;
boolean pausing = true;

int pauseTimer;

Minim minim;
AudioInput in;

void setup() {
  // fullScreen();
  size(700, 700);
  colorMode(HSB, 360, 100, 100, 1.0);

  oscP5 = new OscP5(this, 13000);
  location = new NetAddress("127.0.0.1", 12000);

  pixelDensity(2);
  img = loadImage("final_2400x1600.jpg");  // Load the image into the program

  c = color(358, 0, 73);

  minim = new Minim(this);

  // use the getLineIn method of the Minim object to get an AudioInput
  in = minim.getLineIn();
}

void send(String topic, int id) {
  message = new OscMessage(topic);
  message.add(id);
  oscP5.send(message, location);
}

void showCircle(int state) {

  int cwidth = 20;
  int cheight = 20;
  
  float level = map(in.left.level(), 0, 0.05, 0, 1);
  level = constrain(level, 0, 1);
  
  switch(state) {
  case 1:
    // Recording.
    fill(0, 99, 99, 0.75);
    cwidth = 20+int(30*in.left.level());
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

void startRecording() {
  messageId++;
  send("/record", messageId);
  recording = true;
}

void draw() {
  //delay(250);

  background(0);

  color c1 = color(358, 69, 73); // red
  color c2 = color(53, 65, 73);  // yellow

  if (adjustTarget != current) {

    float dTarget = adjustTarget-current;
    if (easing == true) {
      current += dTarget*speed;
    } else {

      speed = (current < adjustTarget) ? speed : speed*-1;
      if ((speed > 0 && current+speed > adjustTarget)
        || (speed < 0 && current+speed < adjustTarget)) {
        current = adjustTarget;
      } else {
        current += speed;
      }
    }

    current = constrain(current, -1, 1);

    println("adjustTarget" +adjustTarget);
    println(current);

    if (current > 0) {
      c = color(hue(c1), int(current*saturation(c1)), brightness(c1));
    } else {
      c = color(hue(c2), int(abs(current)*saturation(c2)), brightness(c2));
    }
  }

  tint(hue(c), saturation(c), brightness(c));

  imageMode(CENTER);
  image(img, width/2, height/2, img.width/2, img.height/2);

  if (pausing == false && recording == false && processing == false) {
    startRecording();
  } else if (processing == true) {
    showCircle(2);
  } else if (pausing == true) {
    showCircle(1);
  }
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  //print("### received an osc message.");
  //print(" addrpattern: "+theOscMessage.addrPattern());
  //println(" typetag: "+theOscMessage.typetag());

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
      adjustTarget = map(score, -5, 5, -1, 1);
    }
  }
}

void keyPressed() {
  int _key = 0;
  switch(key) {
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
  }


  adjustTarget = map(_key, -5, 5, -1, 1);
} 