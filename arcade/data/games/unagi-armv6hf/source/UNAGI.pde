/*
  ====================================================
  File name: UNAGI.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/

import ddf.minim.*;

private SceneController sc;

private Minim minim;

void setup() {
  fullScreen();
  noCursor();
  // size(480, 848);
  frameRate(12);
  noStroke();
  textFont(createFont("PixelMplus10-Regular.ttf", 20, false));
  
  minim = new Minim(this);
  
  sc = new SceneController(
    new IGPIO(),
    // new IKey(),
    new STitle()
    // new SHowto()
    // new SGame(0, 2, new LinkedList<SOUnagi>())
    // new SRanking("TEST", 0, null)
    // new SName(100, null)
    // new SStaff()
  );
}

void draw() {
  if (sc.action()) {
    exit();
  }
}

void stop() {
  minim.stop();
}
AudioPlayer __load__(String s) {
  return minim.loadFile(s);
}
