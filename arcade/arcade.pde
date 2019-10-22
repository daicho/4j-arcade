import java.io.IOException; //<>//
import processing.io.*;
import ddf.minim.*;

// 画面遷移
enum Scene {
  Insert, // コイン投入
  Zoom,   // ズームイン
  Select  // ゲーム選択
}

Scene scene = Scene.Insert; // 現在のシーン
Minim minim;

// コイン投入画面
final int PHOTO = 25; // フォトインタラプタのピン番号

boolean zoom = false; // ズームしているか
float amt = 0;        // アニメーションの進行
Timer zoomTimer = new Timer(90); // ズームするまでのタイマー

PImage coinBack; // 背景
PImage coinStr;  // INSERT COINの文字

AudioPlayer coinSE; // コイン投入音
AudioPlayer zoomSE; // ズーム音

// ゲーム選択画面
String[] exec_commands = new String[3]; // 実行コマンド
String[] exec_dirs = new String[3];     // 実行時作業フォルダ
Runtime runtime = Runtime.getRuntime(); // 実行するやつ

int select = -1;                   // 選択しているゲーム
boolean selectChange = false;      // 選択を切り替えたか
Timer selectTimer = new Timer(30); // 選択してからのタイマー

Demo movie;                        // 映像
boolean playMovie = false;         // 再生中か
Timer movieTimer = new Timer(300); // 映像用タイマー

boolean reset = false;             // リセットするか
Timer resetTimer = new Timer(900); // リセット用タイマー

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

  // 実行コマンド
  exec_commands[0] = "processing-java --sketch=" + dataPath("games/Main/") + " --run";
  exec_commands[1] = "bash" + dataPath("games/pacman-armv6hf/pacman_game");
  exec_commands[2] = "bash" + dataPath("games/unagi-armv6hf/UNAGI");

  // 実行時作業フォルダ
  exec_dirs[0] = dataPath("games/Main/");
  exec_dirs[1] = dataPath("games/pacman-armv6hf/");
  exec_dirs[2] = dataPath("games/unagi-armv6hf/");

  // 画像
  coinBack = loadImage("coin/back.png");
  coinStr = loadImage("coin/str.png");

  selectBack = loadImage("select/back.png");
  frame = loadImage("select/frame.png");
  tetris = loadImage("select/tetris.png");
  pacman = loadImage("select/pacman.png");
  unagi = loadImage("select/unagi.png");

  // 音声
  minim = new Minim(this);
  coinSE = minim.loadFile("coin/coin.mp3");
  zoomSE = minim.loadFile("coin/zoom.mp3");
}

void draw() {
  //println(frameRate);

  // デバッグ用
  if (keyPressed && key == ' ' && scene == Scene.Insert) {
    coinSE.play();
    scene = Scene.Zoom;
  }

  imageMode(CENTER);
  rectMode(CENTER);

  // リセット
  if (reset) {
    if (resetTimer.update()) {
      reset = false;
      scene = Scene.Insert;
      select = -1;
      selectChange = false;
      playMovie = false;
      coinSE.rewind();
      zoomSE.rewind();
    }

    return;
  }

  // ゲーム選択画面描画
  if (scene == Scene.Zoom || scene == Scene.Select) {
    // ゲーム選択画面
    if (playMovie) {
      rectMode(CORNER);
      ellipseMode(CENTER);
      imageMode(CORNER);
      movie.draw();

      imageMode(CENTER);
      rectMode(CENTER);
      fill(0, 0, 0, 30);
      rect(width / 2, height / 2, width, height);

      if (movieTimer.update())
        playMovie = false;
    } else {
      image(selectBack, width / 2, height / 2);
    }

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

  switch (scene) {
  case Insert:
    // コイン投入画面
    background(0, 169, 157);
    image(coinStr, width / 2, 518);
    fill(0, 0, 0);
    stroke(0, 0, 0);
    slot(width / 2, height / 2, 17, 147);

    break;

  case Zoom:
    // ズームイン
    fill(0, 169, 157);
    slotMask(width / 2, height / 2, lerp(17, 650, amt), lerp(147, 3000, amt));
    fill(0, 0, 0, lerp(255, 0, amt));
    stroke(0, 0, 0);
    slot(width / 2, height / 2, lerp(17, 650, amt), lerp(147, 3000, amt));

    if (zoomTimer.update()) {
      zoomSE.play();
      zoom = true;
    }

    if (zoom) {
      amt += amt / 20 + 0.001;
      if (amt > 1) {
        amt = 0;
        zoom = false;
        zoomTimer.reset();
        scene = Scene.Select;
      }
    }

    break;

  case Select:
    // ゲーム実行
    if ((Input.buttonAPress() || Input.buttonBPress() || Input.buttonCPress()) && !reset && select != -1) {
      try {
        File file = new File(exec_dirs[select]);
        runtime.exec(exec_commands[select], null, file);
      } catch (IOException ex) {
        ex.printStackTrace();
      }

      reset = true;
      resetTimer.reset();
      break;
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
        switch (select) {
        case 0:
          movie = new Tetris();
          break;
          
        case 1:
          movie = new Pacman();
          break;
          
        case 2:
          movie = new UNAGI();
          break;
        }

        movieTimer.reset();
        selectChange = false;
        playMovie = true;
      }
    }

    break;
  }
}

// コイン投入
void throwCoin(int pin) {
  if (scene == Scene.Insert) {
    coinSE.play();
    scene = Scene.Zoom;
  }
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
  float sw = (w + h) * 0.035;

  rectMode(CENTER);
  strokeWeight(sw);
  
  if (h - sw <= height)
    rect(x, y, w, h);
  else
    rect(x, y, w, height + sw);
}

// 穴あきコイン投入口を描画
void slotMask(float x, float y, float w, float h) {
  rectMode(CENTER);
  noStroke();

  beginShape();
    vertex(0, 0);
    vertex(width, 0);
    vertex(width, height);
    vertex(0, height);

    beginContour();
      if (h <= height) {
        vertex(x - w / 2, y - h / 2);
        vertex(x - w / 2, y + h / 2);
        vertex(x + w / 2, y + h / 2);
        vertex(x + w / 2, y - h / 2);
      } else {
        vertex(x - w / 2, 0);
        vertex(x - w / 2, height);
        vertex(x + w / 2, height);
        vertex(x + w / 2, 0);
      }
    endContour();
  endShape(CLOSE);
}
