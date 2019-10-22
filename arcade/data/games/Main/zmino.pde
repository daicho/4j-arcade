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

    //super.texture = loadImage("resources/minoZfront.png");
    super.id = 6;
  }
  
  public void superSpin(){}

  public void showTexture() {
  }

  public void turnMino(int turn) {
  }
}
