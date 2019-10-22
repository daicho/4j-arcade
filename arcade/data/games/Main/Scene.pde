class Scene {
  Sound sound;
  boolean finishFlag;
  private int startTimeMS;
  protected int elapsedTimeS;
  protected int elapsedTimeMS;
  Scene() {
    finishFlag = false;
    elapsedTimeMS = 0;
    startTimeMS = millis();
    imageMode(CORNER);
    rectMode(CORNER);
  }
  public void update() {
    elapsedTimeMS = millis() - startTimeMS;
    elapsedTimeS = elapsedTimeMS / 1000;
  }
  public void keyPressed() {}
  public void keyReleased() {}
  public boolean isFinish() { return finishFlag; }
}