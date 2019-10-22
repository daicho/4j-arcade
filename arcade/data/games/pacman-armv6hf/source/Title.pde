// タイトル画面
public class Title implements Scene {
  protected PImage logoImage = loadImage("images/logo.png");
  protected PImage pressButonImage = loadImage("images/press_button.png");
  protected PImage copyrightImage = loadImage("images/copyright.png");
  protected Timer lightTimer1 = new Timer(30); // タイマー
  protected Timer lightTimer2 = new Timer(15); // タイマー
  protected boolean lightAppear = true;
  protected boolean jpEn = false;

  protected Timer startTimer = new Timer(10); // タイマー
  protected boolean startAppear = true;
  protected int startCount = 0;
  protected TitleBGM titlebgm = new TitleBGM(minim); // BGM
  protected int position; // BGMの再生位置

  private final FreeCharacter[] freeCharacters = {
    new FreeCharacter(new PVector(-20, SCREEN_SIZE.y * 0.08 - 17), 0, 2.3, "player"), 
    new FreeCharacter(new PVector(-20, SCREEN_SIZE.y * 0.08 - 17), 0, 2.3, "fujix"), 
    new FreeCharacter(new PVector(-20, SCREEN_SIZE.y * 0.08 - 17), 0, 2.3, "ito"), 
    new FreeCharacter(new PVector(-20, SCREEN_SIZE.y * 0.08 - 17), 0, 2.3, "arai"), 
    new FreeCharacter(new PVector(-20, SCREEN_SIZE.y * 0.08 - 17), 0, 2.3, "ohya")
  };

  public void update() {
    titlebgm.play();

    if (Input.anyButtonPress()) {
      position = titlebgm.getPos();
      titlebgm.stop();
      SceneManager.setScene(new Rule(position));
    }
  }

  public void draw() {
    background(200, 240, 255);
    noStroke();
    rectMode(CENTER);
    imageMode(CENTER);
    textAlign(CENTER, CENTER);

    image(logoImage, SCREEN_SIZE.x / 2, 167);

    // タイマー
    if (lightAppear == true) {
      fill(0);
      textFont(font2, 40);
      if (jpEn == false) {
        text("ボタンをおしてね!", SCREEN_SIZE.x / 2, 330);
      } else {
        image(pressButonImage, SCREEN_SIZE.x / 2, 335);
      }
      if (lightTimer1.update()) {
        lightAppear = false;
        jpEn = !jpEn;
      }
    }

    if (lightAppear == false) {
      if (lightTimer2.update())
        lightAppear = true;
    }

    fill(0, 0, 159);
    textFont(font2, 22.5);
    text("ランキング", SCREEN_SIZE.x * 0.35, 395);
    text("スコア", SCREEN_SIZE.x * 0.65, 395);
    fill(0);
    rect(SCREEN_SIZE.x / 2, 417.5, SCREEN_SIZE.x * 0.7, 1);
    textFont(font2, 30);
    for (int i = 0; i < 10; i++) {
      text(i + 1, SCREEN_SIZE.x * 0.35, 430 + i * 30);
      text(Record.getRanking(i + 1), SCREEN_SIZE.x * 0.65, 430 + i * 30);
      rect(SCREEN_SIZE.x / 2, 447.5 + i * 30, SCREEN_SIZE.x * 0.7, 1);
    }
    image(copyrightImage, SCREEN_SIZE.x / 2, 790);

    for (int i = 0; i < freeCharacters.length; i++) {
      if (startCount > i) {
        freeCharacters[i].move();
        freeCharacters[i].update();
        freeCharacters[i].draw();
        if (freeCharacters[i].getDirection() == 0 && freeCharacters[i].position.x >= SCREEN_SIZE.x / 2 + logoImage.width / 2 + 15) {
          freeCharacters[i].setDirection(3);
        } else if (freeCharacters[i].getDirection() == 3 && freeCharacters[i].position.y >= SCREEN_SIZE.y * 0.08 + logoImage.height + 16) {
          freeCharacters[i].setDirection(2);
        } else if (freeCharacters[i].getDirection() == 2 && freeCharacters[i].position.x <= SCREEN_SIZE.x / 2 - logoImage.width / 2 - 15) {
          freeCharacters[i].setDirection(1);
        } else if (freeCharacters[i].getDirection() == 1 && freeCharacters[i].position.y <= SCREEN_SIZE.y * 0.08 - 15) {
          freeCharacters[i].setDirection(0);
        }
      }
    }


    // タイマー
    if (startAppear == true) {
      if (startTimer.update()) {
        startAppear = false;
        startCount ++;
      }
    }

    if (startAppear == false) {
      if (startTimer.update())
        startAppear = true;
    }
  }
}
