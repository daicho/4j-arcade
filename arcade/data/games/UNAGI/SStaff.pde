class SStaff extends Scene {
  private final SOPressed pressed;
  
  SStaff() {
    pressed = new SOPressed();
    
    final SOMessage staff = new SOMessage(
      STAFF_X, STAFF_Y,
      STAFF_TEXTSIZE, STAFF_SPACE, STAFF_COLOR,
      STAFF
    );
    
    addObjects(new SOBack(0), staff, pressed);
  }
  
  @Override
  public Scene next() {
    if (pressed.pressed()) {
      return new STitle();
    }
    
    return this;
  }
  
  private final String[] STAFF = {
    "NNCT-J2016-UNAGI-TEAM",
    "スプライトデザイナ\n塚田 陽大",
    "プログラマ\n芳賀 七海",
    "デバッガ\n島田 拓人\n宮坂 大晟",
    "\nロゴ提供\n角田 創",
    "\n作業用具提供\n島田 佳祐"
  };
  private static final int STAFF_TEXTSIZE = 30;
  private static final int STAFF_SPACE = STAFF_TEXTSIZE * 3;
  private static final int STAFF_COLOR = 255;
  private static final int STAFF_W = STAFF_TEXTSIZE / 2 * 21;
  private static final int STAFF_X = (__WIDTH__ - STAFF_W) / 2;
  private static final int STAFF_Y = 50;
}

// 1 [2] 2 [1] 2 [1] 3 
