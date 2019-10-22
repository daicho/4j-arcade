class Stage {         

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
  private boolean fallMinoFlag;
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
  private Sound sound;

  public Stage(Sound sound) {
    this.sound = sound;

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
    fallMinoFlag = false;
    
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
  public boolean update(Input input, int delta_time) {

    decrementTime();//時間を減らす
    
    // 操作されたか（カサカサ用）
    boolean wasOperate = false;

    wasOperate = move(input,wasOperate);  
    
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
      if (!isGround) {
        //sound.playSE("soft");
        fallMinoFlag = false;
      }
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

    if (gameFinishFlag) sound.stopAllSounds();
    return gameFinishFlag;
  }

  private boolean move(Input input,boolean wasOp){
    boolean wasOperate = wasOp;
    // キーと操作の対応はclass InputKeyを参照されたし
    if (input.state[input.R_MOVE]) {        // 右移動
      wasOperate = mino.moveRight(stage);
      if(wasOperate)sound.playSE("soft");
    }

    if (input.state[input.L_MOVE]) {        // 左移動
      wasOperate = mino.moveLeft(stage);
      if(wasOperate)sound.playSE("soft");
    }
    
    if (input.state[input.H_DROP]) {        // ハードドロップ
      mino.posy = mino.ghost_y;
      minoFreeTime = FREE_TIME;
      isGround = true;
    }
    
    if (input.state[input.S_DROP]) {        // ソフトドロップ
      fall_time = SOFT_FALL_TIME - ((level - 1) * 100);
      fallMinoFlag = true;
    } else {
      fall_time = NORMAL_FALL_TIME - ((level - 1) * 100);
    }
    return wasOperate;
  }
  
  private boolean rotation(Input input,boolean wasOp){
    boolean wasOperate = wasOp;
      if (input.state[input.R_TURN]) {        // 右回転
        wasOperate = mino.turnRight(stage);
        if(wasOperate)sound.playSE("soft");
        // 浮かび上がったときの処理
        boolean preIsGround = isGround;
        isGround = !mino.checkMino(stage, 0, 1);
        if (preIsGround && isGround) {
          waitFall = 0;
        }
      }

    if (input.state[input.L_TURN]) {        // 左回転
      wasOperate = mino.turnLeft(stage);
      if(wasOperate)sound.playSE("soft");
      // 浮かび上がったときの処理
      boolean preIsGround = isGround;
      isGround = !mino.checkMino(stage, 0, 1);
      if (preIsGround && isGround) {
        waitFall = 0;
      }
    }
    return wasOperate;
  }
  
  private void ground(){
    tSpinFlag = checkTSpin(stage,mino.posx,mino.posy,mino.shape);
    // ラインチェックと次のミノの処理
    stageSetMino(mino);      // stage[][]にミノのブロックを反映
    gameFinishFlag = gameOver();
    clearLineNum += checkline(mino.posy);    // ラインチェック
    clearLineNum = gameClear(clearLineNum);
    //onDispFlag();
    firstGroundFlag = true;
    allClearFlag = checkAllClear();
    if(allClearFlag == true) dispAllClearFlag = true;
    
    addScore(lenCount);            // 得点か三
    lenCount(clearLineNum);        // れん
    setNextMino();         // 次のミノを取り出す
    levelUp();
    

    if(line4) sound.playSE("tetris");
    else if (line3) {
      if (tSpinFlag == true) sound.playSE("tSpin3");
      else sound.playSE("twoLine");
    }
    else if (line2) {
      if (tSpinFlag == true) sound.playSE("tSpin2");
      else sound.playSE("twoLine");
    }
    else if (line1) {
      if (tSpinFlag == true) sound.playSE("tSpin1");
      else sound.playSE("aline");
    }
    else sound.playSE("drop");

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
    if(clear == 1)
      line1 = true;
    else if(clear == 2)
      line2 = true;
    else if(clear == 3)
      line3 = true;
    else if(clear == 4)
      line4 = true;
      
      onDispFlag();
      
    return clear;
  }

  public void addScore(int lenNum) {//得点加算 値は適当に決めたので変更してください
    int len = 0;
    int lenBonus = 0;
    byte tSpinBonus = 1;
    if(lenNum>=2)
    {
      len = lenNum-1;
    }
    
    if(tSpinFlag)  tSpinBonus = 2;
    if (len == 0)          lenBonus = 0;
    else if(len < 4)       lenBonus = 50;
    else if(len < 8)       lenBonus = 100;
    else if(len < 12)      lenBonus = 150;
    else if(len < 16)      lenBonus = 200;
    else                   lenBonus = 250;
    if(line1 == true)
    {
      score += (int)(oneLineScore * tSpinBonus + lenBonus); 
    }
    else if(line2 == true)
    {
      score += (int)(oneLineScore * tSpinBonus* 2 +lenBonus); 
    }
    else if(line3 == true)
    {
      score += (int)(oneLineScore * tSpinBonus * 3 + lenBonus); 
    }
    else if(line4 == true)
    {
      score += (int)(oneLineScore* 4 + lenBonus); 
    }
    
    if(allClearFlag) score+=1000;
  }

  public int gameClear(int clear) {
    if (clear >= CLEAR_LINE_NUM)
    {
      println("clear");
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
    if(lastline != count )
    {
      lenCount += 1;
    }
    else
    {
      lenCount = 0;
      
    }
    lastline = count;
    if(lenCount != 0)
    println("len:"+lenCount);
  }

  /**
   * 
   * せり上がりs 
   *
   **/
  public void addLine() {
  }
  public void downFlag(){
    line1 = false;
    line2 = false;
    line3 = false;
    line4 = false;
    allClearFlag = false;
  }
  
  public boolean checkAllClear(){  
    if (!firstGroundFlag) return false; 
    for(int i = 1;i < 11; i++){
      if(stage[22][i] >= 1) return false;
    }
    return true;
  }

  public int getScore() {
    return score;
  }
  
    public int getTime(){
    return gameTime;
  }
  
  private void decrementTime(){
    int ms = (millis() - startTime) / 1000;
    gameTime = gameLimitTime - ms;
    if(gameTime <= 0) gameFinishFlag = true;
  }
  
  public boolean checkTetris(){
    if(tetrisFlag == true) {
      tetrisFlag = false;
      return true;
    }
    return false;
  }
  
  public boolean checkTSpin(int[][] stage,int posx,int posy,int[][] mino){
    if(this.mino.id != 1) return false;
    
    boolean CP1 = false;
    boolean CP2 = false; 
    boolean CP3 = false;
    boolean CP4 = false;
    if(stage[posy+1][posx+1] != 0) CP1 = true;//LEFTUP
    if(stage[posy+1][posx+3] != 0) CP2 = true;//RIGHTUP
    if(stage[posy+3][posx+1] != 0) CP3 = true;//LEFTDOWN
    if(stage[posy+3][posx+3] != 0) CP4 = true;//RIGHTDOWN
    
    int tRo = 0;
    //Tmino direction
    if(mino[3][2] == 0 )tRo = 1; //UP
    else if(mino[2][1] == 0 )tRo = 2; //RIGHT
    else if(mino[2][3] == 0 )tRo = 3; //LEFT
    else if(mino[1][2] == 0 )tRo = 4;  //DOWN
    if(CP3 &&CP4){
      if(tRo==1) 
      {
        if(CP1 || CP2) { 
          if((stage[posy+2][posx+0] != 0) && (stage[posy+2][posx+4] != 0)){
             println("Tspin"); 
             return true; 
          }
        }
      }
      else if(tRo==2) 
      { 
        if(CP2) {  
          println("Tspin"); 
          return true; 
        } 
      } 
      else if(tRo==3) 
      { 
        if(CP1) {  
          println("Tspin");  
          return true; 
        } 
      } 
      else if(tRo==4) 
      { 
        if(CP1 || CP2) {  
          println("Tspin");  
          return true; 
        } 
      } 
    }
    return false; 
  } 
   
  private void levelUp(){
    if (score < 500) level = 1;
    else if (score < 800) level = 2;
    else if (score < 1500) level = 3;
    else if (score < 2300) level = 4;
    else if (score < 3200) level = 5;
    else if (score < 4500) level = 6;
    else if (score < 7500) level = 7;
    else if (score < 10000) level = 8;
    else level = 9;
    
    println(level);
  }
  
  public int getLevel(){
    return level;
  }
  
  public boolean checkTSpinFlag(){
    if(tSpinFlag == true) {
      tSpinFlag = false;
      return true;
    }
    return false;
  }
  
  public boolean getAllClearFlag(){
    if(dispAllClearFlag){
      dispAllClearFlag = false;
      return true;
    }
    return false;
  }
  
  
  public int getClearLine(){
    int line;
    line = dispClearLine;
    dispClearLine = 0;
    return line;
  }
  
  public int getLenCount(){
    return lenCount;
  }
  
  private void onDispFlag(){
    if(line1 == true) dispClearLine = 1;
    if(line2 == true) dispClearLine = 2;
    if(line3 == true) dispClearLine = 3;
    if(line4 == true) tetrisFlag = true;
  }
}
