public class TMino extends Mino {
  
  private int tSpinTriple[][] = {
    {0 ,0 ,1,-2,-2},
    {0 ,0 ,0,-2,-2},
    {-2,1 ,0,-2,-2},
    {-2,0 ,0,-2,-2},
    {-2,-2,0,-2,-2}};
  
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

    //super.texture = loadImage("resources/minoTfront.png");
    super.id = 1;
  }
  
  public boolean tSpinFlag(int[][] stage,int[][] rotate_shape,int posx,int posy)
  {
    
    return true;
  }
  


  public boolean checkBlockR(int[][] stage,int [][] rotateShape,int posx,int posy)
  {
    return true;
  }
  
    
  
  public boolean superTSpin(int[][] stage,int[][] rotate_shape,int posx,int posy,boolean RLFlag){
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
    int rex,rey,spx,spy;
    boolean rFlag = true ,sFlag = true;
    boolean conR = true,conS = true;
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
       for(int j = 0;j < 5;j += 1)
       {
         if(j+spy > 23)conS = false;
         if(j+rey > 23)conR = false;
           for(int i = 0;i < 5;i += 1)
           {
             if(i+spx >= 12)conS = false;
             if(i+rex >= 12)conR = false;
             
             
             if(conS == true && sFlag == true)
             sFlag = chechkSpin_L(stage,i,j,spx,spy);
             if(conR == true && rFlag == true)
             rFlag = chechkSpin_R(stage,i,j,rex,rey);
             if(rFlag == false && sFlag == false)return false;
           }
           conS = true;
           conR = true;
       }
       
     }
     else if (RLFlag == false)
     {
       sx -= 1;
       spx = sx;
       spy = sy;
       sx += 1;
       sy -= 2;
       rex = sx;
       rey = sy;
       
       if(rex == -1)rex = 0;
       for(int j = 0;j < 5;j += 1)
       {
         if(j+spy > 23)conS = false;
         if(j+rey > 23)conR = false;
           for(int i = 0;i < 5;i += 1)
           {
             if(i+spx >= 12)conS = false;
             if(i+rex >= 12)conR = false;
             if(conS == true && sFlag == true)
             sFlag = chechkSpin_R(stage,i,j,spx,spy);
             if(conR == true && rFlag == true)
             rFlag = chechkSpin_L(stage,i,j,rex,rey);
             if(rFlag == false && sFlag == false)return false;
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
    }
    else if (checkMino(stage, rotate_shape, -1, 2) && RLFlag == false) {
      super.posx -= 1;
      super.posy += 2;
      super.shape = rotate_shape;
      return true;
    }
    else if(rFlag == true && RLFlag == true)
    {
      super.posx += 1;
      super.posy -= 2;
      super.shape = rotate_shape;
      return true;
    }
    else if(rFlag == true && RLFlag == false)
    {
      super.posx -= 1;
      super.posy -= 2;
      super.shape = rotate_shape;
      return true;
    }
    
    //戻りや向きが逆のパターンはのちにする
    return false;
  }

  public void showTexture() {
  }

  public void turnMino(int turn) {
  }
  
  public boolean chechkSpin_R(int[][] stage,int i,int j,int sx,int sy)
  {
    
     if(tSpinTriple[j][4-i] != -2){ //-2の時はどちらでもいいので判定しない
                  if(stage[j+sy][i+sx] == -1)return true;
                  if(tSpinTriple[j][4-i] == 1){
                     //ブロック1以上かをチェック
                     if(stage[j+sy][i+sx] <= 0)
                     return false;
                   }else if(tSpinTriple[j][4-i] == 0){
                     //ブロックがないかをチェック
                     if(stage[j+sy][i+sx] != 0)
                     return false;
                   }
               }
          return true;
  }
  public boolean chechkSpin_L(int[][] stage,int i,int j,int sx,int sy)
  {
    
    if(tSpinTriple[j][i] != -2){ //-2の時はどちらでもいいので判定しない
    print((j+sy));
    println((i+sx));
                  if(stage[j+sy][i+sx] == -1)return true;
                  
                  if(tSpinTriple[j][i] == 1){
                     //ブロック1以上かをチェック
                     if(stage[j+sy][i+sx] <= 0)
                     return false;
                   }else if(tSpinTriple[j][i] == 0){
                     //ブロックがないかをチェック
                     if(stage[j+sy][i+sx] != 0)
                     return false;
                   }
               }
       return true;
  }
}
