import processing.video.*;
import oscP5.*;
import netP5.*;

Capture video;
 
PImage prevFrame;
 
float threshold = 150;
int Mx = 0;
int My = 0;
int ave = 0;
float bx;
float by;
int boxSize = 75;
boolean overBox = false;
boolean locked = false;
float xOffset = 0.0; 
float yOffset = 0.0;
int zoom = 4;
//int width = 160;
//int height = 120;

//int ballX = width/2;
//int ballY = height/2;
//int rsp = 5;
OscP5 oscP5;
NetAddress myRemoteLocation;
 
void setup() {
  size(160, 120);
  video = new Capture(this, width, height, 30);
  video.start();
      
  prevFrame = createImage(video.width, video.height, RGB);
  
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("127.0.0.1",12001);
}
 
void draw() {
  background(200);
 //float avgX = 0;
 //float avgY = 0;
 
 
 
  if (video.available()) {
 
    prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height); 
    prevFrame.updatePixels();
    video.read();
  }
  image(video, 0, 0);
  
  
 
  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();
 
  Mx = 0;
  My = 0;
  ave = 0;
 
 
  for (int x = 90; x < video.width; x ++ ) {
    for (int y = 90; y < video.height; y ++ ) {
 
      int loc = x + y * video.width;            
      color current = video.pixels[loc];      
      color previous = prevFrame.pixels[loc]; 
 
 
      float r1 = red(current); 
      float g1 = green(current); 
      float b1 = blue(current);
      float r2 = red(previous); 
      float g2 = green(previous); 
      float b2 = blue(previous);
      float diff = dist(r1, g1, b1, r2, g2, b2);
 
 
      if (diff > threshold) { 
        pixels[loc] = video.pixels[loc];
        Mx += x;
        My += y;
        ave++;
        
      } 
      else {
 
        pixels[loc] = video.pixels[loc];
      }
    }
  }
  fill(255);
  rect(100, 100, width, height);
  if (ave != 0) { 
    Mx = Mx/ave;
    My = My/ave;
    
        
   OscMessage myMessage = new OscMessage("chute");
  
   myMessage.add(1); /* add an int to the osc message */

  /* send the message */
  oscP5.send(myMessage, myRemoteLocation); 
    
 
  }
  
  
 
  //if (Mx > ballX + rsp/2 && Mx > 50) {
  //  ballX+= rsp;
  //}
  //else if (Mx < ballX - rsp/2 && Mx > 50) {
  //  ballX-= rsp;
  //}
  //if (My > ballY + rsp/2 && My > 50) {
  //  ballY+= rsp;
  //}
  //else if (My < ballY - rsp/2 && My > 50) {
  //  ballY-= rsp;
  //}
 
  updatePixels();
  noStroke();
  fill(60, 60, 255);
   if (Mx > bx-boxSize && Mx < bx+boxSize && 
      My > by-boxSize && My < by+boxSize) {
    overBox = true;  
    if(locked) { 
      stroke(255); 
      fill(153);
    } 
  } else {
    stroke(153);
    fill(153);
    overBox = false;
  }
  
  // Draw the box
  //rect(bx, by, boxSize, boxSize);

  
  ellipse(80, 60, 50, 50);
}

void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}
