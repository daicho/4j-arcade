// タイトル画面
public class Title implements Scene {
  public void update() {
    if (Input.buttonAPress())
      SceneManager.setScene(new Stage("original"));
  }

  public void draw() {
    background(0);
    fill(255);
    textAlign(CENTER, CENTER);
    textFont(font, 20);
    text("Title\nPress 'Z' Key", screenSize.x / 2, 150);
    text("Ranking", screenSize.x / 2, 200);
    for (int i = 0; i < 10; i++)
      text(Record.getRanking(i + 1), screenSize.x / 2, 230 + i * 20);
  }
}
