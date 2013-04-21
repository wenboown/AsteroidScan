// Daniel Shiffman
// Kinect Point Cloud example
// http://www.shiffman.net
// https://github.com/shiffman/libfreenect/tree/master/wrappers/java/processing

import org.openkinect.*;
import org.openkinect.processing.*;
import processing.dxf.*;
import processing.pdf.*;

boolean record = false;
boolean rgb = true;
boolean pc= true;
boolean ir = false;

// Kinect Library object
Kinect kinect;

float a = 0;

// Size of kinect image
int w = 640;
int h = 480;


// We'll use a lookup table so that we don't have to repeat the math over and over
float[] depthLookUp = new float[2048];

void setup() {
  size(1280,600,P3D);
  kinect = new Kinect(this);
  kinect.start();
  kinect.enableDepth(pc);
  kinect.enableRGB(rgb);
  // We don't need the grayscale image in this example
  // so this makes it more efficient
  kinect.processDepthImage(false);

  // Lookup table for all possible depth values (0 - 2047)
  for (int i = 0; i < depthLookUp.length; i++) {
    depthLookUp[i] = rawDepthToMeters(i);
  }
}
int counter = 0;
  void draw() {
    if (record == true) {
beginRaw(DXF, "raw.dxf"); 
}
  //beginRaw(PDF,"raw1.pdf");
    background(0);
    image(kinect.getVideoImage(),800,20);
   // beginRaw(DXF, "raw.dxf"); 
    fill(255);
    textMode(SCREEN);
    text("Kinect FR: " + (int)kinect.getDepthFPS() + "\nProcessing FR: " + (int)frameRate,10,10);
   text("RGB/IR FPS: " + (int) kinect.getVideoFPS(),10,50);
  text("Press 'p' to enable/disable point cloud    Press 'r' to enable/disable rgb image  Press Space Bar to save file  Framerate: " + frameRate,10,80);

    // Get the raw depth as array of integers
    int[] depth = kinect.getRawDepth();
  
    // We're just going to calculate and draw every 4th pixel (equivalent of 160x120)
    int skip = 4;
  
    // Translate and rotate
    translate(width/2,height/2,-50);
    rotateY(a);
  
    for(int x=0; x<w; x+=skip) {
      for(int y=0; y<h; y+=skip) {
        int offset = x+y*w;
  
        // Convert kinect data to world xyz coordinate
        int rawDepth = depth[offset];
        PVector v = depthToWorld(x,y,rawDepth);
  
        stroke(255);
        pushMatrix();
        // Scale up by 200
        float factor = 350;
        translate(v.x*factor-600,v.y*factor,factor-v.z*factor);
        // Draw a point
        point(0,0);
        popMatrix();
      }
    }
  
    // Rotate
   // a += 0.015f;
   if (record == true) {
endRaw();
record = false; // Stop recording to the file
}
  }

// These functions come from: http://graphics.stanford.edu/~mdfisher/Kinect.html
float rawDepthToMeters(int depthValue) {
  if (depthValue < 2047) {
    return (float)(1.0 / ((double)(depthValue) * -0.0030711016 + 3.3309495161));
  }
  return 0.0f;
}

PVector depthToWorld(int x, int y, int depthValue) {

  final double fx_d = 1.0 / 5.9421434211923247e+02;
  final double fy_d = 1.0 / 5.9104053696870778e+02;
  final double cx_d = 3.3930780975300314e+02;
  final double cy_d = 2.4273913761751615e+02;

  PVector result = new PVector();
  double depth =  depthLookUp[depthValue];//rawDepthToMeters(depthValue);
  result.x = (float)((x - cx_d) * depth * fx_d);
  result.y = (float)((y - cy_d) * depth * fy_d);
  result.z = (float)(depth);
  return result;
}

void keyPressed() {
if (key == ' ') {
// Press Space to save the file
record = true;
counter++;  //Thanks to Dr. Rhazes Spell for putting the counter in adding functionality.
}
  else if (key == 'r') {
    rgb = !rgb;
    if (rgb) ir = false;
    kinect.enableRGB(rgb);
  }
    else if (key == 'p') {
    pc = !pc;
    kinect.enableDepth(pc);
  }
}

void stop() {
  kinect.quit();
  super.stop();
}

