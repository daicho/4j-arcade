import java.io.IOException;

// 実行ファイルのパス
final String[] EXEC_PATHS = {
  dataPath("games/pacman_x64/pacman_game.exe"),
  dataPath("games/pacman_x64/pacman_game.exe"),
  dataPath("games/pacman_x64/pacman_game.exe")
};

Runtime runtime = Runtime.getRuntime(); // 実行するやつ

int select = 0;                    // 選択しているゲーム
int prevSelect = select;           // 前フレームの選択
boolean selectChange = false;      // 選択を切り替えたか
Timer selectTimer = new Timer(30); // 選択してからのタイマー

Demo[] movies;                     // 映像
int curMovie = select;             // 再生している映像
Timer movieTimer = new Timer(300); // ループ用タイマー

void setup() {
  // 画面設定
  //fullScreen(); // フルスクリーン
  size(480, 848); // ウィンドウ
  frameRate(30);  // フレームレート

  // 入力設定
  //Input.setInputInterface(new MixInput());    // キーボード・アーケード同時対応
  Input.setInputInterface(new KeyboardInput()); // キーボード
  
  // デモ
  movies = new Demo[3];
  movies[0] = new Pacman();
  movies[1] = new Pacman();
  movies[2] = new Pacman(); //<>// //<>//
}

void draw() {
  textAlign(LEFT, CENTER);
  rectMode(CENTER);

  // ゲーム実行
  if (Input.buttonAPress()) {
    try {
      File file = new File(EXEC_PATHS[select]);
      runtime.exec(EXEC_PATHS[select], null, new File(file.getParent()));
    } catch (IOException ex) {
      ex.printStackTrace();
    }
  }

  // ゲーム選択
  if (Input.upPress())
    select = constrain(select - 1, 0, EXEC_PATHS.length - 1);

  if (Input.downPress())
    select = constrain(select + 1, 0, EXEC_PATHS.length - 1);

  if (select != prevSelect) {
    selectChange = true;
    prevSelect = select;
    selectTimer.reset();
  }

  // 動画再生
  if (selectChange) {
    if (selectTimer.update()) {
      for (Demo movie : movies)
        movie.reset();

      curMovie = select;
      movieTimer.reset();
      selectChange = false;
    }
  }

  if (movieTimer.update())
    movies[curMovie].reset();
  movies[curMovie].draw();

  fill(0, 0, 0);
  rect(width / 2, height / 2, 150, 100);
  fill(255, 255, 255);
  text("→", width / 2 - 30, height / 2 + (select - 1) * 30);
  text("テトリス", width / 2, height / 2 - 30);
  text("パックマン", width / 2, height / 2);
  text("スネーク", width / 2, height / 2 + 30);
}
