/*
  ====================================================
  File name: SRanking.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/

class SRanking extends Scene {
  private final int score;
  private final SOUnagi unagi;
  private final Scene next;
  private final SOPressed pressed;
  
  private final boolean naming;
  
  SRanking(String name, int score, SOUnagi unagi, Scene next) {
    this.score = score;
    this.unagi = unagi;
    this.next  = next;
    pressed = new SOPressed();
    
    final String[] records = loadStrings("records.txt");
    
    if (name == null && score > Integer.parseInt(records[RECORDS - 1].split(":")[3])) {
      naming = true;
      return;
    }
    
    naming = false;
    
    addObjects(new SOBack(0));
    
    final String[] write = new String[RECORDS];
    int diff = 0;
    for (int i = 0; i < RECORDS; i++) {
      if (name != null && diff == 0 && score >= Integer.parseInt(records[i].split(":")[3])) {
        diff = 1;
        addObjects(new SORecord(
          RECORD_X,
          RECORD_Y + (SORecord.H + RECORD_SPACE) * i,
          i + 1,
          name,
          unagi.size(),
          unagi.quality(),
          score,
          true
        ));
        write[i] = name + ":" + unagi.size() +  ":" + unagi.quality() + ":" + score;
      }
      else {
        addObjects(new SORecord(
          RECORD_X,
          RECORD_Y + (SORecord.H + RECORD_SPACE) * i,
          i + 1,
          records[i - diff].split(":")[0],
          Integer.parseInt(records[i - diff].split(":")[1]),
          Integer.parseInt(records[i - diff].split(":")[2]),
          Integer.parseInt(records[i - diff].split(":")[3]),
          false
        ));
        
        write[i] = records[i - diff];
      }
    }
    
    if (diff == 0 && score >= 0) {
      addObjects(new SORecord(
        RECORD_X,
        RECORD_Y + (SORecord.H + RECORD_SPACE) * RECORDS,
        0,
        "あなた",
        unagi.size(),
        unagi.quality(),
        score,
        true
      ));
    }
    
    addObjects(new SOMessage(
      MESSAGE_X,
      MESSAGE_Y,
      MESSAGE_TEXTSIZE,
      0,
      255,
      score >= 0 ? MESSAGE_FINISH : MESSAGE_NEXT
    ));
    
    addObjects(pressed);
    
    saveStrings("data/records.txt", write);
  }
  
  @Override
  public Scene next() {
    if (naming) {
      return new SName(score, unagi);
    }
    
    if (pressed.pressed()) {
      return next;
    }
    
    return this;
  }
  
  private static final int RECORDS = 10;
  private static final int RECORD_SPACE = 20;
  private static final int RECORD_X = (__WIDTH__ - SORecord.W) / 2;
  private static final int RECORD_Y = (__HEIGHT__ - (SORecord.H + RECORD_SPACE) * (RECORDS + 1)) / 2;
  
  private static final String MESSAGE_NEXT = "ボタンをおしてもどる";
  private static final String MESSAGE_FINISH = "ボタンをおしておわる";
  private static final int MESSAGE_TEXTSIZE = 20;
  private static final int MESSAGE_W = MESSAGE_TEXTSIZE * 10;
  private static final int MESSAGE_X = (__WIDTH__ - MESSAGE_W) / 2;
  private static final int MESSAGE_Y = 800;
}

class SORecord extends SceneObject {
  private final int rank;
  private final String name;
  private final int size;
  private final int quality;
  private final int score;
  
  private final boolean flash;
  private boolean dark;
  private int cycle_flash;
  
  SORecord(int x, int y, int rank, String name, int size, int quality, int score, boolean flash) {
    super(x, y);
    
    this.rank = rank;
    this.name = name;
    this.score = score;
    this.flash = flash;
    this.size = size;
    this.quality = quality;
    
    cycle_flash = CYCLE_FLASH;
  }
  
  @Override
  public void RENDER_INIT() {
    fill(255);
    render_record();
  }
  
  @Override
  public void RENDER() {
    if (!flash) {
      return;
    }
    
    fill(0);
    rect(0, 0, W, H);
    fill(dark ? 255 : #ffff00);
    render_record();
  }
  
  @Override
  public void UPDATE(Input input) {
    if (!flash) {
      return;
    }
    
    cycle_flash--;
    if (cycle_flash == 0) {
      dark = !dark;
      cycle_flash = CYCLE_FLASH;
    }
  }
  
  private void render_record() {
    textSize(TEXTSIZE);
    if (rank > 0) {
      textAlign(RIGHT, TOP);
      text(rank + ".", RANK_XR, RANK_Y);
    }
    textAlign(LEFT, TOP);
    text("せいさんしゃ：" + name, NAME_XL,  NAME_Y);
    
    final String quality_name =
      quality == 0 ? "草" :
      quality == 1 ? "梅" :
      quality == 2 ? "竹" : "松";
    
    text(String.format("%03d", size * SOSize.CM) + "cm  " + quality_name + "  " + String.format("%0" + DIGIT + "d", score) + "円", SCORE_XL, SCORE_Y);
  }
  
  private static final int TEXTSIZE = 20;
  
  private static final int RANK_XR = TEXTSIZE / 2 * 3;
  private static final int RANK_Y  = 0;
  
  private static final int NAME_XL = RANK_XR + TEXTSIZE / 2;
  private static final int NAME_Y  = 0;
  
  private static final int SCORE_XL = NAME_XL;
  private static final int SCORE_Y  = TEXTSIZE + 4;
  
  public static final int W = NAME_XL + TEXTSIZE * 17;
  public static final int H = TEXTSIZE * 2 + 4;
  
  private static final int DIGIT = 5;
  
  private static final int CYCLE_FLASH = 15;
}
