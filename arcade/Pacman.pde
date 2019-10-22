import java.util.Iterator;

// パックマン
public class Pacman implements Demo {
  protected PacmanMap map;       // マップ
  protected PacmanPlayer pacman; // パックマン
  protected ArrayList<PacmanCharacter> monsters = new ArrayList<PacmanCharacter>(); // 敵
  protected ArrayList<PacmanItem> foods = new ArrayList<PacmanItem>();              // エサ
  protected ArrayList<PacmanItem> powerFoods = new ArrayList<PacmanItem>();         // パワーエサ

  protected ArrayList<PVector> foodPositions = new ArrayList<PVector>();      // エサの座標
  protected ArrayList<PVector> powerFoodPositions = new ArrayList<PVector>(); // パワーエサの座標

  protected PFont font;

  public Pacman() {
    this.map = new PacmanMap();

    // マップファイル読み込み
    ArrayList<PVector> monsterPositions = new ArrayList<PVector>();
    PImage mapImage = loadImage("pacman/map.png");
    mapImage.loadPixels();

    for (int y = 0; y < mapImage.height; y++) {
      for (int x = 0; x < mapImage.width; x++) {
        color pixel = mapImage.pixels[y * mapImage.width + x];

        // パックマン
        if (pixel == color(255, 0, 0)) {
          this.pacman = new PacmanPlayer(new PVector(x, y), 3, 3);
        }

        // 敵
        else if (pixel == color(0, 0, 255)) {
          monsterPositions.add(new PVector(x, y));
        }

        // エサ
        else if (pixel == color(255, 255, 0)) {
          foodPositions.add(new PVector(x, y));
        }

        // パワーエサ
        else if (pixel == color(0, 255, 255)) {
          powerFoodPositions.add(new PVector(x, y));
        }
      }
    }

    // 敵
    this.monsters.add(new PacmanAkabei(monsterPositions.get(1), 1, 3));
    this.monsters.add(new PacmanPinky(monsterPositions.get(0), 1, 3));
    this.monsters.add(new PacmanAosuke(monsterPositions.get(3), 3, 3));
    this.monsters.add(new PacmanGuzuta(monsterPositions.get(2), 3, 3));

    // アイテム
    for (PVector foodPosition : foodPositions)
      foods.add(new PacmanItem(foodPosition, "food"));
    for (PVector powerFoodPosition : powerFoodPositions)
      foods.add(new PacmanItem(powerFoodPosition, "power_food"));

    font = createFont("pacman/NuKinakoMochi-Reg.otf", 10);
  }

  // ステージ内の状態を更新
  public void update() {
    pacman.decideDirection(map);
    pacman.move(map);

    for (PacmanCharacter monster : monsters) {
      monster.decideDirection(map);
      monster.move(map);
    }

    // 更新
    pacman.update(map);
    for (PacmanCharacter monster : monsters)
      monster.update(map);

    for (PacmanItem food : foods)
      food.update();

    for (PacmanItem powerFood : powerFoods)
      powerFood.update();

    // 当たり判定
    // ノーマルエサ
    for (Iterator<PacmanItem> i = foods.iterator(); i.hasNext(); ) {
      PacmanItem food = i.next();

      if (pacman.isColliding(food))
        i.remove();
    }

    // パワーエサ
    for (Iterator<PacmanItem> i = powerFoods.iterator(); i.hasNext(); ) {
      PacmanItem powerFood = i.next();

      if (pacman.isColliding(powerFood))
        i.remove();
    }
  }

  // 画面描画
  public void draw() {
    // 更新
    update();

    // マップ
    background(200, 240, 255);
    map.draw();

    pushMatrix();
    translate(0, 176);

    // アイテム
    for (PacmanItem food : foods)
      food.draw();
    for (PacmanItem powerFood : powerFoods)
      powerFood.draw();

    // キャラクター
    for (PacmanCharacter monster : monsters)
      monster.draw();
    pacman.draw();

    popMatrix();

    // 残基表示
    imageMode(CENTER);
    for (int i = 0; i < 2; i++)
      image(pacman.animations[3].images[0], i * 32 + 31, 701);

    // 枠表示
    rectMode(CENTER);
    stroke(27, 20, 100);
    strokeWeight(4);
    noFill();
    rect(width / 2, 418, 478, 630, 10);
  }
  
  // リセット
  public void reset() {
    // キャラクター
    pacman.reset();
    for (PacmanCharacter monster : monsters)
      monster.reset();

    // アイテム
    foods = new ArrayList<PacmanItem>();
    powerFoods = new ArrayList<PacmanItem>();

    for (PVector foodPosition : foodPositions)
      foods.add(new PacmanItem(foodPosition, "food"));
    for (PVector powerFoodPosition : powerFoodPositions)
      powerFoods.add(new PacmanItem(powerFoodPosition, "power_food"));
  }
}

// マップ内のオブジェクトの種類
public enum PacmanMapObject {
  Wall,  // 壁
  Route, // 通路
}

// マップ
public class PacmanMap {
  protected PacmanMapObject[][] objects; // マップ内のオブジェクト
  protected PImage image; // 画像ファイル
  protected PVector size; // 画像サイズ

  public PacmanMap() {
    // 画像ファイル読み込み
    this.image = loadImage("pacman/image.png");
    this.size = new PVector(image.width, image.height);
    this.objects = new PacmanMapObject[image.width][image.height];

    // マップファイル読み込み
    PImage mapImage = loadImage("pacman/map.png");
    mapImage.loadPixels();

    for (int y = 0; y < mapImage.height; y++) {
      for (int x = 0; x < mapImage.width; x++) {
        color mapPixel = mapImage.pixels[y * mapImage.width + x];

        if (mapPixel == color(255, 255, 255))
          objects[x][y] = PacmanMapObject.Wall; // 壁
        else
          objects[x][y] = PacmanMapObject.Route; // 通路
      }
    }
  }

  public PVector getSize() {
    return this.size;
  }

  public PacmanMapObject getObject(float x, float y) {
    return this.objects[round(x + size.x) % int(size.x)][round(y + size.y) % int(size.y)];
  }

  public PacmanMapObject getObject(PVector v) {
    return this.objects[round(v.x + size.x) % int(size.x)][round(v.y + size.y) % int(size.y)];
  }

  // 画面描画
  public void draw() {
    imageMode(CENTER);
    image(image, width / 2, height / 2);
  }
}

// ゲーム内オブジェクトの基底クラス
public abstract class PacmanGameObject {
  protected PVector position; // 現在位置
  protected PVector size;     // 画像サイズ

  protected PacmanGameObject(PVector position) {
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
  public boolean isColliding(PacmanGameObject object) {
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
public class PacmanItem extends PacmanGameObject {
  protected PacmanAnimation animation; // アニメーション

  public PacmanItem(PVector position, String itemName) {
    super(position);

    this.animation = new PacmanAnimation(itemName);
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

// キャラクターの基底クラス
public abstract class PacmanCharacter extends PacmanGameObject {
  protected PVector startPosition; // 初期地点
  protected int direction;         // 向き (0:右 1:上 2:左 3:下)
  protected int nextDirection;     // 次に進む方向
  protected int startDirection;    // 初期方向
  protected float speed;           // 速さ [px/f]
  protected PacmanAnimation[] animations = new PacmanAnimation[4]; // アニメーション

  public PacmanCharacter(PVector position, int direction, float speed, String characterName) {
    super(position);

    this.startPosition = position.copy();
    this.direction = direction;
    this.nextDirection = direction;
    this.startDirection = direction;
    this.speed = speed;

    // アニメーション
    for (int i = 0; i < 4; i++)
      animations[i] = new PacmanAnimation(characterName + "-" + i);
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
  public void move(PacmanMap map) {
    // 曲がれたら曲がる、曲がれなかったら直進
    PVector forwardMove = canMove(map, direction);
    PVector nextMove = canMove(map, nextDirection);

    if (nextMove.mag() != 0 && (forwardMove.mag() == 0 || (direction + 2) % 4 != nextDirection))
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
  public PVector canMove(PacmanMap map, int aimDirection) {
    float curSpeed = speed;
    boolean turnFlag = false;
    PVector result = new PVector(0, 0);

    for (float t = 0; t < curSpeed; t++) {
      float moveDistance;
      PVector moveVector;
      PacmanMapObject mapObject;

      // 1マスずつ進みながらチェック
      if (t + 1 <= int(curSpeed) || !turnFlag && (aimDirection + direction) % 2 == 1)
        moveDistance = 1;
      else
        moveDistance = curSpeed - t;

      // 進みたい方向に進んでみる
      moveVector = getDirectionVector(aimDirection);
      moveVector.mult(moveDistance);
      result.add(moveVector);

      mapObject = map.getObject(PVector.add(position, result));
      if (mapObject != PacmanMapObject.Wall) {
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
        if (mapObject == PacmanMapObject.Wall)
          break;
      }
    }

    if (turnFlag)
      return result;
    else
      return new PVector(0, 0);
  }

  // 目標地点に進むための方向を返す
  protected int getAimDirection(PacmanMap map, PVector point) {
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
  public abstract void decideDirection(PacmanMap map);

  // リセット
  public void reset() {
    position = startPosition.copy();
    direction = startDirection;
    nextDirection = direction;
    for (PacmanAnimation animetion : animations)
      animetion.reset();
  }

  // アニメーションの更新
  protected void animationUpdate(PacmanAnimation animation, PacmanMap map) {
    if (canMove(map, direction).mag() != 0)
      animation.update();
  }

  // 更新
  public void update(PacmanMap map) {
    animationUpdate(animations[direction], map);
  }

  // 画面描画
  public void draw() {
    imageMode(CENTER);
    image(animations[direction].getImage(), position.x, position.y);
  }
}

// プレイヤー (パックマン)
public class PacmanPlayer extends PacmanCharacter {
  public PacmanPlayer(PVector position, int direction, float speed) {
    super(position, direction, speed, "player");
  }

  public void decideDirection(PacmanMap map) {
    PVector aimPoint = new PVector(random(0, map.size.x), random(0, map.size.y));
    nextDirection = getAimDirection(map, aimPoint);
  }
}

// 藤澤 (アカベエ)
public class PacmanAkabei extends PacmanCharacter {
  public PacmanAkabei(PVector position, int direction, float speed) {
    super(position, direction, speed, "fujix");
  }

  // 進む方向を決定する
  public void decideDirection(PacmanMap map) {
    // 右上を徘徊
    PVector aimPoint = new PVector(random(map.size.x / 2, map.size.x), random(0, map.size.y / 2));
    nextDirection = getAimDirection(map, aimPoint);
  }
}

// 伊藤 (アオスケ)
public class PacmanAosuke extends PacmanCharacter {
  public PacmanAosuke(PVector position, int direction, float speed) {
    super(position, direction, speed, "ito");
  }

  // 進む方向を決定する
  public void decideDirection(PacmanMap map) {
    // 右下を徘徊
    PVector aimPoint = new PVector(random(map.size.x / 2, map.size.x), random(map.size.y / 2, map.size.y));
    nextDirection = getAimDirection(map, aimPoint);
  }
}

// 荒井 (ピンキー)
public class PacmanPinky extends PacmanCharacter {
  public PacmanPinky(PVector position, int direction, float speed) {
    super(position, direction, speed, "arai");
  }

  // 進む方向を決定する
  public void decideDirection(PacmanMap map) {
    // 左上を徘徊
    PVector aimPoint = new PVector(random(0, map.size.x / 2), random(0, map.size.y / 2));
    nextDirection = getAimDirection(map, aimPoint);
  }
}

// 大矢 (グズタ)
public class PacmanGuzuta extends PacmanCharacter {
  public PacmanGuzuta(PVector position, int direction, float speed) {
    super(position, direction, speed, "ohya");
  }

  // 進む方向を決定する
  public void decideDirection(PacmanMap map) {
    // 左下を徘徊
    PVector aimPoint = new PVector(random(0, map.size.x / 2), random(map.size.y / 2, map.size.y));
    nextDirection = getAimDirection(map, aimPoint);
  }
}

// アニメーション
public class PacmanAnimation {
  protected PImage[] images;     // アニメーション画像
  protected PVector size;        // 画像サイズ
  protected int cur = 0;         // 現在のアニメーション番号
  protected int number;          // アニメーションの数
  protected Timer intervalTimer; // インターバルタイマー

  public PacmanAnimation(String imageName) {
    // 画像ファイルの存在確認
    for (this.number = 0; ; this.number++) {
      File imageFile = new File(dataPath("pacman/" + imageName + "-" + number + ".png"));
      if (!imageFile.exists())
        break;
    }

    // 画像ファイル読み込み
    this.images = new PImage[number];
    for (int i = 0; i < number; i++)
      this.images[i] = loadImage("pacman/" + imageName + "-" + i + ".png");
    size = new PVector(images[0].width, images[0].height);

    // インターバル読み込み
    String[] intervalText = loadStrings("pacman/" + imageName + "-interval.txt");
    this.intervalTimer = new Timer(int(intervalText[0]));
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
