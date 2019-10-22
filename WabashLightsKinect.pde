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


color[] colors = {
  color(255, 255, 255), 
  color(255, 255, 0),
  color(255, 0, 255), 
  color(128, 0, 0),
  color(0, 64, 64), 
  color(0, 0, 64)
};

float lowerThreshold = 600;
float upperThreshold = 3000;

void setup() {

  // Rendering in P3D
  size(800, 600, P3D);

  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();

  smooth(16);
  strokeWeight(4);
}


void draw() {
  background(colors[colors.length - 1]);
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
      int offset = (kinect2.depthWidth - x) + y * kinect2.depthWidth;
      int z = depth[offset]; 
      
      stroke(colorPhase(z));
      
      //calculte the x, y, z camera position based on the depth information
      PVector point = depthToPointCloudPos(x, y, z);

      // Draw a point
      vertex(point.x, point.y, point.z);
    }
  }
  endShape();

  popMatrix();

  // Rotate
  //a += 0.0015f;
}

// Lerp between different colors based on distance
color colorPhase(float zValue) {
  color phaseColor = colors[0];
  float increment = (upperThreshold - lowerThreshold) / colors.length;
  for (int i = 0; i < colors.length; i ++) {
    float currentThreshold = lowerThreshold + i * increment;
    float nextThreshold = lowerThreshold + (i + 1) * increment;
    if (zValue > currentThreshold) {
      int lowIndex = Math.max(i - 1, 0);
      float lerpValue = (zValue - currentThreshold) / (nextThreshold - currentThreshold);
      color nextIndex = Math.min(i + 1, colors.length - 1);
      phaseColor = lerpColor(colors[i], colors[nextIndex], lerpValue);
    }
  }   

  return phaseColor;
}

//calculte the xyz camera position based on the depth data
PVector depthToPointCloudPos(int x, int y, float depthValue) {
  PVector point = new PVector();
  point.z = (depthValue);// / (1.0f); // Convert from mm to meters
  point.x = (x - CameraParams.cx) * point.z / CameraParams.fx;
  point.y = (y - CameraParams.cy) * point.z / CameraParams.fy;
  return point;
}
