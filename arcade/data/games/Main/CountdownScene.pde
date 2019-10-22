class CountdownScene extends Scene {
  final private int count;

  private int text_size;
  private PImage backImage;
  private PImage backTitle;

  private int backImageAlpha;

  public CountdownScene() {
    super();
    backImage = loadImage("resources/MAIN.jpg");
    backTitle = loadImage("title_resources/select.png");
    background(0, 255);
    count = 3;
    text_size = 70;
    backImageAlpha = 255;
    noTint();
    image(backImage, 0, 0, width, height);
    tint(255, backImageAlpha);
    image(backTitle, 0, 0, width, height);
  }
  public void update() {
    super.update();
    countdown();
  }

  public void countdown() {
    noTint();
    image(backImage, 0, 0, width, height);
    tint(255, backImageAlpha);
    image(backTitle, 0, 0, width, height);
    // fill(0, backImageAlpha);
    // rect(0, 0, width, height);
    textSize(text_size);
    fill(#D0FFFF);
    textAlign(CENTER);
    text(count - elapsedTimeS, width/2, height/2);
    if (backImageAlpha >= 3) backImageAlpha -= 3;
    if (elapsedTimeS == count) {
      finishFlag = true;
      return;
    }
  }

  public void keyPressed() {}
  public void keyReleased() {}

  public boolean isFinish() { return finishFlag; }
}
