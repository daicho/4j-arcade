import java.io.IOException;

class TitleScene extends Scene {
  int select = -1;                   // 選択しているゲーム
  int state = -1;                    // how to playの切り替え用
  int count = 0;
  boolean selectFlag = false;
  boolean keyReleasedFlag = false;

  PImage back;   // 背景
  PImage start; 
  PImage how;
  PImage test;

  //Imageview view;

  final private int ENTER_GAME = 1;
  final private int HOW_TO_PLAY = 2;
  
  Imageview view;

  private Sound sound;

  public TitleScene(Sound sound) {
    super();
    view = new Imageview();
    this.sound = sound;
    //view = new Imageview();
    Input_title.setInputInterface(new MixInput());    // キーボード・アーケード同時対応
    //Input_title.setInputInterface(new KeyboardInput()); // キーボード
    back = loadImage("title_resources/select.png");
    start = loadImage("title_resources/start.png");
    how = loadImage("title_resources/how.png");
    test = loadImage("title_resources/test.png");
    this.sound.playBGM(0);
  }

  public void update() {
    super.update();
    sound.bgmRoop();
    if (Input_title.upPress()) {
      if (!view.isRunnning()) {
        if (select == -1)
          select = HOW_TO_PLAY;
        else
          select = 3 - select;
      }
    }

    if (Input_title.downPress()) {
      if (!view.isRunnning()) {
        if (select == -1)
          select = ENTER_GAME;
        else
          select = 3 - select;
      }
    }

    //HOW TO PLAYが押された場合
    if(select == HOW_TO_PLAY && Input_title.buttonA()) {
      selectFlag = true;
    }

    if(selectFlag){
      state = 0;
      if(keyReleasedFlag && Input_title.buttonA()){
        state = -1;
        selectFlag = false;
        keyReleasedFlag = false;
      }
    }

    imageMode(CENTER);
    image(back, width/2,height/2);

    if (select == ENTER_GAME) {
      fill(41,171,226,80);
    } else {
      noFill();
    }
    oval(width/2, 393, 210, 30);

    if (select == HOW_TO_PLAY) {
      fill(41,171,226, 80);
    } else {
      noFill();
    }
    oval(width/2, 492, 210, 30);
  
    image(start, width / 2, 394);
    image(how, width / 2, 493);  

    view.HowToPlay();
  }
  
  public void keyPressed() {
    super.keyPressed();

    switch (select) {
      case ENTER_GAME:
        if (Input_title.buttonA()) {
          finishFlag = true;
          sound.endingBgm();
        }
        break;
      case HOW_TO_PLAY:
        if (Input_title.buttonA()) view.pushSwitch();
        if (Input_title.right()) view.goFrontPage();
        else if (Input_title.left()) view.goBackPage();
        break;
    }
  }

  public void keyReleased() {
    super.keyReleased();
  }

  void oval(float x, float y, float w, float h) {
    rectMode(CENTER);
    stroke(41,171,226, 80);
    strokeWeight(1.5);

    rect(x, y, w, h, 15);
  }

  public boolean isFinish() { return finishFlag; }
}
