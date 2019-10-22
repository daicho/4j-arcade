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
      int score = int(scoreData[i]);
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
      return int(settings.get(key));
    else
      return 0;
  }

  public int getInt(String key, int defaultValue) {
    if (settings.containsKey(key))
      return int(settings.get(key));
    else
      return defaultValue;
  }

  public float getFloat(String key) {
    if (settings.containsKey(key))
      return float(settings.get(key));
    else
      return 0;
  }

  public float getFloat(String key, float defaultValue) {
    if (settings.containsKey(key))
      return float(settings.get(key));
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
