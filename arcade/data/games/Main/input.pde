abstract class Input {

  public final int R_MOVE = 0; 
  public final int L_MOVE = 1;
  public final int R_TURN = 2;
  public final int L_TURN = 3;
  public final int HOLD   = 4;
  public final int S_DROP = 5;
  public final int H_DROP = 6;

  private final int INPUT_DELAY = 200;            // 次の入力を受け付けるまでの時間(ms)
  private final int MOVE_FAST_INPUT_DELAY = 20;   // 左右移動の速いほうの待ち時間

  public boolean state[];                          // 7種類のキーの状態 ON or OFF
  public boolean preStateMoveR;
  public boolean preStateMoveL;

  public int moveCount;                        // 連続で動いた回数

  protected  boolean keyState[];                   // 押されているキー
  private int wait[];                              // 7種類のキーの待ち時間
  private int waitMove;                            // moveとturnは左右でセットなので同じ時間を参照する
  private int waitTurn;

  // この２つのメソッドをコントローラーに合わせてオーバーライドすればいい
  abstract void checkInput();
  abstract void checkRelease();

  public Input() {
    state =  new boolean[7];
    keyState = new boolean[7];
    wait = new int[7];
    waitMove = 0;
    waitTurn = 0;
    preStateMoveR = false;
    preStateMoveL = false;
    moveCount = 0;
  }

  // draw()の最初で呼ぶ
  public void update(int delta_time) {

    // ・　・・・の処理
    int moveDelay;

    if (moveCount >= 2) {
      moveDelay = MOVE_FAST_INPUT_DELAY;
    } else {
      moveDelay = INPUT_DELAY;
    }

    if (!keyState[R_MOVE] && preStateMoveR) {
      moveCount = 0;
    }
    if (!keyState[L_MOVE] && preStateMoveL) {
      moveCount = 0;
    }

    preStateMoveR = keyState[R_MOVE];
    preStateMoveL = keyState[L_MOVE];

    if (waitMove >= moveDelay) {
      if (!keyState[R_MOVE] || !keyState[L_MOVE]) {
        // 右移動
        if (keyState[R_MOVE]) {
          state[L_MOVE] = false;
          state[R_MOVE] = true;
          moveCount++;
          waitMove = 0;
        }

        // 左移動
        if (keyState[L_MOVE]) {
          state[R_MOVE] = false;
          state[L_MOVE] = true;
          moveCount++;
          waitMove = 0;
        }
      }
    }

    // 右回転
    // 連続入力なし
    if (keyState[R_TURN]) {
      if (wait[R_TURN] >= INPUT_DELAY && waitTurn >= INPUT_DELAY) {
        state[R_TURN] = true;
        wait[R_TURN] = 0;
        waitTurn = 0;
      }
    } else {
      wait[R_TURN] = INPUT_DELAY;
    }

    // 左回転
    // 連続入力なし
    if (keyState[L_TURN]) {
      if (wait[L_TURN] >= INPUT_DELAY && waitTurn >= INPUT_DELAY) {
        state[L_TURN] = true;
        wait[L_TURN] = 0;
        waitTurn = 0;
      }
    } else {
      wait[L_TURN] = INPUT_DELAY;
    }

    // ホールド
    if (keyState[HOLD]) {
      if (wait[HOLD] >= INPUT_DELAY) {
        state[HOLD] = true;
        wait[HOLD] = 0;
      }
    }

    // ソフトドロップ
    if (keyState[S_DROP]) {
      state[S_DROP] = true;
    }

    // ハードドロップ
    // 連続入力なし
    if (keyState[H_DROP]) {
      if (wait[H_DROP] >= INPUT_DELAY) {
        state[H_DROP] = true;
        wait[H_DROP] = 0;
      }
    } else {
      wait[H_DROP] = INPUT_DELAY;
    }

    // 待ち時間を加算する
    for (int i = 0; i < 7; i++) {
      if (i == H_DROP || i == R_TURN || i == L_TURN) { // 連続入力をしないキーはここで飛ばす
        continue;
      }
      wait[i] += delta_time;
    }
    waitTurn += delta_time;
    waitMove += delta_time;
  }

  // draw()の最後で呼ぶ
  public void clean() {
    for (int i = 0; i < 7; i++) {
      state[i] = false;
    }
  }
}
