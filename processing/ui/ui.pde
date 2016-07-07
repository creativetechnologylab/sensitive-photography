import netP5.*;
import oscP5.*;
import ddf.minim.*;

PImage img; 
float adjustTarget = 0.0;
float current = 0.0;
color c;

float speed = 0.05;
boolean easing = false;

OscP5 oscP5;
NetAddress location;
OscMessage message;

int messageId = 0;
boolean processing = false;
boolean recording = false;
boolean pausing = true;
boolean debug = false;

int recordTimer = millis()/1000;
int averageVolume;

float[] data = new float[60];
float total = 0, average = 0;
int p = 0, n = 0;

Minim minim;
AudioInput in;

void setup() {
  //fullScreen();
   size(1200, 800);
  colorMode(HSB, 360, 100, 100, 1.0);

  oscP5 = new OscP5(this, 13000);
  location = new NetAddress("127.0.0.1", 12000);

  //int dd = displayDensity();
  pixelDensity(displayDensity());
  img = loadImage("final_2400x1600.jpg");  // Load the image into the program

  c = color(358, 0, 73);

  minim = new Minim(this);

  // use the getLineIn method of the Minim object to get an AudioInput
  in = minim.getLineIn();
  
  send("/kill", 0);
  //delay(5000);
}

void send(String topic, int id) {
  message = new OscMessage(topic);
  message.add(id);
  oscP5.send(message, location);
}

void showMessage(String msg, int offsetX, int offsetY) {
  textSize(12);
  textAlign(LEFT);
  fill(0, 0, 99);
  text(msg, 20, 29);
}

void showPaused(){
  showMessage("Waiting. Please speak." + average, 0, 0);
}

void showRecording() {
  int now = millis()/1000;
  int count = 10 - (now-recordTimer);
  
  showCircle(1);
  if(count > 0) {
    fill(0, 0, 99, 0.6);
    textAlign(CENTER);
    textSize(10);
    text(count, 25, 29);
  }
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
  println("Start recording");
  recordTimer = millis()/1000;
  messageId++;
  send("/record", messageId);
  recording = true;
}

void draw() {
  //delay(250);
  background(0);

  color c1 = color(51, 45, 80); // yellow
  color c2 = color(214, 46, 59);  // blue

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

   int brightnessCentre = 50;
   int brightDiff;
    if (current > 0) {
      brightDiff = abs(int(brightnessCentre-brightness(c1)));
      //println("bright:" + int(brightnessCentre+int(current*brightDiff)));
      c = color(hue(c1), int(current*saturation(c1)), int(brightnessCentre+int(current*brightDiff)));
    } else {
      brightDiff = int(brightnessCentre-brightness(c2));
      //println("bright:" + int(brightnessCentre+int(current*brightDiff)));
      c = color(hue(c2), int(abs(current)*saturation(c2)), int(brightnessCentre+int(current*brightDiff)));
    }
  }

  tint(hue(c), saturation(c), brightness(c));

  imageMode(CENTER);
  image(img, width/2, height/2, img.width/2, img.height/2);

  if (debug == false && pausing == false && recording == false && processing == false) {
    startRecording();
  } else if (recording == true) {
    showRecording();
  } else if (processing == true) {
    showMessage("Processing", 0, 0);
  } else if (pausing == true) {
    if(average > 0){
       pausing = false;
    } else {
      showPaused();
    }
  }
  
  nextValue(in.left.level());
  //showMessage(str(average));
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  
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

// Use the next value and calculate the
// moving average
public void nextValue(float value){
  total -= data[p];
  data[p] = value;
  total += value;
  p = ++p % data.length;
  if(n < data.length) n++;
  average = total / n;
}

void keyPressed() {
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

  if(debug == true && _key != -99){
    adjustTarget = map(_key, -5, 5, -1, 1);
  }
} 