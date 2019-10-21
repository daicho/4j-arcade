class Tetris implements Demo {

  PFont font;
  DemoDisplay disp;   
  DemoStage stage;
  DemoInput input;
  boolean finishFlag;
  private int startTimeMS;
  protected int elapsedTimeS;
  protected int elapsedTimeMS;

  int pre_time;
  int delta_time;  // 前フレームからの経過時間を持つ 

  public void reset() {
    strokeWeight(1); 
    setupFonts();
    finishFlag = false;
    elapsedTimeMS = 0;
    startTimeMS = millis();
    imageMode(CORNER);
    rectMode(CORNER);
    stage = new DemoStage();
    disp = new DemoDisplay(stage);
    input = new DemoInput();
    pre_time = 0;
  }

  public void draw() {
    elapsedTimeMS = millis() - startTimeMS;
    elapsedTimeS = elapsedTimeMS / 1000;
    // 時間計測
    delta_time = elapsedTimeMS - pre_time;
    pre_time = elapsedTimeMS;
    //画面の状態
    int screenNum = 1;
    //update 
    input.update(delta_time); 
    disp.update();

    //ゲーム表示
    if (screenNum == 0) {  //スタート画面

      if (disp.startScreen(stage)) screenNum++;
    } else if (screenNum == 1) {  //ゲーム画面
      if (stage.update(input, delta_time)) finishFlag = true;
      disp.drawBackground();
      disp.drawgame(stage);
      disp.showNext();
      disp.showHold();
      disp.drawFallingMino(stage.mino);
      disp.drawScore(stage);
      disp.dispText(stage);
      disp.dispLevel(stage);
    }
    //キーリセット
    input.clean();
  }


  private void setupFonts() {  
    font = loadFont("tetris/data/ModiThorson-48.vlw");  
    textFont(font, 48);
  }

  class DemoDisplay {

    int sSarray_x;       // 横配列
    int sSarray_y;       // 縦配列
    float arst_y;
    PImage ui_img;       // 画面背景
    PImage minoTex[];    // ステージに設置されたミノ描画用のテクスチャ
    String score;//スコア

    private final int STAGESIZE_Y=19;  // 縦ブロック数(ゲーム高さ) //*
    private final int STAGESIZE_X=10;  // 横ブロック数(ゲーム幅) //*
    private final float BLOCKSIZE=25;  // ブロックの大きさ (変更する際はMinoclassのも変更)
    private final float BLOCKRADIUS = 5;
    private final float STAGEPOSITION_X = (229)/2;  //プレイ画面の位置
    private final float STAGEPOSITION_Y = 373 / 2;
    private final float NEXTPOINTINREVAL = 45; //次のブロックの表示位置の差
    private final float COLLECTNEXT_X = 20;          //ネクストブロック座標補正(次のブロック以外のネクストの位置を変えるため)
    private final float COLLECTNEXT_Y = 20;          
    private final color MINO_COLOR = #D6FFFC;
    private final color TEXT_COLOR = #00FFFF;
    private ArrayList<ViewedText> t_a_s_text = new ArrayList();

    boolean tetris_flag = false;
    int tetris_disp_start_time = 0;

    boolean allClearFlag = false;
    int allClear_disp_start_time = 0;

    boolean tSpinFlag = false;
    int tSpin_disp_start_time = 0;

    int tLine = 0;

    boolean lenFlag = false;
    int len_disp_start_time = 0;
    int len = 0;

    DemoStage stage;
    Mino dispNextMino[];
    Mino holdMino;
    Mino minos[];

    public DemoDisplay(DemoStage stage) {    
      //テクスチャ設定
      this.stage = stage;
      ui_img = loadImage("tetris/resources/MAIN.jpg");
      minoTex = new PImage[7];

      minos = new Mino[7];
      minos[0] = new TMino(0, 0);
      minos[1] = new IMino(0, 0);
      minos[2] = new JMino(0, 0);
      minos[3] = new LMino(0, 0);
      minos[4] = new SMino(0, 0);
      minos[5] = new ZMino(0, 0);
      minos[6] = new OMino(0, 0);

      sSarray_x = stage.stage[0].length;    //横配列
      sSarray_y = stage.stage.length;  //縦配列

      arst_y = sSarray_y-STAGESIZE_Y-1;   //配列とブロック数の差
      dispNextMino =new Mino[4];
      score = String.valueOf(stage.getScore());
    }

    public void update() {
      stage.getNext(dispNextMino);
      holdMino = stage.getHoldMino(holdMino);
      score = String.valueOf(stage.score);
    }
    //ゴースト絵画
    public void showGhost(int x, int y, Mino mino) {
      if (mino.posy < mino.ghost_y) {
        fill(210, 100);
        noStroke();
        rect(STAGEPOSITION_X + BLOCKSIZE * (x + mino.posx - 1), STAGEPOSITION_Y + BLOCKSIZE * (y + mino.ghost_y - arst_y), BLOCKSIZE, BLOCKSIZE);
      }
    }



    //ネクスト表示
    public void showNext() {
      float collectRadius = 1;
      for (int next = 0; next < 4; next++) {
        translate(0, NEXTPOINTINREVAL);

        translate(dispNextMino[next].nextPointX, dispNextMino[next].nextPointY);
        if (next >= 1) { //2個前
          collectRadius = 1.5;
          dispNextMino[next].nextBlockSize -=5;       
          translate(COLLECTNEXT_X, COLLECTNEXT_Y);
        } else {  //1個前
        }
        for (int i = 0; i < 5; i++) {
          for (int j = 0; j < 5; j++) {
            if (dispNextMino[next].shape[i][j] >= 1) {
              stroke(MINO_COLOR);
              fill(255, 100);
              rect(dispNextMino[next].nextBlockSize* j, dispNextMino[next].nextBlockSize * i, dispNextMino[next].nextBlockSize, dispNextMino[next].nextBlockSize, BLOCKRADIUS / collectRadius);
            }
          }
        }
        if (next >= 1) {
          translate(-COLLECTNEXT_X, -COLLECTNEXT_Y);
          dispNextMino[next].nextBlockSize +=5;
        }

        translate(-dispNextMino[next].nextPointX, -dispNextMino[next].nextPointY);
      }
      //元に戻す

      translate(0, NEXTPOINTINREVAL*(-4));
    }

    //ホールド表示
    public void showHold() {
      if (holdMino != null) {
        translate(holdMino.holdPointX, holdMino.holdPointY);
        for (int i = 0; i < 5; i++) {
          for (int j = 0; j < 5; j++) {
            if (minos[holdMino.id - 1].shape[i][j] >= 1) {
              stroke(MINO_COLOR);
              fill(255, 100);
              rect(holdMino.holdSize* j, holdMino.holdSize * i, holdMino.holdSize, holdMino.holdSize, BLOCKRADIUS);
            }
          }
        }
        //元に戻す
        translate(-holdMino.holdPointX, -holdMino.holdPointY);
      }
    }

    //背景
    public void drawBackground() {  
      image(ui_img, 0, 0, width, height);
    }

    // ステージに設置されているブロックを描画
    public void drawgame(DemoStage stage) {  //ゲームプレイ画面
      for (int i = (int)arst_y; i < sSarray_y; i++) {
        for (int j = 0; j < sSarray_x; j++) {

          if (stage.stage[i][j] == 0) {
            fill(200, 200, 255, 50);
            noStroke();
          } else if (stage.stage[i][j] > 0) {
            stroke(MINO_COLOR);
            rect(STAGEPOSITION_X + BLOCKSIZE * (j - 1), STAGEPOSITION_Y + BLOCKSIZE * (i-arst_y), BLOCKSIZE, BLOCKSIZE, BLOCKRADIUS);
          }
        }
      }
    }

    // 落下中のミノ描画
    public void drawFallingMino(Mino mino) {
      for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 5; x++) {
          if (mino.shape[y][x] != 0) {
            // ミノの影
            showGhost(x, y, mino);
            // ミノの本体
            stroke(MINO_COLOR);
            fill(0, 50);
            rect(STAGEPOSITION_X + BLOCKSIZE * (x + mino.posx - 1), STAGEPOSITION_Y + BLOCKSIZE * (y + mino.posy - arst_y), BLOCKSIZE, BLOCKSIZE, BLOCKRADIUS);
          }
        }
      }
    }

    //スタート画面の表示
    public boolean startScreen(DemoStage stage) {
      //ここにスタート画面を表示するコードを書く終了したらtrueにする
      return false;
    }

    //scoreを描画
    public void drawScore(DemoStage stage) {
      textSize(35);
      fill(TEXT_COLOR);
      textAlign(RIGHT);
      textFont(font, 38);
      text(score, 350, 139);
    }

    //Tetrisなどの文字を描画
    public void dispText(DemoStage stage) {
      int tempTLine = 0;
      int tempLen = 0;

      if (stage.checkTetris()) {
        tetris_disp_start_time = millis();
        tetris_flag = true;
      }

      if (stage.getAllClearFlag()) {
        allClear_disp_start_time = millis();
        allClearFlag = true;
      }

      if (stage.checkTSpinFlag()) {
        tSpin_disp_start_time = millis();
        tSpinFlag = true;
      }

      if ((tempLen = stage.getLenCount()) != len) {
        len = tempLen;
        if (len != 0 || len != 1) len_disp_start_time = millis();
        //lenFlag = true;
      }

      if ((tempTLine = stage.getClearLine()) != 0) {
        tLine = tempTLine;
      } else tLine = 0;

      if (tetris_flag) {
        tetris_flag = false;
        t_a_s_text.add(0, new ViewedText("TETRIS"));
      }

      if ((millis() - len_disp_start_time <= 3000)) {
        textSize(25);
        fill(255);
        if (!(len >= 0 && len <= 1))  text("Len", 310, 250);
        if (!(len >= 0 && len <= 1))  text(len - 1, 310, 280);
      }


      if (tSpinFlag) {
        t_a_s_text.add(0, new ViewedText("Tspin")); 
        switch(tLine) {
        case 1:
          t_a_s_text.add(1, new ViewedText("Single"));
          break;
        case 2:
          t_a_s_text.add(1, new ViewedText("Double"));
          break;
        case 3:
          t_a_s_text.add(1, new ViewedText("Triple"));
          break;
        default :

          break;
        }
        tSpinFlag = false;
      }

      for (int i = 0; i < t_a_s_text.size(); ++i) {
        if (t_a_s_text.get(i).isFinish()) {
          if (t_a_s_text.get(i).getText() == "Tspin" && tLine != 0) {
            t_a_s_text.remove(i+1);
          }
          t_a_s_text.remove(i);
        }
      }

      textView();
    }

    private void textView() {
      for (int i = 0; i < t_a_s_text.size(); i++) {
        textSize(25);
        fill(255);
        textAlign(CENTER);
        text(t_a_s_text.get(i).getText(), width * 0.5, 250 + 30 * i);
      }
    }

    public void dispLevel(DemoStage stage) {
      int level = stage.getLevel();
      textSize(55);
      textAlign(RIGHT);
      fill(TEXT_COLOR);
      text(level, 325, 755);
    }

    public void dispTime(DemoStage stage) {
      int time = stage.getTime();
      String min = String.valueOf(time / 60);
      String sec = String.valueOf(time % 60);
      if (sec.length() == 1) sec = "0" + sec; 
      String gametime = min + " : " + sec;
      textSize(16);
      textAlign(RIGHT);
      fill(TEXT_COLOR);
      text(gametime, 79, 365);
    }
  }

  class DemoInput {
    public boolean state[] = new boolean[7];
    public final int R_MOVE = 0; 
    public final int L_MOVE = 1;
    public final int R_TURN = 2;
    public final int L_TURN = 3;
    public final int HOLD   = 4;
    public final int S_DROP = 5;
    public final int H_DROP = 6;

    static final int INPUT_INTERVALL = 200; // ms

    int move_count;
    int rotate_count;
    int elapsed_time;  // 経過時間
    boolean done_drop;

    public DemoInput()
    {
      super();

      move_count = 0;
      rotate_count = 0;
      done_drop = true;
    }

    public void update(int delta_time) {
      //  新しいミノが来たら
      // 1. 落とす場所を決める
      // 2. 回転回数を決める
      // 3. 落とす
      if (elapsed_time > INPUT_INTERVALL) {
        elapsed_time = 0;
        if (done_drop) {        // 値設定
          if (move_count == 0) {
            move_count = (int)random(-5, 6);
          }

          if (rotate_count == 0) {
            rotate_count = (int)random(0, 5);
          } 

          done_drop = false;
        } else {                      // 実際に操作

          if (move_count != 0) {      // まずは左右移動
            if (move_count > 0) {     // move_countがマイナスなら左に移動、プラスなら右に移動
              state[R_MOVE] = true;
              move_count--;
            } else {
              state[L_MOVE] = true;
              move_count++;
            }
          } else {                    // 移動が終わっていたら回転
            if (rotate_count != 0) {  // 回転
              state[R_TURN] = true;
              rotate_count--;
            } else {                  // 回転が終わっていたら落とす
              done_drop = true;
              state[H_DROP] = true;
            }
          }
        }
      }
      elapsed_time += delta_time;
    }

    public void clean() {
      for (int i = 0; i < 7; i++) {
        state[i] = false;
      }
    }
  }

  class DemoStage {         

    private int score;

    private int waitFall;       
    private int lastInputTime;  // 最後の入力からの経過時間
    private int gameTime;    //ゲームの残り時間(秒)
    private int gameLimitTime; //リミットタイム
    private int startTime;     // ゲーム開始時の時間
    private int level;
    private boolean gameFinishFlag;

    private boolean isGround;   // ミノが接地しているか
    private int minoFreeTime;   // 地面に接している間にミノが自由に動ける時間
    private boolean doneHold;   // ホールドを使ったか
    private int fall_time;     //落下間隔時間
    private int clearLineNum;
    private int lenCount;
    private int lastline;
    private boolean allClearFlag;
    private boolean dispAllClearFlag;
    private boolean firstGroundFlag;

    private boolean line1;  //スコア関連フラグ
    private boolean line2;
    private boolean line3;
    private boolean line4;
    private boolean tetrisFlag;
    private boolean tSpinFlag;
    private int dispClearLine;

    private int oneLineScore = 100; //加算するスコア(変えてください)

    private Mino nextMino[];  

    private final int FIRST_X = 3;  // ミノの生成位置
    private final int FIRST_Y = 3;
    private final int NORMAL_FALL_TIME = 1000; //自然落下間隔時間
    private final int SOFT_FALL_TIME = 40;  //強制落下間隔時間
    private final int FREE_TIME = 4000;   // 接地後に最大何ms動かせるか
    private final int INPUT_WAIT = 1000;  // 最後の入力から何ms待つか(カサカサ)
    private final int CLEAR_LINE_NUM = 150;

    RandomMino next;
    private Mino mino;
    private Mino holdMino;
    int[][] stage;

    public DemoStage() {
      next = new RandomMino();  // ミノ生成
      mino = getNewMino(next.getNextMino());  // 最初のミノを生成
      nextMino =new Mino[4];
      for (int i = 0; i < 4; i++) nextMino[i]=getNewMino(next.getNextMino());  // Nextの4つのミノを生成
      allClearFlag = false;
      dispAllClearFlag = false;
      firstGroundFlag = false;
      holdMino = null;
      isGround = false;
      waitFall = 0;
      fall_time = NORMAL_FALL_TIME;
      minoFreeTime = 0;
      lastInputTime = 0;
      clearLineNum = 0;
      gameLimitTime = 360;
      gameTime = 0;
      startTime = millis();
      level = 1;
      gameFinishFlag = false;
      doneHold = false;

      line1 = false;
      line2 = false;
      line3 = false;
      line4 = false;
      tetrisFlag = false;
      tSpinFlag = false;
      lenCount = 0;
      lastline = 0;
      dispClearLine = 0;

      stage = new int[][] { 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, //3,3
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, //<=ここからミノ生成 (6,5)を回転軸に ここから下が表示される
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 
        {-1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1}, 

        {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}};
    }

    // このメソッドをdraw()で毎フレーム呼ぶ
    public boolean update(DemoInput input, int delta_time) {

      decrementTime();//時間を減らす

      // 操作されたか（カサカサ用）
      boolean wasOperate = false;

      wasOperate = move(input, wasOperate);  

      wasOperate = rotation(input, wasOperate);

      if (input.state[input.HOLD]) {          // ホールド
        hold();
      }

      mino.setGhost(stage);    // ゴーストの位置設定

      // Down Mino //
      waitFall += delta_time;

      if (waitFall >= fall_time) {
        isGround = !mino.fall(stage);  // 落下と接地判定
        waitFall = 0;
      }
      //

      // "kasakasa" and check ground Mino //
      if (isGround) {
        minoFreeTime += delta_time;

        if (wasOperate) {
          lastInputTime = 0;
        } else {
          lastInputTime += delta_time;
        }
        //

        // ミノの位置が決まった
        if (minoFreeTime >= FREE_TIME || lastInputTime >= INPUT_WAIT) {
          ground();
        }
      }

      if (gameFinishFlag) score = 0;
      return gameFinishFlag;
    }

    private boolean move(DemoInput input, boolean wasOp) {
      boolean wasOperate = wasOp;
      // キーと操作の対応はclass InputKeyを参照されたし
      if (input.state[input.R_MOVE]) {        // 右移動
        wasOperate = mino.moveRight(stage);
      }

      if (input.state[input.L_MOVE]) {        // 左移動
        wasOperate = mino.moveLeft(stage);
      }

      if (input.state[input.H_DROP]) {        // ハードドロップ
        mino.posy = mino.ghost_y;
        minoFreeTime = FREE_TIME;
        isGround = true;
      }

      if (input.state[input.S_DROP]) {        // ソフトドロップ
        fall_time = SOFT_FALL_TIME - ((level - 1) * 100);
      } else {
        fall_time = NORMAL_FALL_TIME - ((level - 1) * 100);
      }
      return wasOperate;
    }

    private boolean rotation(DemoInput input, boolean wasOp) {
      boolean wasOperate = wasOp;
      if (input.state[input.R_TURN]) {        // 右回転
        wasOperate = mino.turnRight(stage);
        // 浮かび上がったときの処理
        boolean preIsGround = isGround;
        isGround = !mino.checkMino(stage, 0, 1);
        if (preIsGround && isGround) {
          waitFall = 0;
        }
      }

      if (input.state[input.L_TURN]) {        // 左回転
        wasOperate = mino.turnLeft(stage);
        // 浮かび上がったときの処理
        boolean preIsGround = isGround;
        isGround = !mino.checkMino(stage, 0, 1);
        if (preIsGround && isGround) {
          waitFall = 0;
        }
      }
      return wasOperate;
    }

    private void ground() {
      tSpinFlag = checkTSpin(stage, mino.posx, mino.posy, mino.shape);
      // ラインチェックと次のミノの処理
      stageSetMino(mino);      // stage[][]にミノのブロックを反映
      gameFinishFlag = gameOver();
      clearLineNum += checkline(mino.posy);    // ラインチェック
      clearLineNum = gameClear(clearLineNum);
      //onDispFlag();
      firstGroundFlag = true;
      allClearFlag = checkAllClear();
      if (allClearFlag == true) dispAllClearFlag = true;

      addScore(lenCount);            // 得点か三
      lenCount(clearLineNum);        // れん
      setNextMino();         // 次のミノを取り出す
      levelUp();

      doneHold = false; 
      isGround = false;
      minoFreeTime = 0;
      lastInputTime = 0;
      waitFall = 0;
      downFlag();
    }

    // 新しいミノのインスタンスを返す
    // idは17の間
    private Mino getNewMino(int id) {
      Mino nmino = null;

      switch(id) {
      case 1 : 
        nmino = new TMino(FIRST_X, FIRST_Y);
        break;
      case 2 :
        nmino = new IMino(FIRST_X, FIRST_Y);
        break;
      case 3 :
        nmino = new JMino(FIRST_X, FIRST_Y);
        break;
      case 4 :
        nmino = new LMino(FIRST_X, FIRST_Y);
        break;
      case 5 :
        nmino = new SMino(FIRST_X, FIRST_Y);
        break;
      case 6 :
        nmino = new ZMino(FIRST_X, FIRST_Y);
        break;
      case 7 :
        nmino = new OMino(FIRST_X, FIRST_Y);
        break;
      }
      return nmino;
    }

    // 次のミノをminoに代入する
    public void setNextMino() {
      mino = nextMino[0];
      for (int i = 0; i < 3; i++) {
        nextMino[i] = nextMino[i + 1];
      }
      nextMino[3] = getNewMino(next.getNextMino());
    }

    // ホールドの処理
    public void hold() {
      if (!doneHold) {           // 既にホールドを使っていないかのチェック
        minoFreeTime = 0;        // 各種変数の再設定
        lastInputTime = 0;
        waitFall = 0;
        doneHold = true;
        if (holdMino == null) {  // ホールドにミノがないとき
          holdMino = mino;
          setNextMino();
        } else {                 // ホールドにミノがあるときr
          Mino tmp = mino;
          mino = getNewMino(holdMino.id);
          holdMino = tmp;
        }
      }
    }

    public Mino getHoldMino(Mino holdMino2) {
      holdMino2 = holdMino;
      return holdMino2;
    }

    // ミノをstage[][]にセットする
    public void stageSetMino(Mino mino) {
      for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 5; x++) {
          if (mino.shape[y][x] != 0) {
            stage[y + mino.posy][x + mino.posx] = mino.shape[y][x];
          }
        }
      }
    }

    // int cy : ミノの位置  
    // cyを基準にしてブロックを走査
    public int checkline(int cy) {
      int flag = 0;
      int blockCount = 0;    // 1行にあるブロックの数のバッファ
      int clearY = 0;
      int checknum = 4;    
      int clear = 0;

      for (int i = checknum; i >= 0; i -= 1) {    // 最大4行消えるから?
        flag = 0;
        blockCount = 0;
        for (int j = 1; j <= 10 && flag == 0; j += 1) {
          blockCount += 1;
          if ((cy - i + checknum)>=23)break;      // stage[][]を縦にはみ出さないように
          if (stage[cy - i+4][j] == -1)
            break;
          else if (stage[cy - i+ checknum ][j] == 0)
            flag = 1;
          if (blockCount == 10) {
            clearY = cy - i + checknum;
          }
        }
        if (flag == 0 && blockCount == 10) {
          clear += 1;
          for (int j = 1; j <= 10; j += 1) {
            stage[clearY][j] = 0;
          }
          for (int ci = clearY; ci > 0; ci -= 1) {
            if (stage[ci][1] == -1) break;
            for (int cj = 1; cj <= 10; cj += 1) {
              stage[ci][cj] = stage[ci - 1][cj];
            }
          }
        }

        blockCount = 0;
      }
      if (clear == 1)
        line1 = true;
      else if (clear == 2)
        line2 = true;
      else if (clear == 3)
        line3 = true;
      else if (clear == 4)
        line4 = true;

      onDispFlag();

      return clear;
    }

    public void addScore(int lenNum) {//得点加算 値は適当に決めたので変更してください
      int len = 0;
      int lenBonus = 0;
      byte tSpinBonus = 1;
      if (lenNum>=2)
      {
        len = lenNum-1;
      }

      if (tSpinFlag)  tSpinBonus = 2;
      if (len == 0)          lenBonus = 0;
      else if (len < 4)       lenBonus = 50;
      else if (len < 8)       lenBonus = 100;
      else if (len < 12)      lenBonus = 150;
      else if (len < 16)      lenBonus = 200;
      else                   lenBonus = 250;
      if (line1 == true)
      {
        score += (int)(oneLineScore * tSpinBonus + lenBonus);
      } else if (line2 == true)
      {
        score += (int)(oneLineScore * tSpinBonus* 2 +lenBonus);
      } else if (line3 == true)
      {
        score += (int)(oneLineScore * tSpinBonus * 3 + lenBonus);
      } else if (line4 == true)
      {
        score += (int)(oneLineScore* 4 + lenBonus);
      }
    }

    public int gameClear(int clear) {
      if (clear >= CLEAR_LINE_NUM)
      {
        for (int y = 0; y < 23; y += 1)
        {
          for (int x = 1; x <= 10; x+= 1)
          {  
            stage[y][x] = 0;
          }
        }
        holdMino = null;
        doneHold = false;
        lenCount = 0;
        lastline = 0;
        score = 0;
        return 0;
      }
      return clear;
    }

    public boolean gameOver() {
      boolean gameOverFlag = false;
      //画面外にミノがあるか探す
      for (int y = 0; y < 4; y += 1)
      {
        for (int x = 4; x <= 7; x += 1)
        {  
          if (stage[y][x] != 0)
          {
            gameOverFlag = true;
            break;
          }
        }
      }
      //ミノが生成される場所にミノがあるか探す
      if (gameOverFlag == false)
      {
        for (int x = 4; x <= 6; x+= 1)
        {  
          if (stage[5][x] != 0&&nextMino[0].id == 1)
          {
            gameOverFlag = true;
            break;
          }
          if (stage[5][x] != 0||stage[4][x] != 0)
          {
            gameOverFlag = true;
            break;
          }
        }
        if (stage[5][7] != 0 && nextMino[0].id == 2)
        {
          gameOverFlag = true;
        }
      }
      //処理内容　盤面削除､ホールド初期化
      if (gameOverFlag == true)
      {
        for (int y = 0; y < 23; y += 1)
        {
          for (int x = 1; x <= 10; x+= 1)
          {  
            stage[y][x] = 0;
          }
        }
        holdMino = null;
        doneHold = false;
        lenCount = 0;
        lastline = 0;
        score = 0;
      }
      return gameOverFlag;
    }



    public void getNext(Mino dispNextMino[]) {
      for (int i = 0; i < 4; i++) {
        dispNextMino[i] = nextMino[i];
      }
    }

    public void lenCount(int count) {// れん加算
      if (lastline != count )
      {
        lenCount += 1;
      } else
      {
        lenCount = 0;
      }
      lastline = count;
    }

    /**
     * 
     * せり上がりs 
     *
     **/
    public void addLine() {
    }
    public void downFlag() {
      line1 = false;
      line2 = false;
      line3 = false;
      line4 = false;
      allClearFlag = false;
    }

    public boolean checkAllClear() {  
      if (!firstGroundFlag) return false; 
      for (int i = 1; i < 11; i++) {
        if (stage[22][i] >= 1) return false;
      }
      return true;
    }

    public int getScore() {
      return score;
    }

    public int getTime() {
      return gameTime;
    }

    private void decrementTime() {
      int ms = (millis() - startTime) / 1000;
      gameTime = gameLimitTime - ms;
      if (gameTime <= 0) gameFinishFlag = true;
    }

    public boolean checkTetris() {
      if (tetrisFlag == true) {
        tetrisFlag = false;
        return true;
      }
      return false;
    }

    public boolean checkTSpin(int[][] stage, int posx, int posy, int[][] mino) {
      if (this.mino.id != 1) return false;

      boolean CP1 = false;
      boolean CP2 = false; 
      boolean CP3 = false;
      boolean CP4 = false;
      if (stage[posy+1][posx+1] != 0) CP1 = true;//LEFTUP
      if (stage[posy+1][posx+3] != 0) CP2 = true;//RIGHTUP
      if (stage[posy+3][posx+1] != 0) CP3 = true;//LEFTDOWN
      if (stage[posy+3][posx+3] != 0) CP4 = true;//RIGHTDOWN

      int tRo = 0;
      //Tmino direction
      if (mino[3][2] == 0 )tRo = 1; //UP
      else if (mino[2][1] == 0 )tRo = 2; //RIGHT
      else if (mino[2][3] == 0 )tRo = 3; //LEFT
      else if (mino[1][2] == 0 )tRo = 4;  //DOWN
      if (CP3 &&CP4) {
        if (tRo==1) 
        {
          if (CP1 || CP2) { 
            if ((stage[posy+2][posx+0] != 0) && (stage[posy+2][posx+4] != 0)) { 
              return true;
            }
          }
        } else if (tRo==2) 
        { 
          if (CP2) {  
            return true;
          }
        } else if (tRo==3) 
        { 
          if (CP1) {  
            return true;
          }
        } else if (tRo==4) 
        { 
          if (CP1 || CP2) {   
            return true;
          }
        }
      }
      return false;
    } 

    private void levelUp() {
      if (score < 500) level = 1;
      else if (score < 800) level = 2;
      else if (score < 1500) level = 3;
      else if (score < 2300) level = 4;
      else if (score < 3200) level = 5;
      else if (score < 4500) level = 6;
      else if (score < 7500) level = 7;
      else if (score < 10000) level = 8;
      else level = 9;
    }

    public int getLevel() {
      return level;
    }

    public boolean checkTSpinFlag() {
      if (tSpinFlag == true) {
        tSpinFlag = false;
        return true;
      }
      return false;
    }

    public boolean getAllClearFlag() {
      if (dispAllClearFlag) {
        dispAllClearFlag = false;
        return true;
      }
      return false;
    }


    public int getClearLine() {
      int line;
      line = dispClearLine;
      dispClearLine = 0;
      return line;
    }

    public int getLenCount() {
      return lenCount;
    }

    private void onDispFlag() {
      if (line1 == true) dispClearLine = 1;
      if (line2 == true) dispClearLine = 2;
      if (line3 == true) dispClearLine = 3;
      if (line4 == true) tetrisFlag = true;
    }

    float getStageValue () {  // ステージの評価値
      float sum_value = 0;
      int line_count = 0;

      for (int[] line : stage) {
        int space_count = 0;
        int block_count = 0;

        for (int block : line) {

          if (block > 0) {
            block_count++;
          } else {
            space_count++;
          }
        }
        if (block_count != 0) {
          line_count++; 
          sum_value += block_count / (block_count + space_count);
        }
      }
      return sum_value / line_count;
    }
  }
  public class Imageview {

    private boolean runSwitch;

    Imageview() {
      runSwitch = false;
    }

    public void pushSwitch() {
      runSwitch = !runSwitch;
    }

    public boolean isRunnning() {
      return runSwitch;
    }
  }

  public abstract class Mino {
    private int shape[][];      //ブロックの形
    public float nextPointX;  //ネクストのブロック座標
    public float nextPointY;  
    public float holdPointX;  //ホールドのブロック座標
    public float holdPointY;
    public float holdSize;
    public float nextBlockSize; //ネクストのブロックサイズ
    private int turnImino[][];

    // ミノの左上の座標 stageの配列にそのまま入る
    private int posx, posy;
    private int ghost_y;

    private int id;  //ブロックID

    public Mino(int x, int y) {
      posx = x;
      posy = y;
      ghost_y = 0;
    }

    /*
  回転はstageとミノの状況からcheckMino(), rotateRight(), rotateLeft()をうまく使って実装する
     回転後のshapeは上書きしてもらって構わない
     各種ミノで実装すること
     posxとposyの変更も忘れずに
     */

    //ブロックの回転
    public boolean turnRight(int[][] stage) {  //

      int rotate_shape[][] = rotateRight();
      boolean SspinFlag = false;

      if (checkMino(stage, rotate_shape, 0, 0)) {
        shape = rotate_shape;
        return true;
      } else
      {
        if (id == 1) {
          SspinFlag = superTSpin(stage, rotate_shape, posx, posy, false);
        } else if (id ==2) {
          chengeImino(checkImino(rotate_shape));
          posy+=1;
          if (turnCheck(stage, turnImino)==true)
            return true;
          posy-=1;
        }

        if (SspinFlag == true)return true;
        return turnCheck(stage, rotate_shape);
      }
    }

    public boolean turnLeft(int[][] stage) {
      int rotate_shape[][] = rotateLeft();
      boolean SspinFlag = false;


      if (checkMino(stage, rotate_shape, 0, 0)) {
        shape = rotate_shape;

        return true;
      } else {
        if (id == 1) {
          SspinFlag = superTSpin(stage, rotate_shape, posx, posy, true);
        } else if (id ==2) {
          chengeImino(checkImino(rotate_shape));
          posy +=1;
          if (turnCheck(stage, turnImino)==true)
            return true;
          posy -=1;
        }
        if (SspinFlag == true)return true;
        return turnCheck(stage, rotate_shape);
      }
    }
    //回転判定部分(まとめただけ)
    public boolean turnCheck(int[][] stage, int[][] rotate_shape)
    {

      for (int mpos = 1; mpos < 3; mpos += 1)
      {
        if (checkMino(stage, rotate_shape, -mpos, mpos)) {
          posx -= mpos;
          posy += mpos;
          shape = rotate_shape;
          return true;
        } else if (checkMino(stage, rotate_shape, mpos, mpos)) {
          posx += mpos;
          posy += mpos;
          shape = rotate_shape;
          return true;
        } else if (checkMino(stage, rotate_shape, mpos, 0)) {
          posx += mpos;
          shape = rotate_shape;
          return true;
        } else if (checkMino(stage, rotate_shape, -mpos, 0)) {
          posx -= mpos;
          shape = rotate_shape;
          return true;
        } else if (checkMino(stage, rotate_shape, 0, -mpos)) {
          posy -= mpos;
          shape = rotate_shape;
          return true;
        } else if (checkMino(stage, rotate_shape, mpos, -mpos)) {
          posx += mpos;
          posy -= mpos;
          shape = rotate_shape;
          return true;
        } else if (checkMino(stage, rotate_shape, -mpos, -mpos)) {
          posx -= mpos;
          posy -= mpos;
          shape = rotate_shape;
          return true;
        } else if (checkMino(stage, rotate_shape, -mpos, mpos)) {
          posx -= mpos;
          posy += mpos;
          shape = rotate_shape;
          return true;
        } else if (checkMino(stage, rotate_shape, mpos, mpos)) {
          posx += mpos;
          posy += mpos;
          shape = rotate_shape;
          return true;
        }
      }
      return false;
    }
    // 現在の位置から+(dx, dy)ずれた位置にミノが存在できるかを判定する
    public boolean checkMino(int[][] stage, int[][] shape, int dx, int dy) {
      for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 5; x++) {
          if (shape[y][x] != 0) { 
            int check_x = x + posx + dx;
            int check_y = y + posy + dy;
            // インデックスがstage[][]からはみ出さないか監視
            if (check_x < 0 || check_x >= stage[0].length || check_y < 0 || check_y >= stage.length) {
              return false;
            }
            if (stage[check_y][check_x] != 0) {
              return false;
            }
          }
        }
      }
      return true;
    }

    public boolean checkMino(int[][] stage, int dx, int dy) {
      return checkMino(stage, shape, dx, dy);
    }

    // 落ちられたらtrue、落ちれなかったらfalse
    public boolean fall(int[][] stage) {
      if (checkMino(stage, 0, 1)) {
        posy++; 
        return true;
      }
      return false;
    }

    //ブロック移動
    // 移動出来たらtrue, だめならfalse
    public boolean moveRight(int[][] stage) {
      if (checkMino(stage, 1, 0)) {
        posx++;
        return true;
      }
      return false;
    }


    public boolean moveLeft(int[][] stage) {
      if (checkMino(stage, -1, 0)) {
        posx--; 
        return true;
      }
      return false;
    }

    // ゴーストの位置を作成
    public void setGhost(int[][] stage) {
      for (int y = posy; checkMino(stage, 0, y - posy); y++) {
        ghost_y = y;
      }
    }

    /*
   ミノを回転させる
     この関数を使ってturnLeft、turnRightをつくる
     回転軸が異なるミノはオーバーライドすること
     */
    public int[][] rotateRight() { 
      int[][] rotation = new int[5][5];
      // 回転行列(Iminoだけ特殊にする)
      if (id == 2) {
        for (int y = 1; y < 5; y++) {
          for (int x = 1; x < 5; x++) {
            rotation[y][x] = shape[-(x - 2) + 3][y];
          }
        }
        if (rotation[3][1] == 2&&rotation[3][2] == 2&&rotation[3][3] == 2&&rotation[3][4] == 0)rotation[3][4]=2;
      } else {
        for (int y = 0; y < 5; y++) {
          for (int x = 0; x < 5; x++) {
            rotation[y][x] = shape[-(x - 2) + 2][y];
          }
        }
      }

      return rotation;
    }

    public int[][] rotateLeft() { 
      int[][] rotation = new int[5][5];

      // 回転行列

      if (id == 2) {
        for (int y = 1; y < 5; y++) {
          for (int x = 1; x < 5; x++) {
            rotation[y][x] = shape[x][-(y - 2) + 3];
          }
        }
        if (rotation[3][1] == 2&&rotation[3][2] == 2&&rotation[3][3] == 2&&rotation[3][4] == 0)rotation[3][4]=2;
      } else {
        for (int y = 0; y < 5; y++) {
          for (int x = 0; x < 5; x++) {
            rotation[y][x] = shape[x][-(y - 2) + 2];
          }
        }
      }

      return rotation;
    }

    public boolean superTSpin(int[][] stage, int[][] rotate_shape, int posx, int posy, boolean RLFlag) {
      return false;
    }
    private int checkImino(int[][] rotate_shape)
    {
      if (rotate_shape[1][3]==2)
      {

        return 2;
      }
      if (rotate_shape[4][3]==2)
      {
        return 3;
      }
      if (rotate_shape[1][2]==2)
      {
        return 4;
      }
      if (rotate_shape[2][4]==2)
      {
        return 1;
      }
      return 0;
    }
    private void chengeImino(int num)
    {
      int moveI[][];
      if (num==2)
      {
        moveI = new int[][] {
          {0, 0, 0, 0, 0}, 
          {0, 0, 2, 0, 0}, 
          {0, 0, 2, 0, 0}, 
          {0, 0, 2, 0, 0}, 
          {0, 0, 2, 0, 0}};
      } else if (num==3)
      {
        moveI = new int[][] {
          {0, 0, 0, 0, 0}, 
          {0, 0, 0, 0, 0}, 
          {2, 2, 2, 2, 0}, 
          {0, 0, 0, 0, 0}, 
          {0, 0, 0, 0, 0}};
      } else if (num==4)
      {
        moveI = new int[][] {
          {0, 0, 2, 0, 0}, 
          {0, 0, 2, 0, 0}, 
          {0, 0, 2, 0, 0}, 
          {0, 0, 2, 0, 0}, 
          {0, 0, 0, 0, 0}};
      } else
      {
        moveI = new int[][] {
          {0, 0, 0, 0, 0}, 
          {0, 0, 0, 0, 0}, 
          {0, 2, 2, 2, 2}, 
          {0, 0, 0, 0, 0}, 
          {0, 0, 0, 0, 0}};
      }
      turnImino=moveI;
    }
  }

  public class IMino extends Mino {

    public IMino(int x, int y) {
      super(x, y);
      super.nextPointX = 385;
      super.nextPointY = 140;
      super.holdPointX = 6;                //ホールド座標X
      super.holdPointY = 185;               //ホールド座標Y
      super.holdSize = 15;
      super.nextBlockSize = 15;
      super.shape = new int[][] {
        {0, 0, 0, 0, 0}, 
        {0, 0, 0, 0, 0}, 
        {0, 2, 2, 2, 2}, 
        {0, 0, 0, 0, 0}, 
        {0, 0, 0, 0, 0}};
      super.id = 2;
    }
  }

  public class JMino extends Mino {

    public JMino(int x, int y) {
      super(x, y);
      super.nextPointX = 390;
      super.nextPointY = 140;
      super.holdPointX = 15;                //ホールド座標X 
      super.holdPointY = 190;               //ホールド座標Y
      super.holdSize = 15;
      super.nextBlockSize = 15;
      super.shape = new int[][] {
        {0, 0, 0, 0, 0}, 
        {0, 3, 0, 0, 0}, 
        {0, 3, 3, 3, 0}, 
        {0, 0, 0, 0, 0}, 
        {0, 0, 0, 0, 0}};

      super.id = 3;
    }
  }

  public class LMino extends Mino {

    public LMino(int x, int y) {
      super(x, y);
      super.nextPointX = 390;
      super.nextPointY = 140;
      super.holdPointX = 15;                //ホールド座標X 
      super.holdPointY = 190;               //ホールド座標Y
      super.holdSize = 15;
      super.nextBlockSize = 15;
      super.shape = new int[][] {
        {0, 0, 0, 0, 0}, 
        {0, 0, 0, 4, 0}, 
        {0, 4, 4, 4, 0}, 
        {0, 0, 0, 0, 0}, 
        {0, 0, 0, 0, 0}};

      super.id = 4;
    }
  }

  public class OMino extends Mino {

    public OMino(int x, int y) {
      super(x, y);
      super.nextPointX = 385;
      super.nextPointY = 140;
      super.holdPointX = 8;                //ホールド座標X 
      super.holdPointY = 193;               //ホールド座標Y
      super.holdSize = 14.5;
      super.nextBlockSize = 15;
      super.shape = new int[][] {
        {0, 0, 0, 0, 0}, 
        {0, 0, 7, 7, 0}, 
        {0, 0, 7, 7, 0}, 
        {0, 0, 0, 0, 0}, 
        {0, 0, 0, 0, 0}};

      super.id = 7;
    }

    public void turnMino(int turn) {
    }
    //oは回転させない
    public int[][] rotateRight() { 
      return super.shape;
    }

    public int[][] rotateLeft() { 
      return super.shape;
    }
  }

  public class SMino extends Mino {

    public SMino(int x, int y) {
      super(x, y);
      super.nextPointX = 390;
      super.nextPointY = 140;
      super.holdPointX = 15;                //ホールド座標X 
      super.holdPointY = 190;               //ホールド座標Y
      super.holdSize = 15;
      super.nextBlockSize = 15;
      super.shape = new int[][] {
        {0, 0, 0, 0, 0}, 
        {0, 0, 5, 5, 0}, 
        {0, 5, 5, 0, 0}, 
        {0, 0, 0, 0, 0}, 
        {0, 0, 0, 0, 0}};

      super.id = 5;
    }
  }

  public class TMino extends Mino {

    private int tSpinTriple[][] = {
      {0, 0, 1, -2, -2}, 
      {0, 0, 0, -2, -2}, 
      {-2, 1, 0, -2, -2}, 
      {-2, 0, 0, -2, -2}, 
      {-2, -2, 0, -2, -2}};

    public TMino(int x, int y) {
      super(x, y);
      super.nextPointX = 390;
      super.nextPointY = 140;
      super.holdPointX = 15;                //ホールド座標X 
      super.holdPointY = 190;               //ホールド座標Y
      super.holdSize = 15;
      super.nextBlockSize = 15;
      super.shape = new int[][] {
        {0, 0, 0, 0, 0}, 
        {0, 0, 1, 0, 0}, 
        {0, 1, 1, 1, 0}, 
        {0, 0, 0, 0, 0}, 
        {0, 0, 0, 0, 0}
      };

      super.id = 1;
    }

    public boolean tSpinFlag(int[][] stage, int[][] rotate_shape, int posx, int posy)
    {

      return true;
    }



    public boolean checkBlockR(int[][] stage, int [][] rotateShape, int posx, int posy)
    {
      return true;
    }



    public boolean superTSpin(int[][] stage, int[][] rotate_shape, int posx, int posy, boolean RLFlag) {
      /*
    stage : stage 
       rotate_shape : rotate_shape
       posx : ミノのX座標
       posy : ミノのY座標
       RLFlag : true -> L
       false-> R
       */
      int sx = posx; //この左上の座標と比較
      int sy = posy + 1;
      int rex, rey, spx, spy;
      boolean rFlag = true, sFlag = true;
      boolean conR = true, conS = true;
      //入るかチェック
      if (RLFlag == true)
      {
        sx += 1;
        spx = sx;
        spy = sy;
        sx -= 1;
        sy -= 2;
        rex = sx;
        rey = sy;
        for (int j = 0; j < 5; j += 1)
        {
          if (j+spy > 23)conS = false;
          if (j+rey > 23)conR = false;
          for (int i = 0; i < 5; i += 1)
          {
            if (i+spx >= 12)conS = false;
            if (i+rex >= 12)conR = false;


            if (conS == true && sFlag == true)
              sFlag = chechkSpin_L(stage, i, j, spx, spy);
            if (conR == true && rFlag == true)
              rFlag = chechkSpin_R(stage, i, j, rex, rey);
            if (rFlag == false && sFlag == false)return false;
          }
          conS = true;
          conR = true;
        }
      } else if (RLFlag == false)
      {
        sx -= 1;
        spx = sx;
        spy = sy;
        sx += 1;
        sy -= 2;
        rex = sx;
        rey = sy;

        if (rex == -1)rex = 0;
        for (int j = 0; j < 5; j += 1)
        {
          if (j+spy > 23)conS = false;
          if (j+rey > 23)conR = false;
          for (int i = 0; i < 5; i += 1)
          {
            if (i+spx >= 12)conS = false;
            if (i+rex >= 12)conR = false;
            if (conS == true && sFlag == true)
              sFlag = chechkSpin_R(stage, i, j, spx, spy);
            if (conR == true && rFlag == true)
              rFlag = chechkSpin_L(stage, i, j, rex, rey);
            if (rFlag == false && sFlag == false)return false;
          }
          conS = true;
          conR = true;
        }
      }
      //はめ込みをする
      //左回転させ下に2右に1ずらすなどをして
      if (checkMino(stage, rotate_shape, 1, 2) && RLFlag == true) {
        super.posx += 1;
        super.posy += 2;
        super.shape = rotate_shape;
        return true;
      } else if (checkMino(stage, rotate_shape, -1, 2) && RLFlag == false) {
        super.posx -= 1;
        super.posy += 2;
        super.shape = rotate_shape;
        return true;
      } else if (rFlag == true && RLFlag == true)
      {
        super.posx += 1;
        super.posy -= 2;
        super.shape = rotate_shape;
        return true;
      } else if (rFlag == true && RLFlag == false)
      {
        super.posx -= 1;
        super.posy -= 2;
        super.shape = rotate_shape;
        return true;
      }

      //戻りや向きが逆のパターンはのちにする
      return false;
    }

    public boolean chechkSpin_R(int[][] stage, int i, int j, int sx, int sy)
    {

      if (tSpinTriple[j][4-i] != -2) { //-2の時はどちらでもいいので判定しない
        if (stage[j+sy][i+sx] == -1)return true;
        if (tSpinTriple[j][4-i] == 1) {
          //ブロック1以上かをチェック
          if (stage[j+sy][i+sx] <= 0)
            return false;
        } else if (tSpinTriple[j][4-i] == 0) {
          //ブロックがないかをチェック
          if (stage[j+sy][i+sx] != 0)
            return false;
        }
      }
      return true;
    }
    public boolean chechkSpin_L(int[][] stage, int i, int j, int sx, int sy)
    {

      if (tSpinTriple[j][i] != -2) { //-2の時はどちらでもいいので判定しない

        if (stage[j+sy][i+sx] == -1)return true;

        if (tSpinTriple[j][i] == 1) {
          //ブロック1以上かをチェック
          if (stage[j+sy][i+sx] <= 0)
            return false;
        } else if (tSpinTriple[j][i] == 0) {
          //ブロックがないかをチェック
          if (stage[j+sy][i+sx] != 0)
            return false;
        }
      }
      return true;
    }
  }

  public class ZMino extends Mino {

    public ZMino(int x, int y) {
      super(x, y);
      super.nextPointX = 390;
      super.nextPointY = 140;
      super.holdPointX = 15;                //ホールド座標X 
      super.holdPointY = 190;               //ホールド座標Y
      super.holdSize = 15;
      super.nextBlockSize = 15;
      super.shape = new int[][] {
        {0, 0, 0, 0, 0}, 
        {0, 6, 6, 0, 0}, 
        {0, 0, 6, 6, 0}, 
        {0, 0, 0, 0, 0}, 
        {0, 0, 0, 0, 0}};

      super.id = 6;
    }
  }

  class ViewedText {
    private int startTime;
    private String text;
    ViewedText(String text) {
      startTime = millis();
      this.text = text;
    }
    public boolean isFinish() {
      if (millis() - startTime < 3000) return false;
      else return true;
    }
    public String getText() {
      return this.text;
    }
  }

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
}
