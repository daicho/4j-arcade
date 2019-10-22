/*
  ====================================================
  File name: STitle.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/

class STitle extends Scene {
  private final SOChoice choice;
  
  STitle() {
    final SOImage logo = new SOImage(LOGO_X, LOGO_Y, "logo/logo-400.png");
    choice = new SOChoice(CHOICE_XC, CHOICE_YT);
    
    final SOMessage copyright = new SOMessage(
      COPYRIGHT_X, COPYRIGHT_Y,
      COPYRIGHT_TEXTSIZE, COPYRIGHT_SPACE, COPYRIGHT_COLOR,
      COPYRIGHT
    );
    
    addObjects(new SOBack(0), logo, choice, copyright);
  }
  
  @Override
  public Scene next() {
    if (choice.chosen() != -1) {
      choice.close();
      switch (choice.chosen()) {
        case SOChoice.HOWTO:
          return new SHowto();
        case SOChoice.PLAY:
          return new SGame(
            SGAME_TIME,
            SGAME_STOCK,
            new LinkedList<SOUnagi>()
          );
        case SOChoice.RANKING:
          return new SRanking(null, -1, null, new STitle());
        case SOChoice.STAFF:
          return new SStaff();
      }
    }
    
    return this;
  }
  
  private static final int LOGO_W = 400;
  private static final int LOGO_H = 112;
  private static final int LOGO_X = (__WIDTH__ - LOGO_W) / 2;
  private static final int LOGO_Y = 100;
  
  private static final int CHOICE_XC = __WIDTH__ / 2;
  private static final int CHOICE_YT = __HEIGHT__ / 2;
  
  private static final int SGAME_TIME  = 300;
  private static final int SGAME_STOCK = 2;
  
  private static final String COPYRIGHT = "Copyright (c) NNCT-J2016-UNAGI-TEAM 2019.\nAll rights reserved.";
  private static final int COPYRIGHT_TEXTSIZE = 20;
  private static final int COPYRIGHT_SPACE = 0;
  private static final int COPYRIGHT_COLOR = #ffff00;
  private static final int COPYRIGHT_W = COPYRIGHT_TEXTSIZE / 2 * 41;
  private static final int COPYRIGHT_X = (__WIDTH__ - COPYRIGHT_W) / 2;;
  private static final int COPYRIGHT_Y = 760;
}

class SOChoice extends SceneObject {
  private final AudioPlayer sound;
  
  private int choice;
  private int choice_prev;
  private int chosen;
  
  SOChoice(int x, int y) {
    super(x, y);
    sound = __load__("sound/drum-japanese1.mp3");
    chosen = -1;
  }
  
  @Override
  public void RENDER_INIT() {
    fill(255);
    
    textSize(TEXTSIZE);
    textAlign(CENTER, TOP);
    text("あそびかた", TEXT_XC, (TEXTSIZE + TEXT_SPACE) * HOWTO);
    text("プレイ",   TEXT_XC, (TEXTSIZE + TEXT_SPACE) * PLAY);
    text("ランキング", TEXT_XC, (TEXTSIZE + TEXT_SPACE) * RANKING);
    text("スタッフ", TEXT_XC, (TEXTSIZE + TEXT_SPACE) * STAFF);
    
    render_cursor();
  }
  
  @Override
  public void RENDER() {
    if (choice == choice_prev) {
      return;
    }
    
    fill(0);
    rect(CURSOR_XL, (TEXTSIZE + TEXT_SPACE) * choice_prev, CURSOR_W, CURSOR_H);
    fill(255);
    render_cursor();
    sound.play();
    sound.rewind();
  }
  
  @Override
  public void UPDATE(Input input) {
    choice_prev = choice;
    if (input.posedge(Input.U) && !input.posedge(Input.D)) {
      choice = choice > 0 ? choice - 1 : CHOICE_LIMIT;
      return;
    }
    
    if (input.posedge(Input.D) && !input.posedge(Input.U)) {
      choice = choice < CHOICE_LIMIT ? choice + 1 : 0;
      return;
    }
    
    if (input.posedge(Input.RU) || input.posedge(Input.RR) || input.posedge(Input.RL)) {
      chosen = choice;
    }
    else {
      chosen = -1;
    }
  }
  
  private void render_cursor() {
    triangle(
      CURSOR_XL, (TEXTSIZE + TEXT_SPACE) * choice, 
      CURSOR_XL, (TEXTSIZE + TEXT_SPACE) * choice + CURSOR_H, 
      CURSOR_XL + CURSOR_W, (TEXTSIZE + TEXT_SPACE) * choice + CURSOR_H / 2
    );
  }
  
  public int chosen() {
    return chosen;
  }
  
  public void close() {
    sound.close();
  }
  
  public static final int HOWTO   = 0;
  public static final int PLAY    = 1;
  public static final int RANKING = 2;
  public static final int STAFF   = 3;
  
  private static final int CHOICE_LIMIT = 3;
  
  private static final int TEXTSIZE = 30;
  private static final int TEXT_W   = TEXTSIZE * 5;
  private static final int TEXT_SPACE = TEXTSIZE;
  private static final int TEXT_XC  = 0;
  
  private static final int CURSOR_W  = TEXTSIZE;
  private static final int CURSOR_H  = TEXTSIZE;
  private static final int CURSOR_XL = TEXT_XC - TEXT_W / 2 - TEXTSIZE - CURSOR_W;
}
