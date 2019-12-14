// プレイヤー (パックマン) //<>//
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
