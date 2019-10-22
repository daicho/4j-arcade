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
      if (t + 1 <= int(curSpeed) || !turnFlag && (aimDirection + direction) % 2 == 1)
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
