import java.util. * ;
import java.lang.Math;

//defining images and fonts to be used
PFont arial;
PFont arialSmaller;
PFont notcs;

PImage gear;
PImage screen;

void setup() {
  //sets canvas size and uses 3d rendering
  size(1920, 1080, P3D);

  //innocent font imports
  arial = createFont("Fox & Cat", 60);
  arialSmaller = createFont("Fox & Cat", 30);
  notcs = createFont("Comic Sans MS", 60);

  //the font isnt actually arial anymore
  textFont(arial);
  textAlign(CENTER, CENTER);

  //define images
  gear = loadImage("settings-icon.png");
  screen = loadImage("screen.jpg");

  //use antialiasing to smooth out the pixels
  smooth();
}

//this function reverses a boolean
boolean flipper(boolean bool) {
  boolean result;
  if (bool) {
    result = false;
  } else {
    result = true;
  }
  return result;

}

//this checks if mouse is within a box and returns t/f. The paramaters work the same as the rect() function
boolean mouseWithin(int xOne, int yOne, int xTwo, int yTwo) {
  if (mouseX > xOne && mouseX < (xTwo + xOne) && mouseY > yOne && mouseY < (yTwo + yOne)) {
    return true;
  } else {
    return false;
  }
}

//draws 1/8th of the rubiks cube, one of the mini cubes
void cube(int index) {

  //translates the mini cube to be off centered, based on its index. So that all the mini cubes arent on top of each other in the middle
  if (xvaluesInitial[index]) {
    translate(spacing, 0);
  } else {
    translate( - spacing, 0);
  }
  if (yvaluesInitial[index]) {
    translate(0, spacing);
  } else {
    translate(0, -spacing);
  }
  if (zvaluesInitial[index]) {
    translate(0, 0, spacing);
  } else {
    translate(0, 0, -spacing);
  }

  //dark gray or white depending on theme
  noStroke();
  fill(50, 50, 70);
  if (theme < 0) {
    fill(#ffffff);
  }
  //the colorless outline of the mini cube
  box(200);

  //draws the colores of the mini cubes, as 3d boxes so that they stick out and rotation doesn't matter. Checks for the index and draws 3/6 colores for each mini cubes
  if (index == 4 || index == 5 || index == 6 || index == 7) {
    fill(255, 0, 0);
    translate(24, 0);
    box(160);
    translate( - 24, 0);
  }
  if (index == 2 || index == 3 || index == 6 || index == 7) {
    fill(255, 255, 0);
    translate(0, 24);
    box(160);
    translate(0, -24);
  }
  if (index == 1 || index == 3 || index == 5 || index == 7) {
    fill(0, 0, 255);
    translate(0, 0, 24);
    box(160);
    translate(0, 0, -24);
  }
  if (index == 0 || index == 2 || index == 4 || index == 6) {
    fill(0, 255, 0);
    translate(0, 0, -24);
    box(160);
    translate(0, 0, 24);
  }
  if (index == 0 || index == 1 || index == 4 || index == 5) {
    fill(255, 255, 255);
    if (theme < 0) {
      fill(50, 50, 70);
    }
    translate(0, -24, 0);
    box(160);
    translate(0, 24, 0);
  }
  if (index == 0 || index == 1 || index == 2 || index == 3) {
    fill(255, 100, 60);
    translate( - 24, 0, 0);
    box(160);
    translate(24, 0);
  }

  //resets the transformation from the beginning of the function
  if (xvaluesInitial[index]) {
    translate( - spacing, 0);
  } else {
    translate(spacing, 0);
  }
  if (yvaluesInitial[index]) {
    translate(0, -spacing);
  } else {
    translate(0, spacing);
  }
  if (zvaluesInitial[index]) {
    translate(0, 0, -spacing);
  } else {
    translate(0, 0, spacing);
  }

}

//class to act as a variable, to log the information of each time the cube is turned
class TurnInfo {
  //0,1,2  (x y z)
  public int dimension;

  //true or false
  public boolean direction;

  //indexes (0-7)
  public int[] indexes = {
    0,
    0,
    0,
    0
  };
};

//the starting positions for each mini cube. Boolean variables are used for coordinates instead of numbers because I think it will save like a millibyte of memory
boolean[] xvaluesInitial = {
  false,
  false,
  false,
  false,
  true,
  true,
  true,
  true
};
boolean[] yvaluesInitial = {
  false,
  false,
  true,
  true,
  false,
  false,
  true,
  true
};
boolean[] zvaluesInitial = {
  false,
  true,
  false,
  true,
  false,
  true,
  false,
  true
};

//the current coordinates of the mini cubes
boolean[] xvalues = {
  false,
  false,
  false,
  false,
  true,
  true,
  true,
  true
};
boolean[] yvalues = {
  false,
  false,
  true,
  true,
  false,
  false,
  true,
  true
};
boolean[] zvalues = {
  false,
  true,
  false,
  true,
  false,
  true,
  false,
  true
};

//stores the indexes used during rotation. I probably could have used an array but a vecotor was easier
Vector < Integer > indexMem = new Vector < Integer > ();

//here is where the history of the rotations are stored
Vector < TurnInfo > turnLog = new Vector < TurnInfo > ();

//whether or not the program can accept new input. False during an animation
boolean ready = true;

//used for animations
int clock = 0;

//xpos and ypos are mouseX and mouseY from the last frame, angle is the current direction of travel for the mouse
int xpos = mouseX;
int ypos = mouseY;
double angle;

//mouse displacement in a straight line
float tempxdist;

//displacement (since the last frame) of the mouse in x and y dimensions
float mouseXMod;
float mouseYMod;

//starting cube viewing angle
float xrotate = 5.8 + TWO_PI;
float yrotate = 5.8 + TWO_PI;
float zrotate = 0.2;

//how big the cube is and how far apart the mini cubes are. was useful during testing
int spacing = 100;
int zoom = 100;

//theme and whether or not the settings screen is currently visible
int theme = 1;
boolean settingsScreen = true;

color backgroundColor = #ffffff;

//used for an easter egg
int slide = 0;
boolean sliding = false;
int slidePos = 0;

//curently bound controls
char[] controls = {
  'q',
  'a',
  'w',
  's',
  'e',
  'd'
};

//original controls in case of reset
char[] controlsDefault = {
  'q',
  'a',
  'w',
  's',
  'e',
  'd'
};

//if the program is listening for a key to be rebound
boolean[] remapping = {
  false,
  false,
  false,
  false,
  false,
  false
};

//funcion for rotating a layer of the cube in the x dimension. This function and the folling 2 are not visual, but translate the coordinates of the mini cubes in a circle so that the program knows where they are. All three work the same way
void turnX(boolean xLayer, boolean direction) {
  turnLog.add(new TurnInfo());
  turnLog.get(turnLog.size() - 1).dimension = 0;
  turnLog.get(turnLog.size() - 1).direction = flipper(direction);

  indexMem.clear();

  for (int i = 0; i < 8; i++) {
    if (xLayer == xvalues[i]) {
      if (yvalues[i]) {
        if (zvalues[i]) {
          if (direction) {
            zvalues[i] = false;
          } else {
            yvalues[i] = false;
          }
        } else {
          if (direction == false) {
            zvalues[i] = true;
          } else {
            yvalues[i] = false;
          }
        }
      } else {
        if (zvalues[i]) {
          if (direction == false) {
            zvalues[i] = false;
          } else {
            yvalues[i] = true;
          }
        } else {
          if (direction) {
            zvalues[i] = true;
          } else {
            yvalues[i] = true;
          }
        }
      }
      indexMem.add(i);
    }
  }
  for (int k = 0; k < indexMem.size(); k++) {
    turnLog.get(turnLog.size() - 1).indexes[k] = indexMem.get(k);
  }

  //for the turning animation
  ready = false;
  clock = 8;
}

void turnY(boolean yLayer, boolean direction) {
  turnLog.add(new TurnInfo());
  turnLog.get(turnLog.size() - 1).dimension = 1;
  turnLog.get(turnLog.size() - 1).direction = direction;

  indexMem.clear();

  for (int i = 0; i < 8; i++) {
    if (yLayer == yvalues[i]) {
      if (xvalues[i]) {
        if (zvalues[i]) {
          if (direction) {
            zvalues[i] = false;
          } else {
            xvalues[i] = false;
          }
        } else {
          if (direction == false) {
            zvalues[i] = true;
          } else {
            xvalues[i] = false;
          }
        }
      } else {
        if (zvalues[i]) {
          if (direction == false) {
            zvalues[i] = false;
          } else {
            xvalues[i] = true;
          }
        } else {
          if (direction) {
            zvalues[i] = true;
          } else {
            xvalues[i] = true;
          }
        }
      }
      indexMem.add(i);
    }
  }
  for (int k = 0; k < indexMem.size(); k++) {
    turnLog.get(turnLog.size() - 1).indexes[k] = indexMem.get(k);
  }
  ready = false;
  clock = 8;
}

void turnZ(boolean zLayer, boolean direction) {

  turnLog.add(new TurnInfo());
  turnLog.get(turnLog.size() - 1).dimension = 2;
  turnLog.get(turnLog.size() - 1).direction = flipper(direction);

  indexMem.clear();

  for (int i = 0; i < 8; i++) {
    if (zLayer == zvalues[i]) {
      if (xvalues[i]) {
        if (yvalues[i]) {
          if (direction) {
            yvalues[i] = false;
          } else {
            xvalues[i] = false;
          }
        } else {
          if (direction == false) {
            yvalues[i] = true;
          } else {
            xvalues[i] = false;
          }
        }
      } else {
        if (yvalues[i]) {
          if (direction == false) {
            yvalues[i] = false;
          } else {
            xvalues[i] = true;
          }
        } else {
          if (direction) {
            yvalues[i] = true;
          } else {
            xvalues[i] = true;
          }
        }
      }
      indexMem.add(i);
    }
  }
  for (int k = 0; k < indexMem.size(); k++) {
    turnLog.get(turnLog.size() - 1).indexes[k] = indexMem.get(k);
  }
  ready = false;
  clock = 8;
}

void draw() {

  //for easter egg, checks if the setting screen is swiped left/right
  if (mousePressed && Math.abs(mouseXMod) > 35 && Math.abs(mouseYMod) < 5 && settingsScreen) {
    sliding = true;
  }
  if (sliding) {
    if ((mouseXMod > 0 && slide < 0) || (mouseXMod < 0 && slide > -1920)) {
      slide += mouseXMod;
    }
  } else if (settingsScreen) {
    if (slidePos == 0 && slide < -79) {
      slide += 80;
    } else if (slidePos == 0 && slide < 0) {
      slide = 0;
    }
    if (slidePos == 1 && slide > -1873) {
      slide -= 80;
    } else if (slidePos == 1 && slide > -1920) {
      slide = -1920;
    }

  }

  if (slide <= 0 && slide >= -1920) {
    translate(slide, 0);
  } else if (slide < -1920) {
    translate( - 1920, 0);
  }

  //reset clutter from last cycle
  indexMem.clear();

  //set background color based on theme
  if (theme > 0) {
    backgroundColor = #ffffff;
  } else {
    backgroundColor = #2e3033;

  }

  //draw background
  background(backgroundColor);

  strokeWeight(4);

  //easter egg screen
  if (settingsScreen) {

    image(screen, 1920, 0, 1920, 1080);

    fill(#ffffff);
    textFont(notcs);
    text("COMIC SANS??", width * 1.67, height / 1.5);
  }

  // rounds mouse displacement to zero if it really isnt moving much
  tempxdist = (float) mouseX - (float) xpos;
  if (tempxdist == 0) {
    tempxdist = 0.0001;
  }

  //calculates mouse's displacement in a straight line from last frame
  double distance = Math.sqrt(Math.pow(Math.abs(mouseX - xpos), 2) + Math.pow(Math.abs(mouseY - ypos), 2));

  //calculating angle based on ratios between x distance and y distance. Annoyingly complicated
  if ((float) mouseX - (float) xpos < 0) {
    angle = PI - Math.atan(((float) mouseY - (float) ypos) / tempxdist);
  } else if ((float) mouseY - (float) ypos < 0) {
    angle = -Math.atan(((float) mouseY - (float) ypos) / tempxdist);
  } else {
    angle = TWO_PI - Math.atan(((float) mouseY - (float) ypos) / tempxdist);
  }

  mouseXMod = cos((float) angle) * (float) distance;
  mouseYMod = -sin((float) angle) * (float) distance;

  //check for click on settings screen button
  if (mousePressed && mouseX < 80 && mouseY < 80 && mouseX > 16 && mouseY > 16) {} else {

    if (mousePressed && settingsScreen == false) {

      //reset viewing angle
      if (xrotate == 5.8 + TWO_PI && yrotate == 5.8 + TWO_PI && zrotate == 0.2) {
        xrotate = 5.8;
        yrotate = 5.8;
        zrotate = 0.2;
      }

      //calculate the view rotation
      xrotate += mouseXMod / (PI * 45);

      yrotate -= mouseYMod * cos(xrotate) / (PI * 45);
      zrotate -= mouseYMod * sin(xrotate) * cos(yrotate) / (PI * 45);

    }

    //draw settings icon
    image(gear, 16, 16, 64, 64);
  }

  //center the cube on the screen
  translate(960, 540, -zoom);

  //rotate cube to view any side
  rotateY(xrotate);
  rotateX(yrotate);
  rotateZ(zrotate);

  //loops through each mini cube
  for (int i = 0; i < 8; i++) {

    //saves the translation/rotation state to reset after each mini cube is moved around
    pushMatrix();

    //does the most recent rotation
    if (ready && turnLog.size() > 0) {
      if (i == turnLog.get((turnLog.size() - 1)).indexes[0] || i == turnLog.get((turnLog.size() - 1)).indexes[1] || i == turnLog.get((turnLog.size() - 1)).indexes[2] || i == turnLog.get((turnLog.size() - 1)).indexes[3]) {
        if (turnLog.get((turnLog.size() - 1)).dimension == 0) {
          if (turnLog.get((turnLog.size() - 1)).direction) {
            rotateX(PI / 2);
          } else {
            rotateX( - PI / 2);
          }
        } else if (turnLog.get((turnLog.size() - 1)).dimension == 1) {
          if (turnLog.get((turnLog.size() - 1)).direction) {
            rotateY(PI / 2);
          } else {
            rotateY( - PI / 2);
          }
        } else {
          if (turnLog.get((turnLog.size() - 1)).direction) {
            rotateZ(PI / 2);
          } else {
            rotateZ( - PI / 2);
          }
        }
      }
    }

    //animates the rotation currently happening
    if (ready == false) {
      if (i == turnLog.get((turnLog.size() - 1)).indexes[0] || i == turnLog.get((turnLog.size() - 1)).indexes[1] || i == turnLog.get((turnLog.size() - 1)).indexes[2] || i == turnLog.get((turnLog.size() - 1)).indexes[3]) {
        if (turnLog.get((turnLog.size() - 1)).dimension == 0) {
          if (turnLog.get((turnLog.size() - 1)).direction) {
            rotateX((8 - clock) * PI / 16);
          } else {
            rotateX( - (8 - clock) * PI / 16);
          }
        } else if (turnLog.get((turnLog.size() - 1)).dimension == 1) {
          if (turnLog.get((turnLog.size() - 1)).direction) {
            rotateY((8 - clock) * PI / 16);
          } else {
            rotateY( - (8 - clock) * PI / 16);
          }
        } else {
          if (turnLog.get((turnLog.size() - 1)).direction) {
            rotateZ((8 - clock) * PI / 16);
          } else {
            rotateZ( - (8 - clock) * PI / 16);
          }
        }
      }
    }

    //rotates all the mini cubes from start for each rotation since reset
    for (int j = turnLog.size() - 2; j >= 0; j--) {
      if (i == turnLog.get(j).indexes[0] || i == turnLog.get(j).indexes[1] || i == turnLog.get(j).indexes[2] || i == turnLog.get(j).indexes[3]) {
        if (turnLog.get(j).dimension == 0) {
          if (turnLog.get(j).direction) {
            rotateX(PI / 2);
          } else {
            rotateX( - PI / 2);
          }
        } else if (turnLog.get(j).dimension == 1) {
          if (turnLog.get(j).direction) {
            rotateY(PI / 2);
          } else {
            rotateY( - PI / 2);
          }
        } else {
          if (turnLog.get(j).direction) {
            rotateZ(PI / 2);
          } else {
            rotateZ( - PI / 2);
          }
        }
      }
    }

    //actually draws the mini cube
    cube(i);

    //resets the rotation so that each of the mini cubes can be in positions independant of each other
    popMatrix();
  }

  //updates after the variables are used, so that they are always one frame behind during calculations
  xpos = mouseX;
  ypos = mouseY;

  //resets translations
  rotateZ( - zrotate);
  rotateX( - yrotate);
  rotateY( - xrotate);
  translate( - 960, -540, zoom);

  //progresses the animation clock if an animation is in progress, and indicates that the program is ready when it finishes
  if (clock > 0) {
    clock--;
  } else {
    ready = true;
  }

  if (settingsScreen) {

    //animation for settings screen opening

    if (Math.abs(xrotate) > TWO_PI * 3) {
      while (xrotate > TWO_PI * 2) {
        xrotate -= TWO_PI;
      }
      while (xrotate < TWO_PI * 2) {
        xrotate += TWO_PI;
      }
    }

    if (Math.abs(yrotate) > TWO_PI * 3) {
      while (yrotate > TWO_PI * 2) {
        yrotate -= TWO_PI;
      }
      while (yrotate < TWO_PI * 2) {
        yrotate += TWO_PI;
      }
    }

    if (Math.abs(zrotate) > TWO_PI * 3) {
      while (zrotate > TWO_PI * 2) {
        zrotate -= TWO_PI;
      }
      while (zrotate < TWO_PI * 2) {
        zrotate += TWO_PI;
      }
    }

    //apply a filter for settings screen
    if (theme > 0) {
      fill(20, 20, 20, 30);
    } else {
      fill(230, 230, 230, 30);
    }
    //zoom out for settings screen
    if (zoom < 356) {
      zoom += 16;
    }

    //the filter. its just a big rectangle
    rect( - 2, -2, width + 4, height + 4);
    
    //if the settings animation is done
    if (zoom == 356 && Math.abs(5.8 - xrotate) < 0.01 && Math.abs(5.8 - yrotate) < 0.01 && Math.abs(0.2 - zrotate) < 0.01) {

      //decide on font color based on theme
      stroke(0, 0, 0);
      fill(0, 0, 0);

      if (theme < 1) {
        fill(#ffffff);
      }

      //draw settings title
      textFont(arialSmaller);
      text("CONTROLS", 383, height / 12);
      text("HOW TO USE --->", width * 7/8, height / 12);
      text("(SWIPE)", width * 7/8, height / 12 + 30);
      
      textFont(arial);
      text("THE CUBE", width/2 , height / 8 + 25);

      //draw reset button except when its clicked
      if (mousePressed == false || mouseWithin(width / 2 - 48, height / 8 + 65, 95, 30) == false) {
        textFont(arialSmaller);
        text("RESET", width / 2, height / 8 + 80);
      }

      fill(0, 0, 0, 30);
      pushMatrix();
      translate(256, 0);
      strokeWeight(2.5);

      //draw settings screen buttons
      for (int i = 0; i < 6; i++) {
        translate(0, height / 8);
        rect(0, 0, 256, 64, 8);

        fill(#000000);

        if (theme < 1) {
          fill(#ffffff);
        }

        //text for buttons
        textFont(arialSmaller);
        text("Rotation " + (i + 1) + ": " + "  ", 128, 32);
        if (remapping[i] == false) {
          text(Character.toUpperCase(controls[i]), 200, 32);
        } else {
          text("?", 200, 32);
        }
        fill(0, 0, 0, 30);
      }
      translate(width - 768, height * -6 / 8);

      for (int i = 0; i < 6; i++) {
        translate(0, height / 8);
        //rect(0, 0, 256, 64, 8);
      }
      strokeWeight(4);
      popMatrix();
    } else {

      //settings screen animations
      xrotate -= ( - 5.8 + xrotate) / 16;
      yrotate -= ( - 5.8 + yrotate) / 16;
      zrotate -= ( - 0.2 + zrotate) / 16;

    }

    //reset zoom after setting screen is closed
  } else {
    if (zoom > 100) {
      zoom -= 16;
    }
  }
}

void keyPressed() {
  if (settingsScreen == false) {
    
    //toggle dark theme
    if (key == 't') {
      theme *= -1;
    }
    
    //reset viewing angle
    if (key == 'r') {
      xrotate = 5.8 + TWO_PI;
      yrotate = 5.8 + TWO_PI;
      zrotate = 0.2;
    }
    
    //reset the cube
    if (key == 'y') {
      turnLog.clear();
      clock = 0;
      ready = true;
      for (int i = 0; i < 8; i++) {
        xvalues[i] = xvaluesInitial[i];
        yvalues[i] = yvaluesInitial[i];
        zvalues[i] = zvaluesInitial[i];
      }
      xrotate = 5.8 + TWO_PI;
      yrotate = 5.8 + TWO_PI;
      zrotate = 0.2;
    }
    if (ready) {
      
      //keys for rotations
      
      if (key == controls[0]) {
        turnX(true, true);
      }
      if (key == Character.toUpperCase(controls[0])) {
        turnX(true, false);
      }
      if (key == controls[1]) {
        turnX(false, true);
      }
      if (key == Character.toUpperCase(controls[1])) {
        turnX(false, false);
      }

      if (key == controls[2]) {
        turnY(true, true);
      }
      if (key == Character.toUpperCase(controls[2])) {
        turnY(true, false);
      }
      if (key == controls[3]) {
        turnY(false, true);
      }
      if (key == Character.toUpperCase(controls[3])) {
        turnY(false, false);
      }
      if (key == controls[4]) {
        turnZ(true, true);
      }
      if (key == Character.toUpperCase(controls[4])) {
        turnZ(true, false);
      }
      if (key == controls[5]) {
        turnZ(false, true);
      }
      if (key == Character.toUpperCase(controls[5])) {
        turnZ(false, false);
      }

    }

  } else {
    
    //remap the keybinds in the settings menu
    for (int j = 0; j < 6; j++) {
      if (remapping[j]) {
        if (Character.isLetter(key) && key != controls[0] && key != controls[1] && key != controls[2] && key != controls[3] && key != controls[4] && key != controls[5]) {
          controls[j] = key;
        }
        remapping[j] = false;
      }
    }
  }
}

void mousePressed() {
  
  //click on a button in the settings screen to remap a key
  for (int i = 0; i < remapping.length; i++) {
    if (remapping[i]) {
      remapping[i] = flipper(remapping[i]);
    }
  }
  
  //settings screen icon
  if (mouseWithin(16, 16, 64, 64) && slidePos == 0) {
    if (settingsScreen && Math.abs(5.8 - xrotate) < 0.1 && Math.abs(5.8 - yrotate) < 0.1 && Math.abs(0.2 - zrotate) < 0.1) {
      xrotate = 5.8 + TWO_PI;
      yrotate = 5.8 + TWO_PI;
      zrotate = 0.2;

    }
    if (slidePos == 0 && sliding == false) {
      settingsScreen = flipper(settingsScreen);
    }
  } else if (settingsScreen && slidePos == 0) {
    if (mouseWithin(width / 2 - 48, height / 8 + 65, 95, 30)) {
      for (int i = 0; i < controls.length; i++) {
        controls[i] = controlsDefault[i];
        remapping[i] = false;
      }
      turnLog.clear();
      clock = 0;
      ready = true;
      for (int i = 0; i < 8; i++) {
        xvalues[i] = xvaluesInitial[i];
        yvalues[i] = yvaluesInitial[i];
        zvalues[i] = zvaluesInitial[i];
      }
      xrotate = 5.8 + TWO_PI;
      yrotate = 5.8 + TWO_PI;
      zrotate = 0.2;
    } else if (mouseWithin(width / 2 - 250, height / 2 - 200, 450, 450)) {
      if (settingsScreen && Math.abs(5.8 - xrotate) < 0.1 && Math.abs(5.8 - yrotate) < 0.1 && Math.abs(0.2 - zrotate) < 0.1) {
        xrotate = 5.8 + TWO_PI;
        yrotate = 5.8 + TWO_PI;
        zrotate = 0.2;
  
      }
      if (slidePos == 0 && sliding == false && settingsScreen) {
        settingsScreen = flipper(settingsScreen);
      }
      
    } else {
      for (int b = 0; b < 6; b++) {
        if (mouseWithin(256, 128 * (b + 1), 256, 64)) {
          for (int v = 0; v < 6; v++) {
            if (v != b) {
              remapping[v] = false;
            }
          }
          remapping[b] = flipper(remapping[b]);

          for (int v = 0; v < 6; v++) {}
        }
      }
    }
  }
}
void mouseReleased() {
  
  //decides which way to slide/snap the settings screen when the mouse button is released
  sliding = false;
  if (mouseXMod < -5 || (mouseXMod <= 0 && slide < -960 && slidePos == 0)) {
    slidePos = 1;
  } else if (mouseXMod > 5 || (slide > -960 && mouseXMod >= 0)) {
    slidePos = 0;
  }
}
