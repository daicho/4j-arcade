import java.io.IOException; //<>//
import processing.io.*;

// 画面遷移
enum Scene {
  Insert, // コイン投入
  Zoom, // ズームイン
  Select  // ゲーム選択
}

Scene scene = Scene.Insert; // 現在のシーン

// コイン投入画面
final int PHOTO = 25; // フォトインタラプタのピン番号

PImage coinBack; // 背景
PImage coinStr;  // INSERT COINの文字
float amt = 0;   // アニメーションの進行
Timer zoomTimer = new Timer(30, false); // ズームするまでのタイマー

// ゲーム選択画面
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

PImage selectBack; // 背景
PImage frame;      // フレーム
PImage tetris;     // テトリスの文字
PImage pacman;     // パックマンの文字
PImage unagi;      // ウナギの文字

void setup() {
  // 画面設定
  //fullScreen(); // フルスクリーン
  size(480, 848); // ウィンドウ
  frameRate(30);  // フレームレート
  noCursor();     // マウスカーソル非表示

  // 入力設定
  //Input.setInputInterface(new MixInput());    // キーボード・アーケード同時対応
  Input.setInputInterface(new KeyboardInput()); // キーボード

  // コイン投入検知
  //GPIO.pinMode(PHOTO, GPIO.INPUT);
  //GPIO.attachInterrupt(PHOTO, this, "throwCoin", GPIO.RISING);

  // 実行ファイルパス
  exec_path[0] = dataPath("games/pacman_x64/pacman_game.exe");
  exec_path[1] = dataPath("games/pacman_x64/pacman_game.exe");
  exec_path[2] = dataPath("games/pacman_x64/pacman_game.exe");

  // デモ
  movies[0] = new Pacman();
  movies[1] = new Pacman();
  movies[2] = new Pacman();

  // 画像
  coinBack = loadImage("coin/back.png");
  coinStr = loadImage("coin/str.png");

  selectBack = loadImage("select/back.png");
  frame = loadImage("select/frame.png");
  tetris = loadImage("select/tetris.png");
  pacman = loadImage("select/pacman.png");
  unagi = loadImage("select/unagi.png");
}

void draw() {
  imageMode(CENTER);
  rectMode(CENTER);

  // デバッグ用
  if (keyPressed && key == ' ' && scene == Scene.Insert)
    scene = Scene.Zoom;

  if (scene == Scene.Insert) {
    // コイン投入画面
    image(coinBack, width / 2, height / 2);
    image(coinStr, width / 2, 518);
    fill(0, 0, 0);
    stroke(0, 0, 0);
    slot(width / 2, 424, 17, 147);
  } else {
    // ゲーム選択画面
    if (playMovie) {
      movies[select].draw();
      fill(0, 0, 0, 30);
      rect(width / 2, height / 2, width, height);

      if (movieTimer.update())
        playMovie = false;
    } else {
      image(selectBack, width / 2, height / 2);
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

    // ズームイン
    if (scene == Scene.Zoom) {
      PImage slotBack = coinBack.copy();
      slotBack.mask(slotMask(width / 2, 424, lerp(17, 600, amt), lerp(147, 3000, amt)));
      image(slotBack, width / 2, height / 2);
      fill(0, 0, 0, lerp(255, 0, amt));
      stroke(0, 0, 0);
      slot(width / 2, 424, lerp(17, 650, amt), lerp(147, 3000, amt));

      if (zoomTimer.update()) {
        amt += amt / 30 + 0.002;
        if (amt > 1) {
          amt = 0;
          zoomTimer.reset();
          scene = Scene.Select;
        }
      }
    }

    // 入力受付
    if (scene == Scene.Select) {
      // ゲーム実行
      if ((Input.buttonAPress() || Input.buttonBPress() || Input.buttonCPress()) && !reset && select != -1) {
        try {
          File file = new File(exec_path[select]);
          runtime.exec(exec_path[select], null, new File(file.getParent()));
        } 
        catch (IOException ex) {
          ex.printStackTrace();
        }

        reset = true;
        resetTimer.reset();
      }

      // リセット
      if (reset) {
        if (resetTimer.update()) {
          reset = false;
          scene = Scene.Insert;
          select = -1;
          selectChange = false;
          playMovie = false;
        }

        return;
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
    }
  }
}

// コイン投入
void throwCoin(int pin) {
  if (scene == Scene.Insert)
    scene = Scene.Zoom;
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

// コイン投入口を描画
void slot(float x, float y, float w, float h) {
  rectMode(CENTER);
  strokeWeight((w + h) * 0.035);
  rect(x, y, w, h, (w + h) * 0.03);
}

// マスク用コイン投入口を作成
int[] slotMask(float x, float y, float w, float h) {
  PGraphics graphics = createGraphics(width, height);
  graphics.beginDraw();

  graphics.rectMode(CENTER);
  graphics.noStroke();
  graphics.fill(0);
  graphics.background(255);
  graphics.rect(x, y, w, h, (w + h) * 0.03);

  graphics.endDraw();
  return graphics.pixels;
}
