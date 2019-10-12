import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

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

public PVector screenSize = new PVector(448, 496);
public PFont font;
public Minim minim;

public void setup() {
  

  font = loadFont("fonts/NuAnkoMochi-Reg-20.vlw"); // フォント
  minim = new Minim(this); // サウンド

  // ハイスコアをロード
  String dataName = "ranking.txt";
  Record.setFilePath(dataPath(dataName));
  Record.loadRanking();

  Input.setInputInterface(new KeyboardInput()); // 入力設定
  SceneManager.setScene(new Title()); // タイトル画面をロード
}

public void draw() {
  // 座標系設定
  float windowScale = 1;
  //float windowScale = displayHeight / screenSize.y; ←激重
  //scale(windowScale);
  translate((displayWidth / windowScale - screenSize.x) / 2, (displayHeight / windowScale - screenSize.y) / 2);

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

  protected Character(PVector position, int direction, float speed, String characterName) {
    super(position);

    this.startPosition = position.copy();
    this.direction = direction;
    this.nextDirection = direction;
    this.startDirection = direction;
    this.speed = speed;

    // アニメーション
    for (int i = 0; i < 4; i++)
      animations[i] = new Animation(characterName + "-" + i);
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
  public void move(Map map) {
    if (canMove(map, nextDirection))
      direction = nextDirection;

    if (canMove(map, direction)) {
      position.add(getDirectionVector(direction).mult(speed));

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
  }

  // 特定の方向へ移動できるか
  public boolean canMove(Map map, int aimDirection) {
    PVector check = getDirectionVector(aimDirection); // 壁かどうかの判定に使用する座標

    for (; check.mag() <= getDirectionVector(aimDirection).mult(speed).mag(); check.add(getDirectionVector(aimDirection))) {
      MapObject mapObject = map.getObject(PVector.add(position, check));
      if (mapObject == MapObject.Wall || mapObject == MapObject.MonsterDoor)
        return false;
    }

    return true;
  }

  // リセット
  public void reset() {
    position = startPosition.copy();
    direction = startDirection;
    nextDirection = direction;
  }

  // 更新
  public void update(Map map) {
    if (canMove(map, direction))
      animations[direction].update();
  }

  // 画面描画
  public void draw() {
    PVector minPostision = getMinPosition();
    image(animations[direction].getImage(), minPostision.x, minPostision.y);
  }
}
// パックマン
public class Pacman extends Character {
  public Pacman(PVector position, int direction, float speed) {
    super(position, direction, speed, "pacman");
  }
}

// アカベエ
public class Akabei extends Monster {
  public Akabei(PVector position, int direction, HashMap<MonsterSpeed, Float> speeds) {
    super(position, direction, speeds, "akabei");
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

// アオスケ
public class Aosuke extends Monster {
  public Aosuke(PVector position, int direction, HashMap<MonsterSpeed, Float> speeds) {
    super(position, direction, speeds, "aosuke");
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
        aimPoint = stage.pacman.getPosition().mult(2);
        aimPoint.sub(stage.monsters.get(0).getPosition());
        nextDirection = getAimDirection(stage.map, aimPoint);
        break;

      default:
        break;
      }
    }
  }
}

// ピンキー
public class Pinky extends Monster {
  public Pinky(PVector position, int direction, HashMap<MonsterSpeed, Float> speeds) {
    super(position, direction, speeds, "pinky");
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
        aimPoint = stage.pacman.getPosition();
        aimPoint.add(directionVector.x * stage.pacman.size.x, directionVector.y * stage.pacman.size.y);
        nextDirection = getAimDirection(stage.map, aimPoint);
        break;

      default:
        break;
      }
    }
  }
}

// グズタ
public class Guzuta extends Monster {
  public Guzuta(PVector position, int direction, HashMap<MonsterSpeed, Float> speeds) {
    super(position, direction, speeds, "guzuta");
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
        // パックマンから半径260px外ではアカベイと同じ追跡方法
        if (position.dist(stage.pacman.position) > 260) {
          nextDirection = getAimDirection(stage.map, stage.pacman.getPosition());
        }

        // 半径260px内ではランダムに動く
        else {
          aimPoint = new PVector(position.x + random(-1, 1), position.y + random(-1, 1));
          nextDirection = getAimDirection(stage.map, aimPoint);
        }
        break;

      default:
        break;
      }
    }
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
    return this.position.copy();
  }

  public void setPosition(PVector position) {
    this.position = position.copy();
  }

  public PVector getSize() {
    return this.size.copy();
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

    this.animation = new Animation(itemName);
    this.size = animation.getSize();
  }

  // 更新
  public void update() {
    animation.update();
  }

  // 画面描画
  public void draw() {
    PVector minPostision = getMinPosition();
    image(animation.getImage(), minPostision.x, minPostision.y);
  }
}
// 入力のインターフェース
public abstract class InputInterface {
  // 前回の状態
  public boolean prevRight = false;
  public boolean prevUp = false;
  public boolean prevLeft = false;
  public boolean prevDown = false;
  public boolean prevButtonA = false;
  public boolean prevButtonB = false;
  public boolean prevButtonC = false;

  public abstract boolean right();   // →
  public abstract boolean up();      // ↑
  public abstract boolean left();    // ←
  public abstract boolean down();    // ↓
  public abstract boolean buttonA(); // A
  public abstract boolean buttonB(); // B
  public abstract boolean buttonC(); // C

  public boolean rightPress() {
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

  public boolean upPress() {
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

  public boolean leftPress() {
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

  public boolean downPress() {
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

  public boolean buttonAPress() {
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

  public boolean buttonBPress() {
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
  
  public boolean buttonCPress() {
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

  public boolean rightRelease() {
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

  public boolean upRelease() {
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

  public boolean leftRelease() {
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

  public boolean downRelease() {
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

  public boolean buttonARelease() {
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

  public boolean buttonBRelease() {
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
  
  public boolean buttonCRelease() {
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
}

// キーボードからの入力
public class KeyboardInput extends InputInterface {
  public boolean right() {
    if (keyPressed && keyCode == RIGHT) {
      return true;
    } else {
      return false;
    }
  }

  public boolean up() {
    if (keyPressed && keyCode == UP) {
      return true;
    } else {
      return false;
    }
  }

  public boolean left() {
    if (keyPressed && keyCode == LEFT) {
      return true;
    } else {
      return false;
    }
  }

  public boolean down() {
    if (keyPressed && keyCode == DOWN) {
      return true;
    } else {
      return false;
    }
  }

  public boolean buttonA() {
    if (keyPressed && key == 'z') {
      return true;
    } else {
      return false;
    }
  }

  public boolean buttonB() {
    if (keyPressed && key == 'x') {
      return true;
    } else {
      return false;
    }
  }
  
  public boolean buttonC() {
    if (keyPressed && key == 'c') {
      return true;
    } else {
      return false;
    }
  }
}

// アーケードからの入力
public class ArcadeInput extends InputInterface {
  public boolean right() {
    if (keyPressed && key == 'a') {
      return true;
    } else {
      return false;
    }
  }

  public boolean up() {
    if (keyPressed && key == 'b') {
      return true;
    } else {
      return false;
    }
  }

  public boolean left() {
    if (keyPressed && key == 'c') {
      return true;
    } else {
      return false;
    }
  }

  public boolean down() {
    if (keyPressed && key == 'd') {
      return true;
    } else {
      return false;
    }
  }

  public boolean buttonA() {
    if (keyPressed && key == 'e') {
      return true;
    } else {
      return false;
    }
  }

  public boolean buttonB() {
    if (keyPressed && key == 'f') {
      return true;
    } else {
      return false;
    }
  }
  
  public boolean buttonC() {
    if (keyPressed && key == 'g') {
      return true;
    } else {
      return false;
    }
  }
}

// 入力
public static class Input {
  protected static InputInterface inputInterface;

  public static void setInputInterface(InputInterface inputInterface) {
    Input.inputInterface = inputInterface;
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

  public static boolean rightPress() {
    return inputInterface.rightPress();
  }

  public static boolean upPress() {
    return inputInterface.upPress();
  }

  public static boolean leftPress() {
    return inputInterface.leftPress();
  }

  public static boolean downPress() {
    return inputInterface.downPress();
  }

  public static boolean buttonAPress() {
    return inputInterface.buttonAPress();
  }

  public static boolean buttonBPress() {
    return inputInterface.buttonBPress();
  }
  
  public static boolean buttonCPress() {
    return inputInterface.buttonCPress();
  }

  public static boolean rightRelease() {
    return inputInterface.rightRelease();
  }

  public static boolean upRelease() {
    return inputInterface.upRelease();
  }

  public static boolean leftRelease() {
    return inputInterface.leftRelease();
  }

  public static boolean downRelease() {
    return inputInterface.downRelease();
  }

  public static boolean buttonARelease() {
    return inputInterface.buttonARelease();
  }

  public static boolean buttonBRelease() {
    return inputInterface.buttonBRelease();
  }
  
  public static boolean buttonCRelease() {
    return inputInterface.buttonCRelease();
  }
}
// マップ内のオブジェクトの種類
public enum MapObject {
  Wall,       // 壁
  Route,      // 通路
  MonsterDoor // 敵出入口
}

// マップ
public class Map {
  protected MapObject[][] objects; // マップ内のオブジェクト
  protected PVector releasePoint;  // 出撃地点
  protected PVector returnPoint;   // 帰還地点
  protected PImage image;          // 画像ファイル
  protected PVector size;          // 画像サイズ

  public Map(String mapName) {
    // 画像ファイル読み込み
    this.image = loadImage("stages/" + mapName + "-image.png");
    this.size = new PVector(image.width, image.height);
    this.objects = new MapObject[image.width][image.height];

    // マップファイル読み込み
    PImage mapImage = loadImage("stages/" + mapName + "-map.png");
    mapImage.loadPixels();

    for (int y = 0; y < mapImage.height; y++) {
      for (int x = 0; x < mapImage.width; x++) {
        int pixel = mapImage.pixels[y * mapImage.width + x];

        // 壁
        if (pixel == color(255, 255, 255)) {
          objects[x][y] = MapObject.Wall;
        }

        // 敵出入口
        else if (pixel == color(0, 255, 0)) {
          objects[x][y] = MapObject.MonsterDoor;
        }

        // 通路
        else {
          objects[x][y] = MapObject.Route;
        }

        // 出撃地点
        if (pixel == color(255, 0, 255)) {
          releasePoint = new PVector(x, y);
        }

        // 帰還地点
        else if (pixel == color(255, 127, 0)) {
          returnPoint = new PVector(x, y);
        }
      }
    }
  }

  public PVector getReleasePoint() {
    return this.releasePoint.copy();
  }

  public PVector getReturnPoint() {
    return this.returnPoint.copy();
  }

  public PVector getSize() {
    return this.size.copy();
  }

  public MapObject getObject(float x, float y) {
    return this.objects[round(x + size.x) % PApplet.parseInt(size.x)][round(y + size.y) % PApplet.parseInt(size.y)];
  }

  public MapObject getObject(PVector v) {
    return this.objects[round(v.x + size.x) % PApplet.parseInt(size.x)][round(v.y + size.y) % PApplet.parseInt(size.y)];
  }

  // 画面描画
  public void draw() {
    image(image, 0, 0);
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
  protected int ijikeStatus = 0;                             // 0:通常 1:終わりそう
  protected Animation[] ijikeAnimations = new Animation[2];  // イジケ時のアニメーション
  protected Animation[] returnAnimations = new Animation[4]; // 帰還時のアニメーション
  protected HashMap<MonsterSpeed, Float> speeds;

  protected Monster(PVector position, int direction, HashMap<MonsterSpeed, Float> speeds, String characterName) {
    super(position, direction, speeds.get(MonsterSpeed.Wait), characterName);
    this.speeds = speeds;

    // イジケ時のアニメーション
    this.ijikeAnimations[0] = new Animation("ijike-0");
    this.ijikeAnimations[1] = new Animation("ijike-1");

    // 帰還時のアニメーション
    for (int i = 0; i < 4; i++)
      this.returnAnimations[i] = new Animation("return-" + i);
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
      ijikeStatus = 0;
      ijikeAnimations[0].reset();
      ijikeAnimations[1].reset();
    }
  }

  public int getIjikeStatus() {
    return this.ijikeStatus;
  }

  public void setIjikeStatus(int ijikeStatus) {
    this.ijikeStatus = ijikeStatus;
  }

  // 特定の方向へ移動できるか
  public boolean canMove(Map map, int aimDirection) {
    PVector check = getDirectionVector(aimDirection); // 壁かどうかの判定に使用する座標

    for (; check.mag() <= getDirectionVector(aimDirection).mult(speed).mag(); check.add(getDirectionVector(aimDirection))) {
      MapObject mapObject = map.getObject(PVector.add(check, position));
      if (mapObject == MapObject.Wall || status != MonsterStatus.Release && status != MonsterStatus.Return && mapObject == MapObject.MonsterDoor)
        return false;
    }

    return true;
  }

  // 目標地点に進むための方向を返す
  protected int getAimDirection(Map map, PVector point) {
    int aimDirection = 0;
    float distanceMin = map.size.mag();
    boolean canForward = canMove(map, direction);

    for (int i = 0; i < 4; i++) {
      // 前進できるなら後退しない
      if (canForward)
        if (i == 2) continue;

      // 各方向に進んだときに目標地点との距離が最短となる方向を探す
      int checkDirection = (direction + i) % 4;

      PVector checkPosition = position.copy();
      checkPosition.add(getDirectionVector(checkDirection).mult(speed));

      if (canMove(map, checkDirection) && checkPosition.dist(point) < distanceMin) {
        aimDirection = checkDirection;
        distanceMin = checkPosition.dist(point);
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
      if (!canMove(stage.map, direction))
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
      // 帰還中は帰還地点を目指す
      aimPoint = stage.map.getReturnPoint();
      nextDirection = getAimDirection(stage.map, aimPoint);
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
      if (round(position.x) == round(map.getReleasePoint().x) && round(position.y) == round(map.getReleasePoint().y)) {
        setStatus(MonsterStatus.Active);
      }
      break;

    case Return:
      if (round(position.x) == round(map.getReturnPoint().x) && round(position.y) == round(map.getReturnPoint().y)) {
        setStatus(MonsterStatus.Release);
      }
      break;

    default:
      break;
    }

    // アニメーションを更新
    if (canMove(map, direction)) {
      switch (status) {
      case Wait:
      case Release:
      case Active:
        if (mode == MonsterMode.Ijike) {
          ijikeAnimations[ijikeStatus].update();
        } else {
          animations[direction].update();
        }
        break;

      case Return:
        returnAnimations[direction].update();
        break;
      }
    }
  }

  // 画面描画
  public void draw() {
    PVector minPostision = getMinPosition();

    switch (status) {
    case Wait:
    case Release:
    case Active:
      if (mode == MonsterMode.Ijike) {
        image(ijikeAnimations[ijikeStatus].getImage(), minPostision.x, minPostision.y);
      } else {
        super.draw();
      }
      break;

    case Return:
      image(returnAnimations[direction].getImage(), minPostision.x, minPostision.y);
      break;
    }
  }
}
// スコアの記録
public static class Record {
  protected static final int RANK_NUM = 10; // ランキングの数

  protected static int[] ranking;   // ランキング
  protected static String filePath; // ランキングファイルパス

  // 指定されたランクのスコアを返す (+なら上から、-なら下からの順位を参照)
  public static int getRanking(int rank) {
    if (0 < rank && rank <= Record.RANK_NUM) {
      return Record.ranking[rank - 1];
    } else if (-Record.RANK_NUM <= rank && rank < 0) {
      return Record.ranking[Record.RANK_NUM + rank];
    } else {
      return 0;
    }
  }

  public static void setRanking(int score) {
    for (int i = 0; i < Record.RANK_NUM; i++) {
      if (Record.ranking[i] < score) {
        for (int j = Record.RANK_NUM - 1; j < i; j--) {
          Record.ranking[j] = Record.ranking[j - 1];
        }
        ranking[i] = score;
        break;
      }
    }
  }

  // ファイルパス読み込み
  public static void setFilePath(String filePath) {
    Record.filePath = filePath;
  }

  // ハイスコアの読み込み
  public static void loadRanking() {
    Record.ranking = new int[10];
    File dataFile = new File(Record.filePath);
    String[] scoreData = loadStrings(dataFile); // ハイスコアをロード
    for (int i = 0; i < Record.RANK_NUM; i++) {
      int score = PApplet.parseInt(scoreData[i]);
      Record.ranking[i] = score;
    }
  }

  // ハイスコアの保存
  public static void saveRanking() {
    File dataFile = new File(Record.filePath);
    String[] scoreData = new String[Record.RANK_NUM];
    for (int i = 0; i < Record.RANK_NUM; i++) {
      scoreData[i] = str(Record.ranking[i]);
    }
    saveStrings(dataFile, scoreData);
  }
}
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



//BGM
public class BGM {
  protected Minim minim;
  protected AudioPlayer player;
  //protected int length; 

  public BGM(Minim minim) {
    // 音楽ファイル読み込み
    this.minim = minim;
    player = this.minim.loadFile("sounds/schoolSong.mp3");
    //length = player.length();
    player.cue(3500);
  }

  // 再生
  public void play() {
    if (player.position() >= 52000) {
      player.cue(4100);
    }
    player.play();
  }

  // 停止
  public void stop() {
    player.close();
    minim.stop();
    //super.stop();
  }
}

// 効果音
public class SoundEffect {
  protected final float VOLUME = 0.1f; // 音量

  protected final float P1 = 787.330f; // 音程
  protected final float P2 = 864.255f;
  protected final float P3 = 908.456f;
  protected final float P4 = 998.991f;
  protected final float P5 = 1100.000f;
  protected final float P6 = 1212.767f;
  protected final float P7 = 1276.562f;
  protected final float P8 = 1409.659f;

  protected final float P9 = 174.614f;
  protected final float P10 = 195.998f;
  protected final float P11 = 220;

  protected AudioOutput out;

  public SoundEffect(Minim minim) {
    out = minim.getLineOut();
  }

  // パワーエサを食べたとき
  public void eatPowerFood() {  
    float soundWidth = 0.02f, cycle = 0.16f; 
    int i;
    for (i = 0; i < 4; i++) {
      out.playNote(soundWidth * 0 + cycle * i, soundWidth, new SquareInstrument(P1, VOLUME, out));
      out.playNote(soundWidth * 1 + cycle * i, soundWidth, new SquareInstrument(P2, VOLUME, out));
      out.playNote(soundWidth * 2 + cycle * i, soundWidth, new SquareInstrument(P3, VOLUME, out));
      out.playNote(soundWidth * 3 + cycle * i, soundWidth, new SquareInstrument(P4, VOLUME, out));
      out.playNote(soundWidth * 4 + cycle * i, soundWidth, new SquareInstrument(P5, VOLUME, out));
      out.playNote(soundWidth * 5 + cycle * i, soundWidth, new SquareInstrument(P6, VOLUME, out));
      out.playNote(soundWidth * 6 + cycle * i, soundWidth, new SquareInstrument(P7, VOLUME, out));
      out.playNote(soundWidth * 7 + cycle * i, soundWidth, new SquareInstrument(P8, VOLUME, out));
    }
  }

  // 普通のエサを食べたとき
  public void eatFood(boolean flag) {
    float soundWidth = 0.015f;
    if (flag) {
      out.playNote(soundWidth * 0, soundWidth, new SquareInstrument(P9, VOLUME, out));
      out.playNote(soundWidth * 1, soundWidth, new SquareInstrument(P10, VOLUME, out));
      out.playNote(soundWidth * 2, soundWidth * 2, new SquareInstrument(P11, VOLUME, out));
    } else {
      out.playNote(soundWidth * 0, soundWidth * 2, new SquareInstrument(P11, VOLUME, out));
      out.playNote(soundWidth * 2, soundWidth, new SquareInstrument(P10, VOLUME, out));
      out.playNote(soundWidth * 3, soundWidth, new SquareInstrument(P9, VOLUME, out));
    }
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
  Start, // 開始
    Play, // ゲーム
    Eat, // 敵を食べたときの硬直
    Clear, // クリア
    Die, // 敵に食べられた
    Finish // 終了
}

// ステージ
public class Stage implements Scene {
  protected Map map;       // マップ
  protected Pacman pacman; // パックマン
  protected ArrayList<Monster> monsters = new ArrayList<Monster>(); // 敵
  protected ArrayList<Item> foods = new ArrayList<Item>();          // エサ
  protected ArrayList<Item> powerFoods = new ArrayList<Item>();     // パワーエサ

  protected int score = 0; // スコア
  protected int life = 3;  // 残機の数

  protected StageStatus status = StageStatus.Start; // 状態
  protected int frame = 0;           // 経過フレーム
  protected MonsterMode monsterMode; // 敵のモード
  protected HashMap<MonsterMode, Integer> modeTimes =  new HashMap<MonsterMode, Integer>(); // 各モードの時間 [f]
  protected Timer modeTimer;         // モード切り替え用タイマー
  protected int releaseInterval;     // 排出間隔 [f]
  protected int monsterEatCount = 0; // イジケ時に敵を食べた個数

  protected SoundEffect se = new SoundEffect(minim); // 効果音
  protected boolean eatSEFlag = true; // 普通のエサを食べたときの効果音切り替えフラグ
  protected BGM bgm = new BGM(minim); // BGM

  public Stage(String mapName) {
    this.map = new Map(mapName);

    // 設定ファイル読み込み
    HashMap<String, String> setting = new HashMap<String, String>();
    String[] settingLines = loadStrings(dataPath("stages/" + mapName + "-setting.txt"));

    for (String settingLine : settingLines) {
      String[] curSetting = split(settingLine, ',');
      setting.put(curSetting[0], curSetting[1]);
    }

    this.releaseInterval = PApplet.parseInt(setting.get("release_interval"));

    this.modeTimes.put(MonsterMode.Rest, PApplet.parseInt(setting.get("rest_time")));
    this.modeTimes.put(MonsterMode.Chase, PApplet.parseInt(setting.get("chase_time")));
    this.modeTimes.put(MonsterMode.Ijike, PApplet.parseInt(setting.get("ijike_time")));

    this.monsterMode = MonsterMode.Rest;
    this.modeTimer = new Timer(modeTimes.get(monsterMode));

    HashMap<MonsterSpeed, Float> monsterSpeeds = new HashMap<MonsterSpeed, Float>();
    monsterSpeeds.put(MonsterSpeed.Wait, PApplet.parseFloat(setting.get("monster_wait_speed")));
    monsterSpeeds.put(MonsterSpeed.Release, PApplet.parseFloat(setting.get("monster_release_speed")));
    monsterSpeeds.put(MonsterSpeed.Return, PApplet.parseFloat(setting.get("monster_return_speed")));
    monsterSpeeds.put(MonsterSpeed.Rest, PApplet.parseFloat(setting.get("monster_rest_speed")));
    monsterSpeeds.put(MonsterSpeed.Chase, PApplet.parseFloat(setting.get("monster_chase_speed")));
    monsterSpeeds.put(MonsterSpeed.Ijike, PApplet.parseFloat(setting.get("monster_ijike_speed")));

    // マップファイル読み込み
    ArrayList<PVector> monsterPositions = new ArrayList<PVector>();
    PImage mapImage = loadImage("stages/" + mapName + "-map.png");
    mapImage.loadPixels();

    for (int y = 0; y < mapImage.height; y++) {
      for (int x = 0; x < mapImage.width; x++) {
        int pixel = mapImage.pixels[y * mapImage.width + x];

        // パックマン
        if (pixel == color(255, 0, 0)) {
          int pacmanDirection = PApplet.parseInt(setting.get("pacman_direction"));
          float pacmanSpeed = PApplet.parseFloat(setting.get("pacman_speed"));
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
      }
    }

    int monsterDirection = PApplet.parseInt(setting.get("monster_direction"));
    this.monsters.add(new Akabei(monsterPositions.get(0), monsterDirection, monsterSpeeds));
    this.monsters.add(new Aosuke(monsterPositions.get(1), monsterDirection, monsterSpeeds));
    this.monsters.add(new Pinky(monsterPositions.get(2), monsterDirection, monsterSpeeds));
    this.monsters.add(new Guzuta(monsterPositions.get(3), monsterDirection, monsterSpeeds));

    this.draw();
  }

  public int getFrame() {
    return this.frame;
  }

  public int getScore() {
    return this.score;
  }

  public int getLife() {
    return this.life;
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

    // モンスター放出
    if (frame < releaseInterval * monsters.size() && frame % releaseInterval == 0)
      this.monsters.get(frame / releaseInterval).setStatus(MonsterStatus.Release);

    // モード切り替え
    if (modeTimer.update()) {
      switch (monsterMode) {
      case Rest:
        monsterMode = MonsterMode.Chase;
        modeTimer.setTime(modeTimes.get(MonsterMode.Chase));
        break;

      case Chase:
      case Ijike:
        monsterMode = MonsterMode.Rest;
        modeTimer.setTime(modeTimes.get(MonsterMode.Rest));
        break;
      }

      for (Monster monster : monsters)
        monster.setMode(monsterMode);
    }

    if (monsterMode == MonsterMode.Ijike && modeTimer.getLeft() == 120) {
      for (Monster monster : monsters)
        monster.setIjikeStatus(1);
    }

    // 敵の向きを決定
    for (Monster monster : monsters)
      monster.decideDirection(this);

    // 移動
    for (Monster monster : monsters)
      monster.move(map);
    pacman.move(map);

    // 更新
    pacman.update(map);

    for (Monster monster : monsters)
      monster.update(map);

    for (Item food : foods)
      food.update();

    for (Item powerFood : powerFoods)
      powerFood.update();

    // 当たり判定
    for (Iterator<Item> i = foods.iterator(); i.hasNext(); ) {
      Item food = i.next();

      if (pacman.isColliding(food)) {
        i.remove();

        // 音を鳴らす
        se.eatFood(eatSEFlag);
        eatSEFlag = !eatSEFlag;

        // スコア加算
        this.score += 10;
      }
    }

    for (Iterator<Item> i = powerFoods.iterator(); i.hasNext(); ) {
      Item powerFood = i.next();

      if (pacman.isColliding(powerFood)) {
        i.remove();

        // 音を鳴らす
        se.eatPowerFood();

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

    if (foods.isEmpty() && powerFoods.isEmpty()) {
      // ゲームクリア
      bgm.stop();
      SceneManager.setScene(new Result(score));
    }

    for (Iterator<Monster> i = monsters.iterator(); i.hasNext(); ) {
      Monster monster = i.next();

      if (pacman.isColliding(monster)) {
        switch (monster.getStatus()) {
        case Return:
          break;

        case Active:
          if (monster.getMode() == MonsterMode.Ijike) {
            // モンスターを食べた時のスコア
            monsterEatCount++;
            score += pow(2, monsterEatCount) * 100;
            monster.setStatus(MonsterStatus.Return);
            monster.setMode(MonsterMode.Rest);
            break;
          }

        default:
          if (life <= 0) {
            // ゲームオーバー
            bgm.stop();
            SceneManager.setScene(new Result(score));
          } else {
            // 残機を1つ減らしゲーム続行
            life--;
            println(life);

            // リセット
            pacman.reset();
            for (Monster m : monsters)
              m.reset();

            frame = 0;
            monsterMode = MonsterMode.Rest;
            modeTimer = new Timer(modeTimes.get(monsterMode));

            return;
          }
          break;
        }
      }
    }

    frame++;
  }

  // 画面描画
  public void draw() {
    background(0);
    map.draw();

    for (Item food : foods)
      food.draw();

    for (Item powerFood : powerFoods)
      powerFood.draw();

    pacman.draw();

    for (Monster monster : monsters)
      monster.draw();

    // スコア表示
    fill(255);
    textAlign(RIGHT, BASELINE);
    textFont(font, 20);
    text("SCORE", 75, 180);
    text(score, 75, 200);
    text("HiSCORE", 465, 180);
    if (Record.getRanking(1) > score)
      text(Record.getRanking(1), 445, 200);
    else
      text(score, 445, 200);
      
    //BGMを再生
    bgm.play();
  }
}
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
// アニメーション
public class Animation {
  protected PImage[] images;     // アニメーション画像
  protected int cur = 0;         // 現在のアニメーション番号
  protected int number;          // アニメーションの数
  protected Timer intervalTimer; // インターバルタイマー

  public Animation(String imageName) {
    // 画像ファイルの存在確認
    this.number = 0;
    while (true) {
      File imageFile = new File(dataPath("images/" + imageName + "-" + number + ".png"));
      if (!imageFile.exists())
        break;

      this.number++;
    }

    // 画像ファイル読み込み
    this.images = new PImage[number];
    for (int i = 0; i < number; i++)
      this.images[i] = loadImage(dataPath("images/" + imageName + "-" + i + ".png"));

    // インターバル読み込み
    String[] intervalText = loadStrings(dataPath("images/" + imageName + "-interval.txt"));
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
    return images[cur].copy();
  }

  // 画像サイズを取得
  public PVector getSize() {
    return new PVector(images[0].width, images[0].height);
  }
}

public class Timer {
  protected int time; // 設定時間
  protected int left; // 残り時間

  public Timer(int time) {
    this.time = time;
    this.left = time;
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
    left--;
    if (left < 0) {
      left = time;
      return true;
    } else {
      return false;
    }
  }

  // リセット
  public void reset() {
    left = time;
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
