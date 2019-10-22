public abstract class Mino {
  private int shape[][];      //ブロックの形
  public float nextPointX;  //ネクストのブロック座標
  public float nextPointY;  
  public float holdPointX;  //ホールドのブロック座標
  public float holdPointY;
  public float holdSize;
  public float nextBlockSize; //ネクストのブロックサイズ
  private PImage texture;   //ブロックのテクスチャ
  private int turnImino[][];

  // ミノの左上の座標 stageの配列にそのまま入る
  private int posx, posy;
  private int ghost_y;

  private int id;  //ブロックID

  public abstract void showTexture();

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
        if(id == 1){
        SspinFlag = superTSpin(stage,rotate_shape,posx,posy,false);
        }
        else if(id ==2){
        chengeImino(checkImino(rotate_shape));
        posy+=1;
       if(turnCheck(stage,turnImino)==true)
        return true;
        posy-=1;
        }
        
        if(SspinFlag == true)return true;
        return turnCheck(stage,rotate_shape);
      }
    
  }

  public boolean turnLeft(int[][] stage) {
    int rotate_shape[][] = rotateLeft();
    boolean SspinFlag = false;
    
    
    if (checkMino(stage, rotate_shape, 0, 0)) {
      shape = rotate_shape;
      
      return true;
    } else {
      if(id == 1){
        SspinFlag = superTSpin(stage,rotate_shape,posx,posy,true);
      } 
      else if(id ==2){
        chengeImino(checkImino(rotate_shape));
        posy +=1;
        if(turnCheck(stage,turnImino)==true)
        return true;
        posy -=1;
      }
      if(SspinFlag == true)return true;
      return turnCheck(stage,rotate_shape);
    }

  }
  //回転判定部分(まとめただけ)
  public boolean turnCheck(int[][] stage,int[][] rotate_shape)
  {
    
    for (int mpos = 1; mpos < 3; mpos += 1)
        {
          if (checkMino(stage, rotate_shape, -mpos, mpos)) {
            posx -= mpos;
            posy += mpos;
            shape = rotate_shape;
            return true;
          }
          else if (checkMino(stage, rotate_shape, mpos, mpos)) {
            posx += mpos;
            posy += mpos;
            shape = rotate_shape;
            return true;
          }
          else if (checkMino(stage, rotate_shape, mpos, 0)) {
            posx += mpos;
            shape = rotate_shape;
            return true;
          }
          else if (checkMino(stage, rotate_shape, -mpos, 0)) {
            posx -= mpos;
            shape = rotate_shape;
            return true;
          }
          else if (checkMino(stage, rotate_shape, 0, -mpos)) {
            posy -= mpos;
            shape = rotate_shape;
            return true;
          }
          else if (checkMino(stage, rotate_shape, mpos, -mpos)) {
            posx += mpos;
            posy -= mpos;
            shape = rotate_shape;
            return true;
          }
          else if (checkMino(stage, rotate_shape, -mpos, -mpos)) {
            posx -= mpos;
            posy -= mpos;
            shape = rotate_shape;
            return true;
          }
          else if (checkMino(stage, rotate_shape, -mpos, mpos)) {
            posx -= mpos;
            posy += mpos;
            shape = rotate_shape;
            return true;
          }
          else if (checkMino(stage, rotate_shape, mpos, mpos)) {
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
    if(id == 2){
       for (int y = 1; y < 5; y++) {
          for (int x = 1; x < 5; x++) {
            rotation[y][x] = shape[-(x - 2) + 3][y];
          }
       }
       if(rotation[3][1] == 2&&rotation[3][2] == 2&&rotation[3][3] == 2&&rotation[3][4] == 0)rotation[3][4]=2;
    }else{
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
    
    if(id == 2){
      for (int y = 1; y < 5; y++) {
        for (int x = 1; x < 5; x++) {
          rotation[y][x] = shape[x][-(y - 2) + 3];
        }
      }
      if(rotation[3][1] == 2&&rotation[3][2] == 2&&rotation[3][3] == 2&&rotation[3][4] == 0)rotation[3][4]=2;
    }else{
      for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 5; x++) {
          rotation[y][x] = shape[x][-(y - 2) + 2];
        }
      }
    }

    return rotation;
  }
  
  public boolean superTSpin(int[][] stage,int[][] rotate_shape,int posx,int posy,boolean RLFlag){
    return false;
  }
  private int checkImino(int[][] rotate_shape)
  {
   /* println(rotate_shape[1][3]);
    println(rotate_shape[1][2]);
    println(rotate_shape[1][3]);*/
    if(rotate_shape[1][3]==2)
    {
      
      return 2;
    }
    if(rotate_shape[4][3]==2)
    {
      return 3;
    }
    if(rotate_shape[1][2]==2)
    {
      return 4;
    }
    if(rotate_shape[2][4]==2)
    {
      return 1;
    }
    return 0;
  }
  private void chengeImino(int num)
  {
    int moveI[][];
    if(num==2)
    {
      moveI = new int[][] {
      {0, 0, 0, 0, 0}, 
      {0, 0, 2, 0, 0}, 
      {0, 0, 2, 0, 0}, 
      {0, 0, 2, 0, 0}, 
      {0, 0, 2, 0, 0}};
    }
    else if(num==3)
    {
      moveI = new int[][] {
      {0, 0, 0, 0, 0}, 
      {0, 0, 0, 0, 0}, 
      {2, 2, 2, 2, 0}, 
      {0, 0, 0, 0, 0}, 
      {0, 0, 0, 0, 0}};
    }
    else if(num==4)
    {
      moveI = new int[][] {
      {0, 0, 2, 0, 0}, 
      {0, 0, 2, 0, 0}, 
      {0, 0, 2, 0, 0}, 
      {0, 0, 2, 0, 0}, 
      {0, 0, 0, 0, 0}};
    }
    else
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
