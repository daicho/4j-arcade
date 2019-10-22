class ResultScene extends Scene {
  PImage ui_img;       // 画面背景
  PImage a;
  PImage text_img[];
  
  float textLineX;
  float textLineY;
  final int TIME =12;
  final float INTERVAL = 13 + 23; 
  final float TEXTLINEX = 40; 
  final float TEXTLINEY = 120; 
  String dispResult[];
  int textAlpha[];
  int textAlphaNum;

  private Sound sound;
  private int startTime;

  public ResultScene(Sound sound) {
    text_img = new PImage[13];
    dispResult = new String[result.length];
    textAlpha = new int[result.length];
    textAlphaNum = 0;
    this.sound = sound;
    sound.playBGM(0);
    ui_img = loadImage("score/back.png");
    text_img[0] = loadImage("score/lenman.png");
    text_img[1] = loadImage("score/single.png");
    text_img[2] = loadImage("score/double.png");
    text_img[3] = loadImage("score/triple.png");
    text_img[4] = loadImage("score/tetris.png");
    text_img[5] = loadImage("score/tspin.png");
    text_img[6] = loadImage("score/tspinSingle.png");
    text_img[7] = loadImage("score/tspinDouble.png");
    text_img[8] = loadImage("score/tspinTriple.png");
    text_img[9] = loadImage("score/allclear.png");
    text_img[10] = loadImage("score/level.png");
    text_img[11] = loadImage("score/lines.png");
    text_img[12] = loadImage("score/playtime.png");
    textLineX = TEXTLINEX;
    textLineY = TEXTLINEY;
    changeTimeFormat();
    for(int i = 0;i < result.length;i++) {
      if(i != TIME)  dispResult[i] = String.valueOf(result[i]);
    }
    
    startTime = millis();
  }
  public void update() {
    drawBackground();
    dispText();
    sound.stopCheck();
    sound.bgmRoop();

    if (millis() - startTime >= 30000)
      exit();
  }

  private void drawBackground() {  
    image(ui_img, 0, 0, width, height);
  }
  
  private void dispText(){
    textLineX = TEXTLINEX;
    textLineY = TEXTLINEY;
    for(int i = 0;i < text_img.length;i++){
      if(i == 10) textLineY += INTERVAL - 10;
      dispAText(i,textLineX,textLineY,text_img[i].width,text_img[i].height);
      dispBText(i,width -textLineX,textLineY+13,text_img[i].width,text_img[i].height,255);
      textLineY += INTERVAL;
    }
    if(textAlpha[textAlphaNum] >= 255 && textAlphaNum < result.length -1) textAlphaNum++;
    if(textAlphaNum < result.length && textAlpha[textAlphaNum] <= 255)  textAlpha[textAlphaNum] +=7;
    dispScore();
  }
  
  
  private void dispAText(int img,float pointX,float pointY,float sizeWidth,float sizeHeight){
    tint(255,255,255,textAlpha[img]);
    image(text_img[img], pointX, pointY, sizeWidth, sizeHeight);
    noTint();
  }
  
  private void dispBText(int img,float pointX,float pointY,float sizeWidth,float sizeHeight,float alpha){
    textAlign(RIGHT);
    fill(#00ffff,textAlpha[img]);
    textSize(25);
    text(dispResult[img],pointX,pointY);
  }
  
  private void dispScore(){
    textAlign(CENTER);
    fill(#00ffff,textAlpha[result.length-1]);
    textSize(30);
    text(dispResult[result.length-1],width / 2,height - 142);
  }
  
  private void changeTimeFormat(){

    int time = result[TIME];    //time
    int minute = time / 60;
    int seconds = time % 60;
    String cMinute = String.valueOf(minute);
    String cSeconds = String.valueOf(seconds);
    if (cSeconds.length() == 1) cSeconds = "0"+ cSeconds;
    dispResult[TIME] = cMinute + ":" + cSeconds;
  }

  public void keyPressed() {}
  public void keyReleased() {
    if (key == 'n') finishFlag = true;
  }
  
  public boolean isFinish() { return finishFlag; }
}
