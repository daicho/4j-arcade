import java.io.IOException; //<>//

String[] exec_path = new String[3];     // 実行ファイルパス
Runtime runtime = Runtime.getRuntime(); // 実行するやつ

int select = -1;                   // 選択しているゲーム
boolean selectChange = false;      // 選択を切り替えたか
Timer selectTimer = new Timer(30); // 選択してからのタイマー

Demo[] movies = new Demo[3];       // 映像
boolean playMovie = false;         // 再生中か
Timer movieTimer = new Timer(300); // 映像用タイマー

boolean reset = false;             // リセットするか
Timer resetTimer = new Timer(150); // リセット用タイマー

PImage back;   // 背景
PImage frame;  // フレーム
PImage tetris; // テトリスの文字
PImage pacman; // パックマンの文字
PImage unagi;  // ウナギの文字

void setup() {
  // 画面設定
  //fullScreen(); // フルスクリーン
  size(480, 848); // ウィンドウ
  frameRate(30);  // フレームレート
  noCursor();     // マウスカーソル非表示

  // 入力設定
  //Input.setInputInterface(new MixInput());    // キーボード・アーケード同時対応
  Input.setInputInterface(new KeyboardInput()); // キーボード

  // 実行ファイルパス
  exec_path[0] = dataPath("games/pacman_x64/pacman_game.exe");
  exec_path[1] = dataPath("games/pacman_x64/pacman_game.exe");
  exec_path[2] = dataPath("games/pacman_x64/pacman_game.exe");

  // デモ
  movies[0] = new Pacman();
  movies[1] = new Pacman();
  movies[2] = new Pacman();

  // 画像
  back = loadImage("select/back.png");
  frame = loadImage("select/frame.png");
  tetris = loadImage("select/tetris.png");
  pacman = loadImage("select/pacman.png");
  unagi = loadImage("select/unagi.png");
}

void draw() {
  // ゲーム実行
  if (Input.buttonAPress() && select != -1) {
    try {
      File file = new File(exec_path[select]);
      runtime.exec(exec_path[select], null, new File(file.getParent()));
    } catch (IOException ex) {
      ex.printStackTrace();
    }

    reset = true;
    resetTimer.reset();
  }

  if (reset && resetTimer.update()) {
    reset = false;
    select = -1;
    selectChange = false;
    playMovie = false;
  }

  // ゲーム選択
  if (Input.upPress()) {
    selectChange = true;
    playMovie = false;
    selectTimer.reset();

    if (select == -1)
      select = 2;
    else
      select = (select + 2) % 3;
  }

  if (Input.downPress()) {
    selectChange = true;
    playMovie = false;
    selectTimer.reset();

    if (select == -1)
      select = 0;
    else
      select = (select + 4) % 3;
  }

  // 動画再生
  if (selectChange) {
    if (selectTimer.update()) {
      for (Demo movie : movies)
        movie.reset();

      movieTimer.reset();
      selectChange = false;
      playMovie = true;
    }
  }

  // 描画
  if (playMovie) {
    movies[select].draw();
    if (movieTimer.update())
      playMovie = false;
  } else {
    imageMode(CENTER);
    image(back, width / 2, height / 2);
  }

  image(frame, width / 2, height / 2); // フレーム

  // テトリス
  if (select == 0)
    fill(195, 13, 35);
  else if (playMovie)
    fill(62, 58, 57);
  else
    fill(255, 255, 255);
  oval(width / 2, 202, tetris.width, 40);

  // パックマン
  if (select == 1)
    fill(195, 13, 35);
  else if (playMovie)
    fill(62, 58, 57);
  else
    fill(255, 255, 255);
  oval(width / 2, 454, pacman.width, 40);

  // ウナギ
  if (select == 2)
    fill(195, 13, 35);
  else if (playMovie)
    fill(62, 58, 57);
  else
    fill(255, 255, 255);
  oval(width / 2, 706, unagi.width, 40);

  image(tetris, width / 2, 202);
  image(pacman, width / 2, 454);
  image(unagi, width / 2, 706);
  image(frame, width / 2, height / 2);
}

// 楕円を描画
void oval(float x, float y, float w, float h) {
  rectMode(CENTER);
  ellipseMode(CENTER);
  noStroke();

  rect(x, y, w, h);
  ellipse(x - w / 2, y, h, h);
  ellipse(x + w / 2, y, h, h);
}
