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
