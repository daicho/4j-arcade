class ViewedText {
  private int startTime;
  private String text;
  ViewedText(String text) {
    startTime = millis();
    this.text = text;
  }
  public boolean isFinish() {
    if (millis() - startTime < 3000) return false;
    else return true;
  }
  public String getText() {
    return this.text;
  }
}