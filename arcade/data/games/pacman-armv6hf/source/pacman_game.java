import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.io.*; 
import ddf.minim.*; 
import ddf.minim.ugens.*; 
import java.util.Iterator; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class pacman_game extends PApplet {

public final PVector SCREEN_SIZE = new PVector(480, 848); // ゲーム画面サイズ

public PFont font;  // フォント
public PFont font2; // フォント
public Minim minim; // サウンド

public void setup() {
  // 画面設定
   // フルスクリーン
  //size(480, 848); // ウィンドウ
  frameRate(30);  // フレームレート
  noCursor();     // マウスカーソル非表示

  // 入力設定
  Input.setInputInterface(new MixInput());    // キーボード・アーケード同時対応
  //Input.setInputInterface(new KeyboardInput()); // キーボード

  // 読み込み
  font = createFont("fonts/NuAnkoMochi-Reg.otf", 10);
  font2 = createFont("fonts/NuKinakoMochi-Reg.otf", 10);
  minim = new Minim(this);

  // ランキング読み込み
  Record.setFilePath(dataPath("ranking.txt"));

  // タイトル画面をロード
  SceneManager.setScene(new Title());
}

public void draw() {
  // 画面描画
  SceneManager.update();
  SceneManager.draw();
}
// キャラクターの基底クラス
public abstract class Character extends GameObject {
  protected PVector startPosition; // 初期地点
  protected int direction;         // 向き (0:右 1:上 2:左 3:下)
  protected int nextDirection;     // 次に進む方向
  protected int startDirection;    // 初期方向
  protected float speed;           // 速さ [px/f]
  protected Animation[] animations = new Animation[4]; // アニメーション

  public Character(PVector position, int direction, float speed, String characterName) {
    super(position);

    this.startPosition = position.copy();
    this.direction = direction;
    this.nextDirection = direction;
    this.startDirection = direction;
    this.speed = speed;

    // アニメーション
    for (int i = 0; i < 4; i++)
      animations[i] = new Animation("images/" + characterName + "-" + i);
    this.size = animations[0].getSize();
  }

  public int getDirection() {
    return this.direction;
  }

  public void setDirection(int direction) {
    this.direction = direction;
  }

  public int getNextDirection() {
    return this.nextDirection;
  }

  public void setNextDirection(int nextDirection) {
    this.nextDirection = nextDirection;
  }

  public float getSpeed() {
    return this.speed;
  }

  public void setSpeed(float speed) {
    this.speed = speed;
  }

  // 特定の方向の単位ベクトル
  protected PVector getDirectionVector(int direction) {
    return new PVector(cos(direction * PI / 2), -sin(direction * PI / 2));
  }

  // 移動
  public void move(Map map) {
    // 曲がれたら曲がる、曲がれなかったら直進
    PVector nextMove = canMove(map, nextDirection);
    if (nextMove.mag() != 0)
      direction = nextDirection;
    else
      nextMove = canMove(map, direction);
    position.add(nextMove);

    // 道の真ん中を進むように調整
    switch (direction) {
    case 0:
    case 2:
      position.y = round(position.y);
      break;

    case 1:
    case 3:
      position.x = round(position.x);
      break;
    }

    // ワープトンネル
    PVector mapSize = map.getSize();

    switch(direction) {
    case 0: // 右
      if (position.x >= mapSize.x)
        position.x -= mapSize.x;
      break;

    case 1: // 上
      if (position.y < 0)
        position.y += mapSize.y;
      break;

    case 2: // 左
      if (position.x < 0)
        position.x += mapSize.x;
      break;

    case 3: // 下
      if (position.y >= mapSize.y)
        position.y -= mapSize.y;
      break;
    }
  }

  // 特定の方向へ移動できるか
  public PVector canMove(Map map, int aimDirection) {
    float curSpeed = speed;
    boolean turnFlag = false;
    PVector result = new PVector(0, 0);

    for (float t = 0; t < curSpeed; t++) {
      float moveDistance;
      PVector moveVector;
      MapObject mapObject;

      // 1マスずつ進みながらチェック
      if (t + 1 <= PApplet.parseInt(curSpeed) || !turnFlag && (aimDirection + direction) % 2 == 1)
        moveDistance = 1;
      else
        moveDistance = curSpeed - t;

      // 進みたい方向に進んでみる
      moveVector = getDirectionVector(aimDirection);
      moveVector.mult(moveDistance);
      result.add(moveVector);

      mapObject = map.getObject(PVector.add(position, result));
      if (mapObject != MapObject.Wall && mapObject != MapObject.MonsterDoor) {
        turnFlag = true;
        if ((aimDirection + direction) % 2 == 1)
          curSpeed = speed * 2;
      } else {
        result.sub(moveVector);

        if (turnFlag)
          break;

        // 壁があったら直進する
        moveVector = getDirectionVector(direction);
        moveVector.mult(moveDistance);
        result.add(moveVector);

        mapObject = map.getObject(PVector.add(position, result));
        if (mapObject == MapObject.Wall || mapObject == MapObject.MonsterDoor)
          break;
      }
    }

    if (turnFlag)
      return result;
    else
      return new PVector(0, 0);
  }

  // リセット
  public void reset() {
    position = startPosition.copy();
    direction = startDirection;
    nextDirection = direction;
    for (Animation animetion : animations)
      animetion.reset();
  }

  // アニメーションの更新
  protected void animationUpdate(Animation animation, Map map) {
    if (canMove(map, direction).mag() != 0)
      animation.update();
  }

  // 更新
  public void update(Map map) {
    animationUpdate(animations[direction], map);
  }

  // 画面描画
  public void draw() {
    imageMode(CENTER);
    image(animations[direction].getImage(), position.x, position.y);
  }
}

// 自由に動けるキャラクター
public class FreeCharacter extends GameObject {
  protected int direction; // 向き (0:右 1:上 2:左 3:下)
  protected float speed;   // 速さ [px/f]
  protected Animation[] animations = new Animation[4]; // アニメーション

  public FreeCharacter(PVector position, int direction, float speed, String characterName) {
    super(position);

    this.direction = direction;
    this.speed = speed;

    // アニメーション
    for (int i = 0; i < 4; i++)
      animations[i] = new Animation("images/" + characterName + "-" + i);
    this.size = animations[0].getSize();
  }

  public int getDirection() {
    return this.direction;
  }

  public void setDirection(int direction) {
    this.direction = direction;
  }

  public float getSpeed() {
    return this.speed;
  }

  public void setSpeed(float speed) {
    this.speed = speed;
  }

  // 特定の方向の単位ベクトル
  protected PVector getDirectionVector(int direction) {
    switch (direction) {
    case 0: // 右
      return new PVector(1, 0);

    case 1: // 上
      return new PVector(0, -1);

    case 2: // 左
      return new PVector(-1, 0);

    case 3: // 下
      return new PVector(0, 1);

    default:
      return new PVector(0, 0);
    }
  }

  // 移動
  public void move() {
    PVector nextMove = getDirectionVector(direction);
    nextMove.mult(speed);
    position.add(nextMove);
  }

  // 更新
  public void update() {
    animations[direction].update();
  }

  // 画面描画
  public void draw() {
    imageMode(CENTER);
    image(animations[direction].getImage(), position.x, position.y);
  }
}
// プレイヤー (パックマン)
public class Pacman extends Character {
  protected boolean kakusei = false;          // 覚醒しているか
  protected boolean kakuseiLimit = false;     // 覚醒が終わりそうか
  protected boolean die = false;              // やられたか
  protected boolean clear = false;            // クリアしたか
  protected boolean curImage = false;         // 表示画像 (false:通常 true:覚醒)
  protected Timer switchTimer = new Timer(5); // 画像切り替え用タイマー
  protected Animation[] kakuseiAnimations = new Animation[4]; // 覚醒時のアニメーション
  protected Animation dieAnimation;   // 死亡時のアニメーション
  protected Animation clearAnimation; // クリア時のアニメーション

  public Pacman(PVector position, int direction, float speed) {
    super(position, direction, speed, "player");

    // アニメーション
    for (int i = 0; i < 4; i++)
      this.kakuseiAnimations[i] = new Animation("images/player-kakusei-" + i);
    this.dieAnimation = new Animation("images/player-die");
    this.clearAnimation = new Animation("images/player-clear");
  }

  public boolean getKakusei() {
    return this.kakusei;
  }

  public void setKakusei(boolean kakusei) {
    this.kakusei = kakusei;

    if (kakusei) {
      kakuseiLimit = false;
      curImage = false;
      switchTimer.reset();

      for (int i = 0; i < 4; i++) {
        animations[i].reset();
        kakuseiAnimations[i].reset();
      }
    }
  }

  public boolean getKakuseiLimit() {
    return this.kakuseiLimit;
  }

  public void setKakuseiLimit(boolean kakuseiLimit) {
    this.kakuseiLimit = kakuseiLimit;
  }

  public boolean getDie() {
    return this.die;
  }

  public void setDie(boolean die) {
    this.die = die;
    if (die)
      dieAnimation.reset();
  }

  public boolean getClear() {
    return this.clear;
  }

  public void setClear(boolean clear) {
    this.clear = clear;
    if (clear)
      clearAnimation.reset();
  }

  // リセット
  public void reset() {
    super.reset();
    kakusei = false;
    die = false;
    clear = false;
  }

  // 更新
  public void update(Map map) {
    animationUpdate(animations[direction], map);

    if (kakusei) {
      if (kakuseiLimit && switchTimer.update())
        curImage = !curImage;
      animationUpdate(kakuseiAnimations[direction], map);
    }

    if (die)
      dieAnimation.update();

    if (clear)
      clearAnimation.update();
  }

  // 画面描画
  public void draw() {
    imageMode(CENTER);

    if (die)
      image(dieAnimation.getImage(), position.x, position.y);
    else if (clear)
      image(clearAnimation.getImage(), position.x, position.y);
    else if (kakusei && (!kakuseiLimit || curImage))
      image(kakuseiAnimations[direction].getImage(), position.x, position.y);
    else
      image(animations[direction].getImage(), position.x, position.y);
  }
}

// 藤澤 (アカベエ)
public class Akabei extends Monster {
  public Akabei(PVector position, int direction, HashMap<MonsterSpeed, Float> speeds) {
    super(position, direction, speeds, "fujix");
  }

  // 進む方向を決定する
  public void decideDirection(Stage stage) {
    super.decideDirection(stage);
    PVector aimPoint;

    if (status == MonsterStatus.Active) {
      switch (mode) {
      case Rest:
        // 休息中は右上を徘徊
        aimPoint = new PVector(random(stage.map.size.x / 2, stage.map.size.x), random(0, stage.map.size.y / 2));
        nextDirection = getAimDirection(stage.map, aimPoint);
        break;

      case Chase:
        // パックマンのいる地点を目指す
        nextDirection = getAimDirection(stage.map, stage.pacman.getPosition());
        break;

      default:
        break;
      }
    }
  }
}

// 伊藤 (アオスケ)
public class Aosuke extends Monster {
  public Aosuke(PVector position, int direction, HashMap<MonsterSpeed, Float> speeds) {
    super(position, direction, speeds, "ito");
  }

  // 進む方向を決定する
  public void decideDirection(Stage stage) {
    super.decideDirection(stage);
    PVector aimPoint;

    if (status == MonsterStatus.Active) {
      switch (mode) {
      case Rest:
        // 休息中は右下を徘徊
        aimPoint = new PVector(random(stage.map.size.x / 2, stage.map.size.x), random(stage.map.size.y / 2, stage.map.size.y));
        nextDirection = getAimDirection(stage.map, aimPoint);
        break;

      case Chase:
        // パックマンを中心にしてアカベイの点対象の地点を目指す
        aimPoint = stage.pacman.getPosition().copy().mult(2);
        aimPoint.sub(stage.monsters.get(0).getPosition());
        nextDirection = getAimDirection(stage.map, aimPoint);
        break;

      default:
        break;
      }
    }
  }
}

// 荒井 (ピンキー)
public class Pinky extends Monster {
  public Pinky(PVector position, int direction, HashMap<MonsterSpeed, Float> speeds) {
    super(position, direction, speeds, "arai");
  }

  // 進む方向を決定する
  public void decideDirection(Stage stage) {
    super.decideDirection(stage);
    PVector aimPoint;

    if (status == MonsterStatus.Active) {
      switch (mode) {
      case Rest:
        // 休息中は左上を徘徊
        aimPoint = new PVector(random(0, stage.map.size.x / 2), random(0, stage.map.size.y / 2));
        nextDirection = getAimDirection(stage.map, aimPoint);
        break;

      case Chase:
        // パックマンのいる地点の3マス先を目指す
        PVector directionVector = getDirectionVector(stage.pacman.direction).mult(3);
        aimPoint = stage.pacman.getPosition().copy();
        aimPoint.add(directionVector.x * stage.pacman.size.x, directionVector.y * stage.pacman.size.y);
        nextDirection = getAimDirection(stage.map, aimPoint);
        break;

      default:
        break;
      }
    }
  }
}

// 大矢 (グズタ)
public class Guzuta extends Monster {
  public Guzuta(PVector position, int direction, HashMap<MonsterSpeed, Float> speeds) {
    super(position, direction, speeds, "ohya");
  }

  // 進む方向を決定する
  public void decideDirection(Stage stage) {
    super.decideDirection(stage);
    PVector aimPoint;

    if (status == MonsterStatus.Active) {
      switch (mode) {
      case Rest:
        // 休息中は左下を徘徊
        aimPoint = new PVector(random(0, stage.map.size.x / 2), random(stage.map.size.y / 2, stage.map.size.y));
        nextDirection = getAimDirection(stage.map, aimPoint);
        break;

      case Chase:
        // パックマンから半径260px外ではアカベイと同じ追跡方法、半径260px内ではランダムに動く
        if (position.dist(stage.pacman.position) > 260) {
          nextDirection = getAimDirection(stage.map, stage.pacman.getPosition());
        } else {
          aimPoint = new PVector(random(0, stage.map.size.x), random(0, stage.map.size.y));
          nextDirection = getAimDirection(stage.map, aimPoint);
        }
        break;

      default:
        break;
      }
    }
  }
}
// ゲーム画面
public class Game implements Scene {
  public static final int LIFE_NUM = 3;
  public static final int ONEUP_SCORE = 10000;

  protected int life = LIFE_NUM - 1; // 残機の数
  protected int score = 0;           // 現在のスコア
  protected int prevScore = 0;       // 前ステージまでのスコア
  protected int nextOneUpScore = ONEUP_SCORE; // 1UPするスコア

  protected String[] stageNames = {"1", "2", "3"}; // ステージ名
  protected int stageNum = 0; // 現在のステージ番号
  protected Stage stage;      // 現在のステージ

  protected PImage lifeImage = loadImage("images/player-3-0.png"); // 残基の画像
  protected SoundEffect se = new SoundEffect(minim); // SE

  // ステージの画像
  protected PImage[] stageImages = {
    loadImage("images/computer-0.png"), 
    loadImage("images/kakomon-0.png"), 
    loadImage("images/monster-0.png")
  };

  public Game() {
    this.stage = new Stage(stageNames[stageNum]);
  }

  public void update() {
    stage.update();
    score = prevScore + stage.getScore();

    switch (stage.getStatus()) {
    case Finish:
      // 次のステージへ
      if (stageNum >= stageNames.length - 1) {
        SceneManager.setScene(new Result(score, stageNum + 1, true));
      } else {
        stageNum++;
        this.prevScore = this.score;
        this.stage = new Stage(stageNames[stageNum]);
        this.se = new SoundEffect(minim);
      }

      break;

    case Reset:
      // ゲームオーバー
      if (life <= 0)
        SceneManager.setScene(new Result(score, stageNum + 1, false));
      life--;

      break;

    default:
      // 1UP
      if (score >= nextOneUpScore) {
        life++;
        nextOneUpScore += ONEUP_SCORE;
        se.oneUp();
      }

      break;
    }
  }

  public void draw() {
    this.stage.draw();

    // スコア表示
    textAlign(RIGHT, BASELINE);

    textFont(font2, 24);
    fill(0, 0, 159);
    text("SCORE", 100, 175);
    text("HIGH SCORE", 465, 175);

    textFont(font2, 24);
    fill(0, 0, 0);
    text(score, 100, 197);
    if (Record.getRanking(1) > score)
      text(Record.getRanking(1), 465, 197);
    else
      text(score, 465, 197);

    imageMode(CENTER);

    // 残基表示
    for (int i = 0; i < life; i++)
      image(lifeImage, i * 32 + 31, 738);

    // ステージ表示
    for (int i = 0; i <= stageNum; i++)
      image(stageImages[i], i * -32 + 449, 738);

    // 枠表示
    rectMode(CENTER);
    stroke(27, 20, 100);
    strokeWeight(4);
    noFill();
    rect(SCREEN_SIZE.x / 2, 455, 478, 630, 10);
  }
}
// ゲーム内オブジェクトの基底クラス
public abstract class GameObject {
  protected PVector position; // 現在位置
  protected PVector size;     // 画像サイズ

  protected GameObject(PVector position) {
    this.position = position.copy();
  }

  public PVector getPosition() {
    return this.position;
  }

  public void setPosition(PVector position) {
    this.position = position;
  }

  public PVector getSize() {
    return this.size;
  }

  // 左上の座標を取得
  public PVector getMinPosition() {
    return new PVector(position.x - size.x / 2, position.y - size.y / 2);
  }

  // 右下の座標を取得
  public PVector getMaxPosition() {
    return new PVector(position.x + size.x / 2 - 1, position.y + size.y / 2 - 1);
  }

  // 当たり判定
  public boolean isColliding(GameObject object) {
    PVector minPosition = object.getMinPosition();
    PVector maxPosition = object.getMaxPosition();

    // 自分の中心が相手に触れていたら当たり
    return position.x >= minPosition.x &&
           position.x <= maxPosition.x &&
           position.y >= minPosition.y &&
           position.y <= maxPosition.y;
  }

  // 画面描画
  public abstract void draw();
}

// アイテム
public class Item extends GameObject {
  protected Animation animation; // アニメーション

  public Item(PVector position, String itemName) {
    super(position);

    this.animation = new Animation("images/" + itemName);
    this.size = animation.getSize();
  }

  // リセット
  public void reset() {
    animation.reset();
  }

  // 更新
  public void update() {
    animation.update();
  }

  // 画面描画
  public void draw() {
    imageMode(CENTER);
    image(animation.getImage(), position.x, position.y);
  }
}


// 入力のインターフェイス
public interface InputInterface {
  public abstract boolean right();   // →
  public abstract boolean up();      // ↑
  public abstract boolean left();    // ←
  public abstract boolean down();    // ↓
  public abstract boolean buttonA(); // A
  public abstract boolean buttonB(); // B
  public abstract boolean buttonC(); // C
}

// キーボードからの入力
public class KeyboardInput implements InputInterface {
  public boolean right() {
    return keyPressed && keyCode == RIGHT;
  }

  public boolean up() {
    return keyPressed && keyCode == UP;
  }

  public boolean left() {
    return keyPressed && keyCode == LEFT;
  }

  public boolean down() {
    return keyPressed && keyCode == DOWN;
  }

  public boolean buttonA() {
    return keyPressed && key == 'z';
  }

  public boolean buttonB() {
    return keyPressed && key == 'x';
  }

  public boolean buttonC() {
    return keyPressed && key == 'c';
  }
}

// アーケードからの入力
public class ArcadeInput implements InputInterface {
  public static final int RIGHT = 18;
  public static final int UP = 4;
  public static final int LEFT = 27;
  public static final int DOWN = 17;
  public static final int ROUND_UP = 22;
  public static final int ROUND_LEFT = 24;
  public static final int ROUND_RIGHT = 23;

  public ArcadeInput() {
    GPIO.pinMode(RIGHT, GPIO.INPUT_PULLUP);
    GPIO.pinMode(UP, GPIO.INPUT_PULLUP);
    GPIO.pinMode(LEFT, GPIO.INPUT_PULLUP);
    GPIO.pinMode(DOWN, GPIO.INPUT_PULLUP);
    GPIO.pinMode(ROUND_UP, GPIO.INPUT_PULLUP);
    GPIO.pinMode(ROUND_LEFT, GPIO.INPUT_PULLUP);
    GPIO.pinMode(ROUND_RIGHT, GPIO.INPUT_PULLUP);
  }

  public boolean right() {
    return GPIO.digitalRead(RIGHT) == GPIO.LOW;
  }

  public boolean up() {
    return GPIO.digitalRead(UP) == GPIO.LOW;
  }

  public boolean left() {
    return GPIO.digitalRead(LEFT) == GPIO.LOW;
  }

  public boolean down() {
    return GPIO.digitalRead(DOWN) == GPIO.LOW;
  }

  public boolean buttonA() {
    return GPIO.digitalRead(ROUND_UP) == GPIO.LOW;
  }

  public boolean buttonB() {
    return GPIO.digitalRead(ROUND_LEFT) == GPIO.LOW;
  }

  public boolean buttonC() {
    return GPIO.digitalRead(ROUND_RIGHT) == GPIO.LOW;
  }
}

// キーボード・アーケード同時対応
public class MixInput implements InputInterface {
  private KeyboardInput keyboardInput = new KeyboardInput();
  private ArcadeInput arcadeInput = new ArcadeInput();

  public boolean right() {
    return keyboardInput.right() || arcadeInput.right();
  }

  public boolean up() {
    return keyboardInput.up() || arcadeInput.up();
  }

  public boolean left() {
    return keyboardInput.left() || arcadeInput.left();
  }

  public boolean down() {
    return keyboardInput.down() || arcadeInput.down();
  }

  public boolean buttonA() {
    return keyboardInput.buttonA() || arcadeInput.buttonA();
  }

  public boolean buttonB() {
    return keyboardInput.buttonB() || arcadeInput.buttonB();
  }

  public boolean buttonC() {
    return keyboardInput.buttonC() || arcadeInput.buttonC();
  }
}

// 入力
public static class Input {
  protected static InputInterface inputInterface;

  // 前回の状態
  protected static boolean prevRight = false;
  protected static boolean prevUp = false;
  protected static boolean prevLeft = false;
  protected static boolean prevDown = false;
  protected static boolean prevButtonA = false;
  protected static boolean prevButtonB = false;
  protected static boolean prevButtonC = false;

  public static void setInputInterface(InputInterface inputInterface) {
    Input.inputInterface = inputInterface;
    prevRight = false;
    prevUp = false;
    prevLeft = false;
    prevDown = false;
    prevButtonA = false;
    prevButtonB = false;
    prevButtonC = false;
  }

  public static boolean right() {
    return inputInterface.right();
  }

  public static boolean up() {
    return inputInterface.up();
  }

  public static boolean left() {
    return inputInterface.left();
  }

  public static boolean down() {
    return inputInterface.down();
  }

  public static boolean buttonA() {
    return inputInterface.buttonA();
  }

  public static boolean buttonB() {
    return inputInterface.buttonB();
  }

  public static boolean buttonC() {
    return inputInterface.buttonC();
  }

  public static boolean anyButton() {
    return right() || up() || left() || down() || buttonA() || buttonB() || buttonC();
  }

  public static boolean rightPress() {
    if (right()) {
      if (prevRight) {
        return false;
      } else {
        prevRight = true;
        return true;
      }
    } else {
      prevRight = false;
      return false;
    }
  }

  public static boolean upPress() {
    if (up()) {
      if (prevUp) {
        return false;
      } else {
        prevUp = true;
        return true;
      }
    } else {
      prevUp = false;
      return false;
    }
  }

  public static boolean leftPress() {
    if (left()) {
      if (prevLeft) {
        return false;
      } else {
        prevLeft = true;
        return true;
      }
    } else {
      prevLeft = false;
      return false;
    }
  }

  public static boolean downPress() {
    if (down()) {
      if (prevDown) {
        return false;
      } else {
        prevDown = true;
        return true;
      }
    } else {
      prevDown = false;
      return false;
    }
  }

  public static boolean buttonAPress() {
    if (buttonA()) {
      if (prevButtonA) {
        return false;
      } else {
        prevButtonA = true;
        return true;
      }
    } else {
      prevButtonA = false;
      return false;
    }
  }

  public static boolean buttonBPress() {
    if (buttonB()) {
      if (prevButtonB) {
        return false;
      } else {
        prevButtonB = true;
        return true;
      }
    } else {
      prevButtonB = false;
      return false;
    }
  }

  public static boolean buttonCPress() {
    if (buttonC()) {
      if (prevButtonC) {
        return false;
      } else {
        prevButtonC = true;
        return true;
      }
    } else {
      prevButtonC = false;
      return false;
    }
  }
  
  public static boolean anyButtonPress() {
    return rightPress() || upPress() || leftPress() || downPress() || buttonAPress() || buttonBPress() || buttonCPress();
  }

  public static boolean rightRelease() {
    if (right()) {
      prevRight = true;
      return false;
    } else {
      if (prevRight) {
        prevRight = false;
        return true;
      } else {
        return false;
      }
    }
  }

  public static boolean upRelease() {
    if (up()) {
      prevUp = true;
      return false;
    } else {
      if (prevUp) {
        prevUp = false;
        return true;
      } else {
        return false;
      }
    }
  }

  public static boolean leftRelease() {
    if (left()) {
      prevLeft = true;
      return false;
    } else {
      if (prevLeft) {
        prevLeft = false;
        return true;
      } else {
        return false;
      }
    }
  }

  public static boolean downRelease() {
    if (down()) {
      prevDown = true;
      return false;
    } else {
      if (prevDown) {
        prevDown = false;
        return true;
      } else {
        return false;
      }
    }
  }

  public static boolean buttonARelease() {
    if (buttonA()) {
      prevButtonA = true;
      return false;
    } else {
      if (prevButtonA) {
        prevButtonA = false;
        return true;
      } else {
        return false;
      }
    }
  }

  public static boolean buttonBRelease() {
    if (buttonB()) {
      prevButtonB = true;
      return false;
    } else {
      if (prevButtonB) {
        prevButtonB = false;
        return true;
      } else {
        return false;
      }
    }
  }

  public static boolean buttonCRelease() {
    if (buttonC()) {
      prevButtonC = true;
      return false;
    } else {
      if (prevButtonC) {
        prevButtonC = false;
        return true;
      } else {
        return false;
      }
    }
  }

  public static boolean anyButtonRelease() {
    return rightRelease() || upRelease() || leftRelease() || downRelease() || buttonARelease() || buttonBRelease() || buttonCRelease();
  }
}
// マップ内のオブジェクトの種類
public enum MapObject {
  Wall,       // 壁
  Route,      // 通路
  Tunnel,     // ワープトンネル
  MonsterDoor // 敵出入口
}

// マップ
public class Map {
  protected MapObject[][] objects; // マップ内のオブジェクト
  protected int[][] returnRoute;   // 敵の帰路
  protected PVector releasePoint;  // 出撃地点
  protected PVector returnPoint;   // 帰還地点
  protected Animation image;       // マップの画像
  protected PVector size;          // 画像サイズ

  public Map(String mapName) {
    // 画像ファイル読み込み
    this.image = new Animation("stages/" + mapName + "-image");
    this.size = image.getSize();
    this.objects = new MapObject[round(size.x)][round(size.y)];
    this.returnRoute = new int[round(size.x)][round(size.y)];

    // マップファイル読み込み
    PImage mapImage = loadImage("stages/" + mapName + "-map.png");
    mapImage.loadPixels();

    // 帰路ファイル読み込み
    PImage returnImage = loadImage("stages/" + mapName + "-return.png");
    returnImage.loadPixels();

    for (int y = 0; y < mapImage.height; y++) {
      for (int x = 0; x < mapImage.width; x++) {
        int mapPixel = mapImage.pixels[y * mapImage.width + x];
        int returnPixel = returnImage.pixels[y * returnImage.width + x];

        if (mapPixel == color(255, 255, 255))
          objects[x][y] = MapObject.Wall; // 壁
        else if (mapPixel == color(0, 255, 0))
          objects[x][y] = MapObject.MonsterDoor; // 敵出入口
        else if (mapPixel == color(255, 127, 0))
          objects[x][y] = MapObject.Tunnel; // ワープトンネル
        else
          objects[x][y] = MapObject.Route; // 通路

        if (mapPixel == color(255, 0, 255))
          releasePoint = new PVector(x, y); // 出撃地点

        if (returnPixel == color(0, 0, 0))
          returnRoute[x][y] = 0; // 右
        else if (returnPixel == color(255, 0, 0))
          returnRoute[x][y] = 1; // 上
        else if (returnPixel == color(0, 255, 0))
          returnRoute[x][y] = 2; // 左
        else if (returnPixel == color(0, 0, 255))
          returnRoute[x][y] = 3; // 下
        else if (returnPixel == color(255, 0, 255))
          returnPoint = new PVector(x, y); // 帰還地点
      }
    }
  }

  public PVector getReleasePoint() {
    return this.releasePoint;
  }

  public PVector getReturnPoint() {
    return this.returnPoint;
  }

  public PVector getSize() {
    return this.size;
  }

  public MapObject getObject(float x, float y) {
    return this.objects[round(x + size.x) % PApplet.parseInt(size.x)][round(y + size.y) % PApplet.parseInt(size.y)];
  }

  public MapObject getObject(PVector v) {
    return this.objects[round(v.x + size.x) % PApplet.parseInt(size.x)][round(v.y + size.y) % PApplet.parseInt(size.y)];
  }

  public int getReturnRoute(float x, float y) {
    return this.returnRoute[round(x + size.x) % PApplet.parseInt(size.x)][round(y + size.y) % PApplet.parseInt(size.y)];
  }

  public int getReturnRoute(PVector v) {
    return this.returnRoute[round(v.x + size.x) % PApplet.parseInt(size.x)][round(v.y + size.y) % PApplet.parseInt(size.y)];
  }

  // 更新
  public void update() {
    image.update();
  }

  // 画面描画
  public void draw() {
    imageMode(CENTER);
    image(image.getImage(), SCREEN_SIZE.x / 2, SCREEN_SIZE.y / 2);
  }
}
// 敵の状態
public enum MonsterStatus {
  Wait,    // 待機
  Release, // 出撃
  Active,  // 活動
  Return   // 帰還
}

// 敵のモード
public enum MonsterMode {
  Rest,  // 休息モード
  Chase, // 追いかけモード
  Ijike  // イジケモード
}

// 敵のスピード
public enum MonsterSpeed {
  Wait,    // 待機
  Release, // 出撃
  Return,  // 帰還
  Rest,    // 休憩モード
  Chase,   // 追いかけモード
  Ijike    // イジケモード
}

public abstract class Monster extends Character {
  protected MonsterStatus status = MonsterStatus.Wait;       // 状態
  protected MonsterMode mode = MonsterMode.Rest;             // モード
  protected boolean ijikeLimit = false;                      // イジケモードが終わりそうか
  protected boolean curImage = false;                        // 表示画像 (false:通常 true:イジケ)
  protected Timer switchTimer = new Timer(5);                // 画像切り替え用タイマー
  protected Animation[] ijikeAnimations = new Animation[4];  // イジケ時のアニメーション
  protected Animation[] returnAnimations = new Animation[4]; // 帰還時のアニメーション
  protected HashMap<MonsterSpeed, Float> speeds;

  public Monster(PVector position, int direction, HashMap<MonsterSpeed, Float> speeds, String characterName) {
    super(position, direction, speeds.get(MonsterSpeed.Wait), characterName);
    this.speeds = speeds;

    // イジケ時のアニメーション
    for (int i = 0; i < 4; i++)
      this.ijikeAnimations[i] = new Animation("images/" + characterName + "-ijike-" + i);

    // 帰還時のアニメーション
    for (int i = 0; i < 4; i++)
      this.returnAnimations[i] = new Animation("images/" + "return-" + i);
  }

  protected void updateSpeed() {
    switch (status) {
    case Wait:
      speed = speeds.get(MonsterSpeed.Wait);
      break;

    case Release:
      speed = speeds.get(MonsterSpeed.Release);
      break;

    case Return:
      speed = speeds.get(MonsterSpeed.Return);
      break;

    case Active:
      switch (mode) {
      case Rest:
        speed = speeds.get(MonsterSpeed.Rest);
        break;

      case Chase:
        speed = speeds.get(MonsterSpeed.Chase);
        break;

      case Ijike:
        speed = speeds.get(MonsterSpeed.Ijike);
        break;
      }
    }
  }

  public MonsterStatus getStatus() {
    return this.status;
  }

  public void setStatus(MonsterStatus status) {
    this.status = status;
    updateSpeed();
  }

  public MonsterMode getMode() {
    return this.mode;
  }

  public void setMode(MonsterMode mode) {
    this.mode = mode;
    updateSpeed();

    if (mode == MonsterMode.Ijike) {
      ijikeLimit = false;
      curImage = false;
      switchTimer.reset();

      for (int i = 0; i < 4; i++) {
        animations[i].reset();
        ijikeAnimations[i].reset();
      }
    }
  }

  public boolean getIjikeLimit() {
    return this.ijikeLimit;
  }

  public void setIjikeLimit(boolean ijikeLimit) {
    this.ijikeLimit = ijikeLimit;
  }

  // 移動
  public void move(Map map) {
    if (status != MonsterStatus.Return) {
      // 曲がれたら曲がる、曲がれなかったら直進、前進できるなら後退しない
      PVector forwardMove = canMove(map, direction);
      PVector nextMove = canMove(map, nextDirection);

      if (nextMove.mag() != 0 && (forwardMove.mag() == 0 || (direction + 2) % 4 != nextDirection))
        direction = nextDirection;
      else
        nextMove = canMove(map, direction);
      position.add(nextMove);
    } else {
      for (float t = 0; t < speed; t++) {
        float moveDistance;
        PVector moveVector;

        // 1マスずつ進みながらチェック
        if (t + 1 <= PApplet.parseInt(speed))
          moveDistance = 1;
        else
          moveDistance = speed - t;

        // 進むべき方向に進む
        direction = map.getReturnRoute(position);
        moveVector = getDirectionVector(direction);
        moveVector.mult(moveDistance);
        position.add(moveVector);

        // 巣に到着
        if (round(position.x) == round(map.getReturnPoint().x) && round(position.y) == round(map.getReturnPoint().y))
          break;
      }
    }

    // ワープトンネル、道の真ん中を進むように調整
    switch (direction) {
    case 0: // 右
      position.y = round(position.y);
      if (position.x >= map.getSize().x)
        position.x -= map.getSize().x;
      break;

    case 1: // 上
      position.x = round(position.x);
      if (position.y < 0)
        position.y += map.getSize().y;
      break;

    case 2: // 左
      position.y = round(position.y);
      if (position.x < 0)
        position.x += map.getSize().x;
      break;

    case 3: // 下
      position.x = round(position.x);
      if (position.y >= map.getSize().y)
        position.y -= map.getSize().y;
      break;
    }
  }

  // 特定の方向へ移動できるか
  public PVector canMove(Map map, int aimDirection) {
    float curSpeed;
    boolean turnFlag = false;
    PVector result = new PVector(0, 0);

    // ワープトンネルで減速
    if (map.getObject(position) == MapObject.Tunnel)
      curSpeed = speed / 1.5f;
    else
      curSpeed = speed;

    for (float t = 0; t < curSpeed; t++) {
      float moveDistance;
      PVector moveVector;
      MapObject mapObject;

      // 1マスずつ進みながらチェック
      if (t + 1 <= PApplet.parseInt(curSpeed) || !turnFlag && (aimDirection + direction) % 2 == 1)
        moveDistance = 1;
      else
        moveDistance = curSpeed - t;

      // 進みたい方向に進んでみる
      moveVector = getDirectionVector(aimDirection);
      moveVector.mult(moveDistance);
      result.add(moveVector);

      mapObject = map.getObject(PVector.add(position, result));
      if (mapObject != MapObject.Wall && (status == MonsterStatus.Release || status == MonsterStatus.Return || mapObject != MapObject.MonsterDoor)) {
        turnFlag = true;
      } else {
        result.sub(moveVector);

        if (turnFlag)
          break;

        // 壁があったら直進する
        moveVector = getDirectionVector(direction);
        moveVector.mult(moveDistance);
        result.add(moveVector);

        mapObject = map.getObject(PVector.add(position, result));
        if (mapObject == MapObject.Wall || (status != MonsterStatus.Release && status != MonsterStatus.Return && mapObject == MapObject.MonsterDoor))
          break;
      }
    }

    if (turnFlag)
      return result;
    else
      return new PVector(0, 0);
  }

  // 目標地点に進むための方向を返す
  protected int getAimDirection(Map map, PVector point) {
    int aimDirection = 0;
    float distanceMin = map.size.mag();

    for (int i = 0; i < 4; i++) {
      // 各方向に進んだときに目標地点との距離が最短となる方向を探す
      int checkDirection = (direction + i) % 4;
      PVector checkMove = canMove(map, checkDirection);

      if (checkMove.mag() != 0 && PVector.add(position, checkMove).dist(point) < distanceMin) {
        aimDirection = checkDirection;
        distanceMin = PVector.add(position, checkMove).dist(point);
      }
    }

    return aimDirection;
  }

  // 進む方向を決定する
  public void decideDirection(Stage stage) {
    PVector aimPoint;

    switch (status) {
    case Wait:
      // 待機中は前後に動く
      if (canMove(stage.map, direction).mag() == 0)
        nextDirection = (direction + 2) % 4;
      break;

    case Release:
      // 出撃中は出撃地点を目指す
      aimPoint = stage.map.getReleasePoint();
      nextDirection = getAimDirection(stage.map, aimPoint);
      break;

    case Active:
      if (mode == MonsterMode.Ijike) {
        // イジケ中はランダムに動く
        aimPoint = new PVector(position.x + random(-1, 1), position.y + random(-1, 1));
        nextDirection = getAimDirection(stage.map, aimPoint);
      }
      break;

    case Return:
      break;
    }
  }

  // リセット
  public void reset() {
    super.reset();
    setStatus(MonsterStatus.Wait);
    setMode(MonsterMode.Rest);
  }

  // 更新
  public void update(Map map) {
    // 目標地点に到達したら状態遷移
    switch (status) {
    case Release:
      if (round(position.x) == round(map.getReleasePoint().x) && round(position.y) == round(map.getReleasePoint().y))
        setStatus(MonsterStatus.Active);
      break;

    case Return:
      if (round(position.x) == round(map.getReturnPoint().x) && round(position.y) == round(map.getReturnPoint().y))
        setStatus(MonsterStatus.Release);
      break;

    default:
      break;
    }

    // アニメーションを更新
    switch (status) {
    case Wait:
    case Release:
    case Active:
      if (mode == MonsterMode.Ijike) {
        if (ijikeLimit && switchTimer.update())
          curImage = !curImage;
        animationUpdate(ijikeAnimations[direction], map);
      }
      break;

    case Return:
      animationUpdate(returnAnimations[direction], map);
      break;
    }
  }

  // 画面描画
  public void draw() {
    imageMode(CENTER);

    switch (status) {
    case Wait:
    case Release:
    case Active:
      if (mode == MonsterMode.Ijike && (!ijikeLimit || curImage))
        image(ijikeAnimations[direction].getImage(), position.x, position.y);
      else
        image(animations[direction].getImage(), position.x, position.y);
      break;

    case Return:
      image(returnAnimations[direction].getImage(), position.x, position.y);
      break;
    }
  }
}
// リザルト画面
public class Result implements Scene {
  protected int score;     // スコア
  protected int stage;     // ステージ
  protected boolean clear; // クリアしたか
  protected int ranking;   // ランキング
  protected boolean light = true; // 点灯中か
  protected Timer lightTimer = new Timer(30); // タイマー
  protected Timer exitTimer = new Timer(300); // 終了タイマー

  // キャラクター
  protected FreeCharacter[] characters = {
    new FreeCharacter(new PVector(292, 765), 3, 0, "player"),
    new FreeCharacter(new PVector(328, 765), 3, 0, "fujix"),
    new FreeCharacter(new PVector(364, 765), 3, 0, "ito"),
    new FreeCharacter(new PVector(400, 765), 3, 0, "arai"),
    new FreeCharacter(new PVector(436, 765), 3, 0, "ohya")
  };

  public Result(int score, int stage, boolean clear) {
    this.score = score;
    this.stage = stage;
    this.clear = clear;

    // ハイスコア更新
    this.ranking = Record.setRanking(this.score);
  }

  public void update() {
    if (lightTimer.update()) {
      lightTimer.setTime(light ? 15 : 30);
      light = !light;
    }

    for (FreeCharacter character : characters)
      character.update();

    if (exitTimer.update())
      exit();
  }

  public void draw() {
    background(200, 240, 255);
    noStroke();
    rectMode(CENTER);
    textAlign(CENTER, CENTER);

    fill(63, 63, 63);
    rect(SCREEN_SIZE.x / 2, 167, 420, 75);

    fill(255, 255, 255);
    textFont(font2, 60);
    if (clear)
      text("GAME CLEAR!", SCREEN_SIZE.x / 2, 163);
    else
      text("GAME OVER", SCREEN_SIZE.x / 2, 163);

    fill(0, 0, 0);
    text(stage, SCREEN_SIZE.x / 2, 333);
    text(score, SCREEN_SIZE.x / 2, 468);

    fill(0, 0, 159);
    textFont(font2, 40);
    text("ステージ", SCREEN_SIZE.x / 2, 283);
    text("スコア", SCREEN_SIZE.x / 2, 418);

    if (light && ranking != 0) {
      fill(127, 127, 127);
      rect(SCREEN_SIZE.x / 2, 580, 320, 60);

      fill(255, 255, 0);
      text("ランキングNo. " + ranking, SCREEN_SIZE.x / 2, 580);
    }

    fill(0, 0, 0);
    text("またあそんでね！", 340, 710);

    for (FreeCharacter character : characters)
      character.draw();
  }
}
// ルール説明画面
public class Rule implements Scene {
  private final FreeCharacter FreePacman = new FreeCharacter(new PVector(214, 247), 0, 8, "player");
  private final FreeCharacter[] FreeMonsters = {
    new FreeCharacter(new PVector(179, 370), 3, 1.6f, "fujix"), 
    new FreeCharacter(new PVector(220, 370), 3, 1.6f, "ito"), 
    new FreeCharacter(new PVector(260, 370), 3, 1.6f, "arai"), 
    new FreeCharacter(new PVector(301, 370), 3, 1.6f, "ohya")
  };
  boolean imageLoadFlag = false;  
  protected Timer lightTimer1 = new Timer(30); // 1秒タイマー
  protected Timer lightTimer2 = new Timer(15); // 0.5秒タイマー
  protected boolean lightAppear = true;
  protected Item bigPowerFood = new Item(new PVector(86, 547), "big_power_food");
  private boolean pressed;
  protected TitleBGM titlebgm; // BGM

  public Rule(int position) {
    this.titlebgm = new TitleBGM(minim, position);
  }

  public void update() {
    FreePacman.update();
    titlebgm.play();

    if (Input.anyButtonPress())
      pressed = true;

    if (pressed) {
      FreePacman.move();
      rectMode(CENTER);
      noStroke();
      fill(200, 240, 255);
      rect(FreePacman.getPosition().x - FreePacman.getSpeed() - 5, 247, 32, 35);
      if (FreePacman.getPosition().x >= SCREEN_SIZE.x + 16) {
        SceneManager.setScene(new Load());
        titlebgm.stop();
      }
    }
  }

  public void draw() {
    imageMode(CENTER);
    textAlign(CENTER, CENTER);

    if (imageLoadFlag == false) {
      PImage ruleImage = loadImage("images/rule.png");
      image(ruleImage, SCREEN_SIZE.x / 2, SCREEN_SIZE.y / 2);
      imageLoadFlag = true;
    }
    clearAfterimage();
    FreePacman.draw();
    for (FreeCharacter monster : FreeMonsters) {
      monster.draw();
      monster.update();
      monster.move();
      if (monster.getDirection() == 3 && monster.position.y >= 400)
        monster.setDirection(1);
      else if (monster.getDirection() == 1 && monster.position.y <= 345)
        monster.setDirection(3);
    }
    bigPowerFood.draw();
    bigPowerFood.update();
    if (lightAppear == true) {
      fill(0, 0, 159);
      textFont(font2, 40);
      text("ボタンをおして", SCREEN_SIZE.x / 2, 706);
      text("ゲームスタート！", SCREEN_SIZE.x / 2, 754);
    }
    if (lightTimer1.update())
      lightAppear = false;
    if (lightAppear == false) {
      if (lightTimer2.update())
        lightAppear = true;
    }
  }

  public void clearAfterimage() {
    rectMode(CENTER);
    noStroke();
    fill(200, 240, 255);
    // pacmanを消す
    rect(214, 247, 32, 32);
    // 敵を消す
    rect(SCREEN_SIZE.x / 2, 370, 160, 100);
    // powerFoodを消す
    rect(86, 547, 32, 32);
    // 文字を消す
    rect(SCREEN_SIZE.x / 2, 730, 300, 100);
  }
}

public class Load implements Scene {
  public void update() {
    SceneManager.setScene(new Game());
  }

  public void draw() {
    background(0);
    PImage loadingImage = loadImage("images/Loading.png");
    imageMode(CENTER);
    image(loadingImage, SCREEN_SIZE.x / 2, SCREEN_SIZE.y / 2);
    imageMode(CORNER);
  }
}
// シーン
public interface Scene {
  public void update();
  public void draw();
}

// シーン管理
public static class SceneManager {
  protected static Scene scene;

  public static void setScene(Scene scene) {
    SceneManager.scene = scene;
  }

  public static void update() {
    scene.update();
  }

  public static void draw() {
    scene.draw();
  }
}



// BGMの基底クラス
abstract public class BGM {
  protected Minim minim;
  protected AudioPlayer player;
  protected boolean breakFlag; // ファイル読み込みエラー用のフラグ

  public BGM(Minim minim) {
    // 音楽ファイル読み込み
    this.minim = minim;
  }

  // 停止
  public void stop() {
    if (!breakFlag) {
      player.close();
      minim.stop();
    }
  }
}

// スタート時のBGM
public class StartBGM extends BGM {

  public StartBGM(Minim minim, String mapName) {
    super(minim);
    player = this.minim.loadFile("sounds/start.mp3");
    if (player == null) {
      breakFlag = true;
    } else {
      breakFlag = false;
      player.setGain(-10);
      player.rewind();
    }
    if (mapName.equals("1")) {  // ゲーム開始時かをチェック
    } else {
      player.setGain(-100);     // ゲーム開始時以外なら消音にする
      player.cue(2700);
    }
  }

  // 消音にし、再生開始位置をリセット
  public void mute() {
    if (!breakFlag) {
      player.setGain(-100);
      player.cue(2700);
    }
  }

  // 再生
  public boolean play() {
    if (!breakFlag) {
      player.play();
      if (player.position() >= 4700) {
        player.pause();
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }
}

// 通常時のBGM
public class NomalBGM extends BGM {

  public NomalBGM(Minim minim) {
    super(minim);
    player = this.minim.loadFile("sounds/school_song.mp3");
    if (player == null) {
      breakFlag = true;
    } else {
      breakFlag = false;
      player.cue(3500);
      player.setGain(-10);      // 音量調節
    }
  }

  // 再生開始位置をリセット
  public void rewind() {
    if (!breakFlag) {
      player.cue(3500);
    }
  }

  // 再生
  public void play() {
    if (!breakFlag) {
      if (player.position() >= 52000) {
        player.cue(4100);
      }
      player.play();
    }
  }

  // 一時停止
  public void pause() {
    if (!breakFlag) {
      player.pause();
    }
  }
}

// タイトル時のBGM
public class TitleBGM extends BGM {

  public TitleBGM(Minim minim) {
    super(minim);
    player = this.minim.loadFile("sounds/title_free.mp3");
    if (player == null) {
      breakFlag = true;
    } else {
      breakFlag = false;
      player.cue(300);
      player.setGain(-5);      // 音量調節
    }
  }

  public TitleBGM(Minim minim, int position) {
    super(minim);
    player = this.minim.loadFile("sounds/title_free.mp3");
    if (player == null) {
      breakFlag = true;
    } else {
      breakFlag = false;
      player.cue(position);
      player.setGain(-5);      // 音量調節
    }
  }

  // 再生
  public void play() {
    if (!breakFlag) {
      if (player.position() >= 29974) {
        player.cue(0);
      }
      player.play();
    }
  }

  // 再生位置の取得
  public int getPos() {
    if (!breakFlag) {
      return(player.position());
    } else {
      return(0);
    }
  }
}


// 効果音
public class SoundEffect {
  protected final float VOLUME = 0.1f;  // 音量
  private boolean eatSEFlag = true;    // 普通のエサを食べたときの効果音切り替えフラグ

  protected AudioOutput out;

  public SoundEffect(Minim minim) {
    out = minim.getLineOut();
  }

  // パワーエサを食べたとき
  public void eatPowerFood() {  
    float soundWidth = 0.02f, cycle = 0.16f; 
    int i;
    for (i = 0; i < 4; i++) {
      out.playNote(soundWidth * 0 + cycle * i, soundWidth, new SquareInstrument(787.330f, VOLUME, out));
      out.playNote(soundWidth * 1 + cycle * i, soundWidth, new SquareInstrument(864.255f, VOLUME, out));
      out.playNote(soundWidth * 2 + cycle * i, soundWidth, new SquareInstrument(908.456f, VOLUME, out));
      out.playNote(soundWidth * 3 + cycle * i, soundWidth, new SquareInstrument(998.991f, VOLUME, out));
      out.playNote(soundWidth * 4 + cycle * i, soundWidth, new SquareInstrument(1100.000f, VOLUME, out));
      out.playNote(soundWidth * 5 + cycle * i, soundWidth, new SquareInstrument(1212.767f, VOLUME, out));
      out.playNote(soundWidth * 6 + cycle * i, soundWidth, new SquareInstrument(1276.562f, VOLUME, out));
      out.playNote(soundWidth * 7 + cycle * i, soundWidth, new SquareInstrument(1409.659f, VOLUME, out));
    }
  }

  // 普通のエサを食べたとき
  public void eatFood() {
    float soundWidth = 0.015f;
    if (eatSEFlag) {
      out.playNote(soundWidth * 0, soundWidth, new SquareInstrument(174.614f, VOLUME, out));
      out.playNote(soundWidth * 1, soundWidth, new SquareInstrument(195.998f, VOLUME, out));
      out.playNote(soundWidth * 2, soundWidth * 2, new SquareInstrument(220, VOLUME, out));
    } else {
      out.playNote(soundWidth * 0, soundWidth * 2, new SquareInstrument(220, VOLUME, out));
      out.playNote(soundWidth * 2, soundWidth, new SquareInstrument(195.998f, VOLUME, out));
      out.playNote(soundWidth * 3, soundWidth, new SquareInstrument(174.614f, VOLUME, out));
    }
    eatSEFlag = !eatSEFlag;
  }

  // モンスターを食べたとき
  public void eatMonster() {
    float soundWidth = 0.03f;
    out.playNote(soundWidth * 0, soundWidth, new SquareInstrument(659.255f, VOLUME, out));
    out.playNote(soundWidth * 1, soundWidth, new SquareInstrument(698.456f, VOLUME, out));
    out.playNote(soundWidth * 2, soundWidth, new SquareInstrument(783.991f, VOLUME, out));
    out.playNote(soundWidth * 3, soundWidth, new SquareInstrument(880.000f, VOLUME, out));
    out.playNote(soundWidth * 4, soundWidth, new SquareInstrument(987.767f, VOLUME, out));
    out.playNote(soundWidth * 5, soundWidth, new SquareInstrument(1046.502f, VOLUME, out));
    out.playNote(soundWidth * 6, soundWidth, new SquareInstrument(1174.659f, VOLUME, out));
    out.playNote(soundWidth * 7, soundWidth, new SquareInstrument(1318.510f, VOLUME, out));
    out.playNote(soundWidth * 8, soundWidth, new SquareInstrument(1396.918f, VOLUME, out));
  }

  // 食べられたとき
  public void eaten() {
    float soundWidth = 0.125f;
    out.playNote(soundWidth * 0, soundWidth, new SquareInstrument(1396.913f, VOLUME, out));
    out.playNote(soundWidth * 1, soundWidth, new SquareInstrument(1479.978f, VOLUME, out));
    out.playNote(soundWidth * 2, soundWidth, new SquareInstrument(1318.510f, VOLUME, out));
    out.playNote(soundWidth * 3, soundWidth, new SquareInstrument(1396.918f, VOLUME, out));
    out.playNote(soundWidth * 4, soundWidth, new SquareInstrument(1174.659f, VOLUME, out));
    out.playNote(soundWidth * 5, soundWidth, new SquareInstrument(1244.508f, VOLUME, out));
    out.playNote(soundWidth * 6, soundWidth, new SquareInstrument(1046.502f, VOLUME, out));
    out.playNote(soundWidth * 7.5f, soundWidth, new SquareInstrument(739.989f, VOLUME, out));
    out.playNote(soundWidth * 9, soundWidth, new SquareInstrument(739.989f, VOLUME, out));
  }

  // 1up
  public void oneUp() {
    float soundWidth = 0.13f;
    out.playNote(soundWidth * 0, soundWidth, new SquareInstrument(391.995f, VOLUME * 2, out));
    out.playNote(soundWidth * 1, soundWidth, new SquareInstrument(523.251f, VOLUME * 2, out));
    out.playNote(soundWidth * 2, soundWidth, new SquareInstrument(659.255f, VOLUME * 2, out));
    out.playNote(soundWidth * 3, soundWidth, new SquareInstrument(440.000f, VOLUME * 2, out));
    out.playNote(soundWidth * 4, soundWidth, new SquareInstrument(587.330f, VOLUME * 2, out));
    out.playNote(soundWidth * 5, soundWidth, new SquareInstrument(783.991f, VOLUME * 2, out));
  }

  public void eatSPItem() {
    float soundWidth = 0.12f;
    out.playNote(soundWidth * 0, soundWidth, new SquareInstrument(246.942f, VOLUME, out));
    out.playNote(soundWidth * 1, soundWidth, new SquareInstrument(195.998f, VOLUME, out));
    out.playNote(soundWidth * 2, soundWidth, new SquareInstrument(164.814f, VOLUME, out));
    out.playNote(soundWidth * 3, soundWidth, new SquareInstrument(261.626f, VOLUME, out));
  }
}

// 矩形波を生成
public class SquareInstrument implements Instrument {
  protected Oscil oscil;
  protected AudioOutput out;

  public SquareInstrument(float frequency, float amplitude, AudioOutput out) {
    oscil = new Oscil(frequency, amplitude, Waves.SQUARE);
    this.out = out;
  }

  public void noteOn(float duration) {
    oscil.patch(out);
  }

  public void noteOff() {
    oscil.unpatch(out);
  }
}


// ステージの状態
public enum StageStatus {
  Start,  // 開始
  Play,   // ゲーム
  Eat,    // 敵を食べたときの硬直
  Clear,  // クリア
  Die,    // 敵に食べられた
  Finish, // 終了
  Reset   // リセット
}

// スペシャルアイテムの状態
public enum SpecialItemStatus {
  Appear,    // 出現
  Disappear, // 出現していない
  Eat        // 食べられた
}

// ステージ
public class Stage implements Scene {
  protected Map map;       // マップ
  protected Pacman pacman; // パックマン
  protected ArrayList<Monster> monsters = new ArrayList<Monster>(); // 敵
  protected ArrayList<Item> foods = new ArrayList<Item>();          // エサ
  protected ArrayList<Item> powerFoods = new ArrayList<Item>();     // パワーエサ
  protected Item specialItem; // スペシャルアイテム

  protected int frame = 0; // 経過フレーム
  protected int score = 0; // ステージ毎のスコア
  protected StageStatus status = StageStatus.Start; // 状態
  protected boolean eatAnyItem = false; // 前フレームで何か食べたか

  protected int foodScore;        // エサのスコア
  protected int powerFoodScore;   // パワーエサのスコア
  protected int specialItemScore; // スペシャルアイテムのスコア

  protected SpecialItemStatus specialItemStatus = SpecialItemStatus.Disappear; // スペシャルアイテムの状態
  protected int foodCount = 0;    // 食べたエサの数
  protected boolean specialItemFlag = false; // 食べたエサが丁度70, 170の時の多数発生回避フラグ

  protected Timer specialItemTimer = new Timer(300);     // スペシャルアイテム出現タイマー
  protected Timer specialItemScoreTimer = new Timer(30); // スペシャルスコア表示タイマー
  protected Timer startTimer = new Timer(60, false);     // スタート時のタイマー
  protected Timer dieTimer = new Timer(100);             // 死亡時のタイマー
  protected Timer clearTimer1 = new Timer(30, false);    // クリア時のタイマー1
  protected Timer clearTimer2 = new Timer(90);           // クリア時のタイマー2
  protected Timer eatTimer = new Timer(30);              // 敵を食べたときの硬直タイマー
  protected Timer modeTimer;                             // モード切り替え用タイマー

  protected MonsterMode monsterMode;     // 敵のモード
  protected int releaseInterval;         // 排出間隔 [f]
  protected int monsterEatCount = 0;     // イジケ時に敵を食べた個数
  protected int monsterScore = 0;        // 敵を食べたときのスコア
  protected Monster eatenMonster = null; // 食べられた敵
  protected HashMap<MonsterMode, Integer> modeTimes =  new HashMap<MonsterMode, Integer>(); // 各モードの時間 [f]

  protected SoundEffect se = new SoundEffect(minim); // 効果音
  protected StartBGM startbgm; // スタート時のBGM
  protected NomalBGM nomalbgm = new NomalBGM(minim); // ゲーム中のBGM

  public Stage(String mapName) {
    this.map = new Map(mapName);

    // 設定ファイル読み込み
    Setting setting = new Setting("stages/" + mapName + "-setting.txt");

    this.foodScore = setting.getInt("food_score");
    this.powerFoodScore = setting.getInt("power_food_score");
    this.specialItemScore = setting.getInt("special_item_score");
    this.releaseInterval = setting.getInt("release_interval");

    this.modeTimes.put(MonsterMode.Rest, setting.getInt("rest_time"));
    this.modeTimes.put(MonsterMode.Chase, setting.getInt("chase_time"));
    this.modeTimes.put(MonsterMode.Ijike, setting.getInt("ijike_time"));

    this.monsterMode = MonsterMode.Rest;
    this.modeTimer = new Timer(modeTimes.get(monsterMode));

    HashMap<MonsterSpeed, Float> monsterSpeeds = new HashMap<MonsterSpeed, Float>();
    monsterSpeeds.put(MonsterSpeed.Wait, setting.getFloat("monster_wait_speed"));
    monsterSpeeds.put(MonsterSpeed.Release, setting.getFloat("monster_release_speed"));
    monsterSpeeds.put(MonsterSpeed.Return, setting.getFloat("monster_return_speed"));
    monsterSpeeds.put(MonsterSpeed.Rest, setting.getFloat("monster_rest_speed"));
    monsterSpeeds.put(MonsterSpeed.Chase, setting.getFloat("monster_chase_speed"));
    monsterSpeeds.put(MonsterSpeed.Ijike, setting.getFloat("monster_ijike_speed"));

    // マップファイル読み込み
    ArrayList<PVector> monsterPositions = new ArrayList<PVector>();
    PImage mapImage = loadImage("stages/" + mapName + "-map.png");
    mapImage.loadPixels();

    for (int y = 0; y < mapImage.height; y++) {
      for (int x = 0; x < mapImage.width; x++) {
        int pixel = mapImage.pixels[y * mapImage.width + x];

        // パックマン
        if (pixel == color(255, 0, 0)) {
          int pacmanDirection = setting.getInt("pacman_direction");
          float pacmanSpeed = setting.getFloat("pacman_speed");
          this.pacman = new Pacman(new PVector(x, y), pacmanDirection, pacmanSpeed);
        }

        // 敵
        else if (pixel == color(0, 0, 255)) {
          monsterPositions.add(new PVector(x, y));
        }

        // エサ
        else if (pixel == color(255, 255, 0)) {
          foods.add(new Item(new PVector(x, y), "food"));
        }

        // パワーエサ
        else if (pixel == color(0, 255, 255)) {
          powerFoods.add(new Item(new PVector(x, y), "power_food"));
        }

        // スペシャルアイテム
        else if (pixel == color(127, 0, 255)) {
          specialItem = new Item(new PVector(x, y), setting.getString("special_item_name"));
        }
      }
    }

    this.monsters.add(new Akabei(monsterPositions.get(0), 2, monsterSpeeds));
    this.monsters.add(new Pinky(monsterPositions.get(2), 3, monsterSpeeds));
    this.monsters.add(new Aosuke(monsterPositions.get(1), 1, monsterSpeeds));
    this.monsters.add(new Guzuta(monsterPositions.get(3), 1, monsterSpeeds));
    this.monsters.get(0).setStatus(MonsterStatus.Active);
    
    this.startbgm = new StartBGM(minim, mapName); 
  }

  public int getFrame() {
    return this.frame;
  }

  public int getScore() {
    return this.score;
  }

  public StageStatus getStatus() {
    return this.status;
  }

  // ステージ内の状態を更新
  public void update() {
    // ボタン入力
    if (Input.right())
      pacman.setNextDirection(0); // →
    else if (Input.up())
      pacman.setNextDirection(1); // ↑
    else if (Input.left())
      pacman.setNextDirection(2); // ←
    else if (Input.down())
      pacman.setNextDirection(3); // ↓

    switch (status) {
    case Start:
      // スタートBGM再生
      if (startbgm.play() & startTimer.update()) {
        nomalbgm.rewind();
        nomalbgm.play();
        status = StageStatus.Play;
      }
      break;

    case Play:
      // モンスター放出
      if (frame < releaseInterval * (monsters.size() - 1) && frame % releaseInterval == 0)
        this.monsters.get(frame / releaseInterval + 1).setStatus(MonsterStatus.Release);

      // モード切り替え
      if (modeTimer.update()) {
        switch (monsterMode) {
        case Rest:
          monsterMode = MonsterMode.Chase;
          modeTimer.setTime(modeTimes.get(MonsterMode.Chase));
          break;

        case Ijike:
          pacman.setKakusei(false);

        case Chase:
          monsterMode = MonsterMode.Rest;
          modeTimer.setTime(modeTimes.get(MonsterMode.Rest));

          break;
        }

        for (Monster monster : monsters)
          monster.setMode(monsterMode);
      }

      if (monsterMode == MonsterMode.Ijike && modeTimer.getLeft() == 60) {
        pacman.setKakuseiLimit(true);
        for (Monster monster : monsters)
          monster.setIjikeLimit(true);
      }

      // 移動
      if (!eatAnyItem)
        pacman.move(map);
      else
        eatAnyItem = false;

      for (Monster monster : monsters) {
        monster.decideDirection(this);
        monster.move(map);
      }

      // 更新
      pacman.update(map);

      for (Monster monster : monsters)
        monster.update(map);

      for (Item food : foods)
        food.update();

      for (Item powerFood : powerFoods)
        powerFood.update();

      if (specialItemStatus == SpecialItemStatus.Appear)
        specialItem.update();

      // 当たり判定
      // ノーマルエサ
      for (Iterator<Item> i = foods.iterator(); i.hasNext(); ) {
        Item food = i.next();

        if (pacman.isColliding(food)) {
          eatAnyItem = true;
          i.remove();

          // 音を鳴らす
          se.eatFood();

          // 食べたエサの数をカウント
          foodCount++;

          // スコア加算
          this.score += 10;
        }
      }

      // パワーエサ
      for (Iterator<Item> i = powerFoods.iterator(); i.hasNext(); ) {
        Item powerFood = i.next();

        if (pacman.isColliding(powerFood)) {
          eatAnyItem = true;
          i.remove();

          // 音を鳴らす
          se.eatPowerFood();

          // プレイヤー覚醒
          pacman.setKakusei(true);

          // イジケモードに
          for (Monster monster : monsters) {
            monster.setMode(MonsterMode.Ijike);
            monsterMode = MonsterMode.Ijike;
            modeTimer.setTime(modeTimes.get(MonsterMode.Ijike));
          }

          this.monsterEatCount = 0;

          // スコア加算
          this.score += 50;
        }
      }

      // スペシャルアイテム
      if (specialItemStatus == SpecialItemStatus.Appear) {
        if (pacman.isColliding(specialItem)) {
          eatAnyItem = true;

          // 音を鳴らす
          se.eatSPItem();

          // スコア加算
          this.score += specialItemScore;

          // スペシャルアイテムの状態をEatに
          specialItemStatus = SpecialItemStatus.Eat;
        }
      }

      // エサがなくなったらゲームクリア
      if (foods.isEmpty() && powerFoods.isEmpty()) {
        status = StageStatus.Clear;
        pacman.setClear(true);
      }

      // 接敵
      for (Iterator<Monster> i = monsters.iterator(); i.hasNext(); ) {
        Monster monster = i.next();

        if (pacman.isColliding(monster)) {
          switch (monster.getStatus()) {
          case Return:
            break;

          case Active:
          case Release:
            if (monster.getMode() == MonsterMode.Ijike) {
              // モンスターを食べた時のスコア
              monsterEatCount++;
              monsterScore = (int)pow(2, monsterEatCount) * 100;
              score += monsterScore;
              monster.setStatus(MonsterStatus.Return);
              monster.setMode(MonsterMode.Rest);
              se.eatMonster();
              status = StageStatus.Eat;
              eatenMonster = monster;
              break;
            }

          default:
            // 食べられた
            startbgm.mute();
            se.eaten();
            status = StageStatus.Die;
            pacman.setDie(true);
            return;
          }
        }
      }

      // スペシャルアイテムタイマー
      if (specialItemStatus == SpecialItemStatus.Appear) {
        if (specialItemTimer.update())
          specialItemStatus = SpecialItemStatus.Disappear;
      }

      // スペシャルアイテムを食べたときの点数表示タイマー
      if (specialItemStatus == SpecialItemStatus.Eat) {
        if (specialItemScoreTimer.update())
          specialItemStatus = SpecialItemStatus.Disappear;
      }

      // スペシャルアイテム発生
      if ((foodCount == 70 || foodCount == 170) && specialItemFlag == false) {
        specialItemStatus = SpecialItemStatus.Appear;
        specialItemTimer.reset();
        specialItemScoreTimer.reset();
        specialItemFlag = true;
      }

      if (foodCount != 70 && foodCount != 170) {
        specialItemFlag = false;
      }

      frame++;
      break;

    case Eat:
      for (Monster monster : monsters) {
        if (monster.getStatus() == MonsterStatus.Return && monster != eatenMonster) {
          monster.move(map);
          monster.update(map);
        }
      }

      if (eatTimer.update()) {
        status = StageStatus.Play;
      }
      break;

    case Clear:
      nomalbgm.stop();
      startbgm.stop();

      if (clearTimer1.update())
        map.update();

      if (clearTimer2.update())
        status = StageStatus.Finish;

      break;

    case Die:
      nomalbgm.pause();
      if (dieTimer.update())
        status = StageStatus.Reset;
      break;

    case Finish:
      break;

    case Reset:
      // リセット
      frame = 0;
      monsterMode = MonsterMode.Rest;
      modeTimer.setTime(modeTimes.get(monsterMode));
      eatAnyItem = false;

      pacman.reset();

      for (Monster monster : monsters)
        monster.reset();
      this.monsters.get(0).setStatus(MonsterStatus.Active);

      for (Item food : foods)
        food.reset();

      for (Item powerFood : powerFoods)
        powerFood.reset();

      specialItem.reset();
      specialItemStatus = SpecialItemStatus.Disappear;

      status = StageStatus.Start;
      break;
    }
  }

  // 画面描画
  public void draw() {
    textAlign(CENTER, CENTER);

    background(200, 240, 255);
    map.draw();

    fill(220, 0, 0);
    textFont(font, 24);

    if (status == StageStatus.Start)
      text("READY!", SCREEN_SIZE.x / 2, 491);

    // アイテム
    for (Item food : foods)
      food.draw();

    for (Item powerFood : powerFoods)
      powerFood.draw();

    fill(0, 0, 159);
    textFont(font2, 16);

    // スペシャルアイテム
    if (specialItemStatus == SpecialItemStatus.Appear) {
      specialItem.draw();
    } else if (specialItemStatus == SpecialItemStatus.Eat) {
      PVector position = specialItem.getPosition();
      text(specialItemScore, position.x, position.y);
    }

    // 敵
    if (status != StageStatus.Clear || clearTimer1.getLeft() != 0) {
      for (Monster monster : monsters) {
        if (status != StageStatus.Eat || monster != eatenMonster)
          monster.draw();
      }
    }

    // 敵を食べたときの点数表示
    if (status == StageStatus.Eat) {
      PVector position = eatenMonster.getPosition();
      text(monsterScore, position.x, position.y);
    } else {
      pacman.draw();
    }
  }
}
// タイトル画面
public class Title implements Scene {
  protected PImage logoImage = loadImage("images/logo.png");
  protected PImage pressButonImage = loadImage("images/press_button.png");
  protected PImage copyrightImage = loadImage("images/copyright.png");
  protected Timer lightTimer1 = new Timer(30); // タイマー
  protected Timer lightTimer2 = new Timer(15); // タイマー
  protected boolean lightAppear = true;
  protected boolean jpEn = false;

  protected Timer startTimer = new Timer(10); // タイマー
  protected boolean startAppear = true;
  protected int startCount = 0;
  protected TitleBGM titlebgm = new TitleBGM(minim); // BGM
  protected int position; // BGMの再生位置

  private final FreeCharacter[] freeCharacters = {
    new FreeCharacter(new PVector(-20, SCREEN_SIZE.y * 0.08f - 17), 0, 2.3f, "player"), 
    new FreeCharacter(new PVector(-20, SCREEN_SIZE.y * 0.08f - 17), 0, 2.3f, "fujix"), 
    new FreeCharacter(new PVector(-20, SCREEN_SIZE.y * 0.08f - 17), 0, 2.3f, "ito"), 
    new FreeCharacter(new PVector(-20, SCREEN_SIZE.y * 0.08f - 17), 0, 2.3f, "arai"), 
    new FreeCharacter(new PVector(-20, SCREEN_SIZE.y * 0.08f - 17), 0, 2.3f, "ohya")
  };

  public void update() {
    titlebgm.play();

    if (Input.anyButtonPress()) {
      position = titlebgm.getPos();
      titlebgm.stop();
      SceneManager.setScene(new Rule(position));
    }
  }

  public void draw() {
    background(200, 240, 255);
    noStroke();
    rectMode(CENTER);
    imageMode(CENTER);
    textAlign(CENTER, CENTER);

    image(logoImage, SCREEN_SIZE.x / 2, 167);

    // タイマー
    if (lightAppear == true) {
      fill(0);
      textFont(font2, 40);
      if (jpEn == false) {
        text("ボタンをおしてね!", SCREEN_SIZE.x / 2, 330);
      } else {
        image(pressButonImage, SCREEN_SIZE.x / 2, 335);
      }
      if (lightTimer1.update()) {
        lightAppear = false;
        jpEn = !jpEn;
      }
    }

    if (lightAppear == false) {
      if (lightTimer2.update())
        lightAppear = true;
    }

    fill(0, 0, 159);
    textFont(font2, 22.5f);
    text("ランキング", SCREEN_SIZE.x * 0.35f, 395);
    text("スコア", SCREEN_SIZE.x * 0.65f, 395);
    fill(0);
    rect(SCREEN_SIZE.x / 2, 417.5f, SCREEN_SIZE.x * 0.7f, 1);
    textFont(font2, 30);
    for (int i = 0; i < 10; i++) {
      text(i + 1, SCREEN_SIZE.x * 0.35f, 430 + i * 30);
      text(Record.getRanking(i + 1), SCREEN_SIZE.x * 0.65f, 430 + i * 30);
      rect(SCREEN_SIZE.x / 2, 447.5f + i * 30, SCREEN_SIZE.x * 0.7f, 1);
    }
    image(copyrightImage, SCREEN_SIZE.x / 2, 790);

    for (int i = 0; i < freeCharacters.length; i++) {
      if (startCount > i) {
        freeCharacters[i].move();
        freeCharacters[i].update();
        freeCharacters[i].draw();
        if (freeCharacters[i].getDirection() == 0 && freeCharacters[i].position.x >= SCREEN_SIZE.x / 2 + logoImage.width / 2 + 15) {
          freeCharacters[i].setDirection(3);
        } else if (freeCharacters[i].getDirection() == 3 && freeCharacters[i].position.y >= SCREEN_SIZE.y * 0.08f + logoImage.height + 16) {
          freeCharacters[i].setDirection(2);
        } else if (freeCharacters[i].getDirection() == 2 && freeCharacters[i].position.x <= SCREEN_SIZE.x / 2 - logoImage.width / 2 - 15) {
          freeCharacters[i].setDirection(1);
        } else if (freeCharacters[i].getDirection() == 1 && freeCharacters[i].position.y <= SCREEN_SIZE.y * 0.08f - 15) {
          freeCharacters[i].setDirection(0);
        }
      }
    }


    // タイマー
    if (startAppear == true) {
      if (startTimer.update()) {
        startAppear = false;
        startCount ++;
      }
    }

    if (startAppear == false) {
      if (startTimer.update())
        startAppear = true;
    }
  }
}
// アニメーション
public class Animation {
  protected PImage[] images;     // アニメーション画像
  protected PVector size;        // 画像サイズ
  protected int cur = 0;         // 現在のアニメーション番号
  protected int number;          // アニメーションの数
  protected Timer intervalTimer; // インターバルタイマー

  public Animation(String imageName) {
    // 画像ファイルの存在確認
    for (this.number = 0; ; this.number++) {
      File imageFile = new File(dataPath(imageName + "-" + number + ".png"));
      if (!imageFile.exists())
        break;
    }

    // 画像ファイル読み込み
    this.images = new PImage[number];
    for (int i = 0; i < number; i++)
      this.images[i] = loadImage(imageName + "-" + i + ".png");
    size = new PVector(images[0].width, images[0].height);

    // インターバル読み込み
    String[] intervalText = loadStrings(imageName + "-interval.txt");
    this.intervalTimer = new Timer(PApplet.parseInt(intervalText[0]));
  }

  // アニメーションを更新しアニメーションの終端ならばtrueを返す
  public boolean update() {
    if (intervalTimer.update()) {
      cur++;
      if (cur >= number) {
        cur = 0;
        return true;
      }
    }

    return false;
  }

  // 初期状態にリセット
  public void reset() {
    cur = 0;
    intervalTimer.reset();
  }

  // 画像を取得
  public PImage getImage() {
    return images[cur];
  }

  // 画像サイズを取得
  public PVector getSize() {
    return size;
  }
}

// タイマー
public class Timer {
  protected int time;     // 設定時間
  protected int left;     // 残り時間
  protected boolean loop; // タイマーを繰り返すか

  public Timer(int time) {
    this.time = time;
    this.left = time;
    this.loop = true;
  }

  public Timer(int time, boolean loop) {
    this.time = time;
    this.left = time;
    this.loop = loop;
  }

  public int getTime() {
    return this.time;
  }

  public void setTime(int time) {
    this.time = time;
    this.left = time;
  }

  public int getLeft() {
    return this.left;
  }

  // 設定時間が経過したらtrueを返す
  public boolean update() {
    if (left <= 0) {
      if (loop) left = time;
      return true;
    } else {
      left--;
      return false;
    }
  }

  // リセット
  public void reset() {
    left = time;
  }
}

// スコアの記録
public static class Record {
  public static final int RANK_NUM = 10; // ランキングの数

  protected static int[] ranking = new int[RANK_NUM]; // ランキング
  public static String filePath; // ランキングファイルパス

  // 指定されたランクのスコアを返す (+なら上から、-なら下からの順位を参照)
  public static int getRanking(int rank) {
    if (0 < rank && rank <= RANK_NUM)
      return ranking[rank - 1];
    else if (-RANK_NUM <= rank && rank < 0)
      return ranking[RANK_NUM + rank];
    else
      return 0;
  }

  // ランキングに設定する
  public static int setRanking(int score) {
    for (int i = 0; i < RANK_NUM; i++) {
      if (score >= Record.ranking[i]) {
        // ランキングをずらす
        for (int j = RANK_NUM - 1; j > i; j--)
          Record.ranking[j] = Record.ranking[j - 1];

        ranking[i] = score;
        saveRanking();

        return i + 1;
      }
    }

    return 0;
  }

  // ファイルパス設定
  public static void setFilePath(String filePath) {
    Record.filePath = filePath;
    loadRanking();
  }

  // ハイスコアの読み込み
  public static void loadRanking() {
    String[] scoreData = loadStrings(new File(filePath)); // ハイスコアをロード

    for (int i = 0; i < RANK_NUM; i++) {
      int score = PApplet.parseInt(scoreData[i]);
      Record.ranking[i] = score;
    }
  }

  // ハイスコアの保存
  public static void saveRanking() {
    String[] scoreData = new String[RANK_NUM];
    for (int i = 0; i < RANK_NUM; i++) {
      scoreData[i] = str(ranking[i]);
    }

    saveStrings(new File(filePath), scoreData);
  }
}

// 設定
public class Setting {
  protected String filePath;
  protected HashMap<String, String> settings = new HashMap<String, String>();

  public Setting(String filePath) {
    this.filePath = filePath;

    String[] lines = loadStrings(filePath);
    for (String line : lines) {
      String[] item = split(line, ',');
      settings.put(item[0], item[1]);
    }
  }

  // 値の取得
  public String getString(String key) {
    if (settings.containsKey(key))
      return settings.get(key);
    else
      return "";
  }

  public String getString(String key, String defaultValue) {
    if (settings.containsKey(key))
      return settings.get(key);
    else
      return defaultValue;
  }

  public int getInt(String key) {
    if (settings.containsKey(key))
      return PApplet.parseInt(settings.get(key));
    else
      return 0;
  }

  public int getInt(String key, int defaultValue) {
    if (settings.containsKey(key))
      return PApplet.parseInt(settings.get(key));
    else
      return defaultValue;
  }

  public float getFloat(String key) {
    if (settings.containsKey(key))
      return PApplet.parseFloat(settings.get(key));
    else
      return 0;
  }

  public float getFloat(String key, float defaultValue) {
    if (settings.containsKey(key))
      return PApplet.parseFloat(settings.get(key));
    else
      return defaultValue;
  }

  // 値の設定
  public void setString(String key, String value) {
    settings.put(key, value);
  }

  public void setInt(String key, int value) {
    settings.put(key, str(value));
  }

  public void setFloat(String key, float value) {
    settings.put(key, str(value));
  }

  // 保存
  public void save() {
    int i = 0;
    String[] strings = new String[settings.size()];

    for (String key : settings.keySet())
      strings[i++] += key + "," + settings.get(key) + "\n";

    saveStrings(filePath, strings);
  }
}
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "pacman_game" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
