class Display {

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

  Stage stage;
  Mino dispNextMino[];
  Mino holdMino;
  Mino minos[];

  public Display(Stage stage) {    
    //テクスチャ設定
    this.stage = stage;
    ui_img = loadImage("resources/MAIN.jpg");
    minoTex = new PImage[7];
    
    minos = new Mino[7];
    minos[0] = new TMino(0, 0);
    minos[1] = new IMino(0, 0);
    minos[2] = new JMino(0, 0);
    minos[3] = new LMino(0, 0);
    minos[4] = new SMino(0, 0);
    minos[5] = new ZMino(0, 0);
    minos[6] = new OMino(0, 0);
    
    for(int i = 0; i < 7; i++){
      minoTex[i] = minos[i].texture;
    }

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
  public void showGhost(int x,int y,Mino mino) {
    if (mino.posy < mino.ghost_y) {
      fill(210, 100);
      noStroke();
      //filter(BL
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
            fill(255,100);
            rect(dispNextMino[next].nextBlockSize* j, dispNextMino[next].nextBlockSize * i, dispNextMino[next].nextBlockSize, dispNextMino[next].nextBlockSize, BLOCKRADIUS / collectRadius);
            //image(minoTex[dispNextMino[next].id - 1], dispNextMino[next].nextBlockSize* j, dispNextMino[next].nextBlockSize * i, dispNextMino[next].nextBlockSize, dispNextMino[next].nextBlockSize);
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
            fill(255,100);
            rect(holdMino.holdSize* j, holdMino.holdSize * i, holdMino.holdSize, holdMino.holdSize, BLOCKRADIUS);
            //image(minoTex[minos[holdMino.id - 1].id - 1], holdMino.holdSize* j, holdMino.holdSize * i, holdMino.holdSize, holdMino.holdSize);
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
  public void drawgame(Stage stage) {  //ゲームプレイ画面
    for (int i = (int)arst_y; i < sSarray_y; i++) {
      for (int j = 0; j < sSarray_x; j++) {
        if (stage.stage[i][j] == 0) {
          fill(200,200,255,50);
          noStroke();
          //stroke(150);
          //rect(STAGEPOSITION_X-BLOCKSIZE+BLOCKSIZE*j, STAGEPOSITION_Y+BLOCKSIZE*(i-arst_y), BLOCKSIZE, BLOCKSIZE);
        } else if (stage.stage[i][j] > 0) {
          stroke(MINO_COLOR);
          rect(STAGEPOSITION_X + BLOCKSIZE * (j - 1), STAGEPOSITION_Y + BLOCKSIZE * (i-arst_y), BLOCKSIZE, BLOCKSIZE, BLOCKRADIUS);
          //image(minoTex[stage.stage[i][j] - 1], STAGEPOSITION_X + BLOCKSIZE * (j - 1), STAGEPOSITION_Y + BLOCKSIZE * (i-arst_y), BLOCKSIZE, BLOCKSIZE);
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
          showGhost(x,y,mino);
          // ミノの本体
          stroke(MINO_COLOR);
          fill(0,50);
          rect(STAGEPOSITION_X + BLOCKSIZE * (x + mino.posx - 1), STAGEPOSITION_Y + BLOCKSIZE * (y + mino.posy - arst_y), BLOCKSIZE, BLOCKSIZE, BLOCKRADIUS);
          //image(mino.texture, STAGEPOSITION_X + BLOCKSIZE * (x + mino.posx - 1), STAGEPOSITION_Y + BLOCKSIZE * (y + mino.posy - arst_y), BLOCKSIZE, BLOCKSIZE);
        }
      }
    }
  }

  //スタート画面の表示
  public boolean startScreen(Stage stage){
    //ここにスタート画面を表示するコードを書く終了したらtrueにする
    return false;
  }
  
  //scoreを描画
  public void drawScore(Stage stage){
    textSize(35);
    fill(TEXT_COLOR);
    textAlign(RIGHT);
    text(score, 350, 139);
  }
  
    //Tetrisなどの文字を描画
  public void dispText(Stage stage) {
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
    
    if (stage.checkTSpinFlag()){
      tSpin_disp_start_time = millis();
      tSpinFlag = true;
    }
    
    if ((tempLen = stage.getLenCount()) != len){
      len = tempLen;
      if (len != 0 || len != 1) len_disp_start_time = millis();
      //lenFlag = true;
    }
    
    if((tempTLine = stage.getClearLine()) != 0){
      tLine = tempTLine;    
    } else tLine = 0;
    
    if (tetris_flag) {
      tetris_flag = false;
      t_a_s_text.add(0, new ViewedText("TETRIS"));
    }
    
    if (allClearFlag) {
      allClearFlag = false;
      t_a_s_text.add(0, new ViewedText("ALL CLEAR"));
    }

    if ((millis() - len_disp_start_time <= 3000)) {
      //println("ALL CLEAR" + (millis() - allClear_disp_start_time)); 
      textSize(25);
      fill(255);
      if (!(len >= 0 && len <= 1))  text("Len", 310, 250);
      if (!(len >= 0 && len <= 1))  text(len - 1, 310, 280);
    }

       
    if(tSpinFlag){
      t_a_s_text.add(0, new ViewedText("Tspin")); 
      switch(tLine){
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
  
  public void dispLevel(Stage stage){
    int level = stage.getLevel();
    textSize(55);
    textAlign(RIGHT);
    fill(TEXT_COLOR);
    text(level, 325, 755);
  }
  
  public void dispTime(Stage stage){
    int time = stage.getTime();
    String min = String.valueOf(time / 60);
    String sec = String.valueOf(time % 60);
    if(sec.length() == 1) sec = "0" + sec; 
    String gametime = min + " : " + sec;
    //println(gametime);
    textSize(16);
    textAlign(RIGHT);
    fill(TEXT_COLOR);
    text(gametime, 79, 365);
  }
}
