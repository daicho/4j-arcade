public PVector screenSize = new PVector(448, 496);
public PFont font;
public Minim minim;

void setup() {
  fullScreen();

  font = loadFont("fonts/NuAnkoMochi-Reg-20.vlw"); // フォント
  minim = new Minim(this); // サウンド

  // ハイスコアをロード
  String dataName = "ranking.txt";
  Record.setFilePath(dataPath(dataName));
  Record.loadRanking();

  Input.setInputInterface(new KeyboardInput()); // 入力設定
  SceneManager.setScene(new Title()); // タイトル画面をロード
}

void draw() {
  // 座標系設定
  float windowScale = 1;
  //float windowScale = displayHeight / screenSize.y; ←激重
  //scale(windowScale);
  translate((displayWidth / windowScale - screenSize.x) / 2, (displayHeight / windowScale - screenSize.y) / 2);

  // 画面描画
  SceneManager.update();
  SceneManager.draw();
}
