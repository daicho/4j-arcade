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
      int score = int(scoreData[i]);
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
