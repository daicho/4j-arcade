// リザルト画面
public class Result implements Scene {
  protected int score; // スコア

  public Result(int score) {
    this.score = score;
    // ハイスコア更新処理
    if (Record.getRanking(-1) < this.score) {
      Record.setRanking(this.score);
      Record.saveRanking();
    }
  }

  public void update() {
    if (Input.buttonAPress())
      SceneManager.setScene(new Title());
  }

  public void draw() {
    background(0);
    fill(255);
    textAlign(CENTER, CENTER);
    textFont(font, 20);
    text("Result\nScore:" + score + "\nPress 'Z' Key", screenSize.x / 2, screenSize.y / 2);
  }
}
