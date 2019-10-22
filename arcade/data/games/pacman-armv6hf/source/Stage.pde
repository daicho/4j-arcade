import java.util.Iterator;

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
        color pixel = mapImage.pixels[y * mapImage.width + x];

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
