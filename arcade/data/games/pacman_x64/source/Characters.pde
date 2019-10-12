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
