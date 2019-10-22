public class RandomMino {

  private int nextMino1[] = new int[7];
  private int nextMino2[] = new int[14];
  private boolean firstFlag = false;
  private int q_point = 0;

  private void randomMino() {  //  次にくるブロックの生成
    int flag[] = new int[7];
    int rand;
    for (int i = 0; i < 7; i++) {
      while (true) {
        rand = (int)random(1, 8);
        if (flag[rand - 1] != 1) {
          flag[rand - 1] = 1;
          break;
        }
      }
      nextMino1[i] = rand;
    }
  }

  private void nextMino() {  //生成したブロックを格納
    if (firstFlag == false) {
      randomMino();
      for (int i = 0; i < 7; i++) {
        nextMino2[i] = nextMino1[i];
      }
      randomMino();
      for (int i = 0; i < 7; i++) {
        nextMino2[i+7] = nextMino1[i];
      }
      firstFlag = true;
    } else {

      if (q_point == 8) {
        randomMino();
        for (int i = 0; i < 7; i++) {
          nextMino2[i] = nextMino1[i];
        }
      } else {
        if (q_point == 0);
        randomMino();
        for (int i = 0; i < 7; i++) {
          nextMino2[i+7] = nextMino1[i];
        }
      }
    }
  }

  public int getNextMino() {  //格納したブロックを取り出す(取り出すと次に変わる)
    int next;
    if (q_point == 14)  q_point = 0;
    if (q_point == 0 || q_point == 8) nextMino();
    next = nextMino2[q_point];

    q_point++;
    return (next);
  }
}
