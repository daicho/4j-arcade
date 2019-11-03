/*
  ====================================================
  File name: SStaff.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/

class SStaff extends Scene {
  private final SOPressed pressed;
  
  SStaff() {
    pressed = new SOPressed();
    
    final SOMessage staff = new SOMessage(
      STAFF_X, STAFF_Y,
      STAFF_TEXTSIZE, STAFF_SPACE, STAFF_COLOR,
      STAFF
    );
    
    final SOMessage message = new SOMessage(
      MESSAGE_X,
      MESSAGE_Y,
      MESSAGE_TEXTSIZE,
      0,
      255,
      MESSAGE
    );
    
    addObjects(new SOBack(0), staff, message, pressed);
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
  
  private static final String MESSAGE = "ボタンをおしてもどる";
  private static final int MESSAGE_TEXTSIZE = 20;
  private static final int MESSAGE_W = MESSAGE_TEXTSIZE * 10;
  private static final int MESSAGE_X = (__WIDTH__ - MESSAGE_W) / 2;
  private static final int MESSAGE_Y = 800;
}
