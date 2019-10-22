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

    //super.texture = loadImage("resources/minoJfront.png");
    super.id = 3;
  }

  public void showTexture() {
  }
  public void turnMino(int turn) {
  }
  
  public void superSpin(){}
}
