// Adapted from an example by Daniel Shiffman
// Thomas Sanchez Lengeling

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/

import java.nio.*;
import org.openkinect.processing.*;

// Kinect Library object
Kinect2 kinect2;

// Angle for rotation
float a = 3.1;

color near = color (255, 255, 255);
color mid = color(255, 0, 255);
color far = color(0, 0, 64);

float nearThreshold = 600;
float midThreshold = 1000;
float farThreshold = 2000;


void setup() {

  // Rendering in P3D
  size(800, 600, P3D);

  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();

  smooth(16);
  strokeWeight(5);
}


void draw() {
  background(far);
  // Translate and rotate
  pushMatrix();
  translate(width/2, height/2, 50);
  rotateY(a);

  // We're just going to calculate and draw every 2nd pixel
  int skip = 2;

  // Get the raw depth as array of integers
  int[] depth = kinect2.getRawDepth();
  
  beginShape(POINTS);
  for (int x = 0; x < kinect2.depthWidth; x+=skip) {
    for (int y = 0; y < kinect2.depthHeight; y+=skip) {
      int offset = x + y * kinect2.depthWidth;
      int z = depth[offset];
      float lerpValue;
      if (z > farThreshold) {
        continue;
      } else if ( z > midThreshold) {
        lerpValue = (z - midThreshold) / (farThreshold - midThreshold);
        stroke(lerpColor(mid, far, lerpValue));
      } else {
        lerpValue = (z - nearThreshold) / (midThreshold - nearThreshold);
        stroke(lerpColor(near, mid, lerpValue));
      }

      //calculte the x, y, z camera position based on the depth information
      PVector point = depthToPointCloudPos(x, y, z);

      // Draw a point
      vertex(point.x, point.y, point.z);
    }
  }
  endShape();
 
  popMatrix();

  fill(255, 0, 0);
  text(frameRate, 50, 50);

  // Rotate
  //a += 0.0015f;
}

//calculte the xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue);// / (1.0f); // Convert from mm to meters
  point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  return point;
}
