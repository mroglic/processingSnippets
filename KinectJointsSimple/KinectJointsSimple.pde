/* --------------------------------------------------------------------------
 * KinectJointsSimple
 * --------------------------------------------------------------------------
 * based on SimpleOpenNI User Test from Processing by Max Rheiner (Examples / SimpleOpenNI / OpenNI / User)
 * added drawJoints - draws all user's joints
 * added drawJoint - draws one user joint
 * added findClosestUser - finds user that is closest to Kinect (or returns -1 if there is no tracked user)
 * added getRealWorldJointPos - returns 3D joint position (world position)
 * added getProjectiveJointPos - returns 2D joint position (screen(projective) position)
 * note: this version works only with one user
 * --------------------------------------------------------------------------
 * author:  Milos Roglic / www.milosroglic.com
 * date:    21/02/2016 (d/m/y)
 * ----------------------------------------------------------------------------
 */

import SimpleOpenNI.*;

SimpleOpenNI  kinect;                      

void setup() {
  size(640, 480);
  
  kinect = new SimpleOpenNI(this);
  if(kinect.isInit() == false) {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // enable depthMap generation
  kinect.enableDepth();
   
  // enable skeleton generation for all joints
  kinect.enableUser();
 
  background(200,0,0);

  stroke(0,0,255);
  strokeWeight(3);
  smooth();
}

void draw(){
  // update the cam
  kinect.update();
  
  // draw depthImageMap
  image(kinect.depthImage(),0,0);
  //image(kinect.userImage(), 0, 0);
  
  int userId = findClosestUser();
  if (userId > -1){
    //drawSkeleton(userId);
    drawJoints(userId);
  }
}

int findClosestUser(){
  int closestUserId = -1;
  float closestUserZ = 8000;

  int[] userList = kinect.getUsers();
  for(int i=0; i < userList.length; i++){
    int userId = userList[i];
    if(kinect.isTrackingSkeleton(userId)){
      PVector torso = getRealWorldJointPos(userId, SimpleOpenNI.SKEL_TORSO);
      if (torso.z < closestUserZ){
        closestUserZ = torso.z;
        closestUserId = userId;
      }      
    }
  }

  return closestUserId;
}

void drawJoints(int userId){
  drawJoint(userId, SimpleOpenNI.SKEL_HEAD);
  drawJoint(userId, SimpleOpenNI.SKEL_NECK);

  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
  
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);

  drawJoint(userId, SimpleOpenNI.SKEL_TORSO);

  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);

  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
  drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
}

void drawJoint(int userId, int jointType){
  PVector realWorld = getRealWorldJointPos(userId, jointType);
  PVector projective = getProjectiveJointPos(realWorld);
  ellipse(projective.x, projective.y, 10, 10);
}

PVector getRealWorldJointPos(int userId, int jointType){
  PVector realWorld = new PVector();
  kinect.getJointPositionSkeleton(userId, jointType, realWorld);
  return realWorld; 
}

PVector getProjectiveJointPos(PVector realWorld){
  PVector projective = new PVector();
  kinect.convertRealWorldToProjective(realWorld, projective);
  return projective;
}

void drawSkeleton(int userId){
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);  
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curkinect, int userId){
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  
  curkinect.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curkinect, int userId){
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curkinect, int userId){
  //println("onVisibleUser - userId: " + userId);
}

void keyPressed(){
  switch(key){
  case ' ':
    kinect.setMirror(!kinect.mirror());
    break;
  }
}