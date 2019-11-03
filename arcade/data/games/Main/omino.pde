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

    //super.texture = loadImage("resources/minoOfront.png");
    super.id = 7;
  }

  public void showTexture() {
  }
  
  public void superSpin(){}

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
