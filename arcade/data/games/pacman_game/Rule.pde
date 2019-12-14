// ルール説明画面
public class Rule implements Scene {
  private final FreeCharacter FreePacman = new FreeCharacter(new PVector(214, 247), 0, 8, "player");
  private final FreeCharacter[] FreeMonsters = {
    new FreeCharacter(new PVector(179, 370), 3, 1.6, "fujix"), 
    new FreeCharacter(new PVector(220, 370), 3, 1.6, "ito"), 
    new FreeCharacter(new PVector(260, 370), 3, 1.6, "arai"), 
    new FreeCharacter(new PVector(301, 370), 3, 1.6, "ohya")
  };
  boolean imageLoadFlag = false;  
  protected Timer lightTimer1 = new Timer(30); // 1秒タイマー
  protected Timer lightTimer2 = new Timer(15); // 0.5秒タイマー
  protected boolean lightAppear = true;
  protected Item bigPowerFood = new Item(new PVector(86, 547), "big_power_food");
  private boolean pressed;
  protected TitleBGM titlebgm; // BGM

  public Rule(int position) {
    this.titlebgm = new TitleBGM(minim, position);
  }

  public void update() {
    FreePacman.update();
    titlebgm.play();

    if (Input.anyButtonPress())
      pressed = true;

    if (pressed) {
      FreePacman.move();
      rectMode(CENTER);
      noStroke();
      fill(200, 240, 255);
      rect(FreePacman.getPosition().x - FreePacman.getSpeed() - 5, 247, 32, 35);
      if (FreePacman.getPosition().x >= SCREEN_SIZE.x + 16) {
        SceneManager.setScene(new Load());
        titlebgm.stop();
      }
    }
  }

  public void draw() {
    imageMode(CENTER);
    textAlign(CENTER, CENTER);

    if (imageLoadFlag == false) {
      PImage ruleImage = loadImage("images/rule.png");
      image(ruleImage, SCREEN_SIZE.x / 2, SCREEN_SIZE.y / 2);
      imageLoadFlag = true;
    }
    clearAfterimage();
    FreePacman.draw();
    for (FreeCharacter monster : FreeMonsters) {
      monster.draw();
      monster.update();
      monster.move();
      if (monster.getDirection() == 3 && monster.position.y >= 400)
        monster.setDirection(1);
      else if (monster.getDirection() == 1 && monster.position.y <= 345)
        monster.setDirection(3);
    }
    bigPowerFood.draw();
    bigPowerFood.update();
    if (lightAppear == true) {
      fill(0, 0, 159);
      textFont(font2, 40);
      text("ボタンをおして", SCREEN_SIZE.x / 2, 706);
      text("ゲームスタート！", SCREEN_SIZE.x / 2, 754);
    }
    if (lightTimer1.update())
      lightAppear = false;
    if (lightAppear == false) {
      if (lightTimer2.update())
        lightAppear = true;
    }
  }

  public void clearAfterimage() {
    rectMode(CENTER);
    noStroke();
    fill(200, 240, 255);
    // pacmanを消す
    rect(214, 247, 32, 32);
    // 敵を消す
    rect(SCREEN_SIZE.x / 2, 370, 160, 100);
    // powerFoodを消す
    rect(86, 547, 32, 32);
    // 文字を消す
    rect(SCREEN_SIZE.x / 2, 730, 300, 100);
  }
}

public class Load implements Scene {
  public void update() {
    SceneManager.setScene(new Game());
  }

  public void draw() {
    background(0);
    PImage loadingImage = loadImage("images/Loading.png");
    imageMode(CENTER);
    image(loadingImage, SCREEN_SIZE.x / 2, SCREEN_SIZE.y / 2);
    imageMode(CORNER);
  }
}
