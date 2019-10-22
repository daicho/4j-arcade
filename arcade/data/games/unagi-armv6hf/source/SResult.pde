/*
  ====================================================
  File name: SResult.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/

class SResult extends Scene {
  private final SOTimingWrapper pressed;
  private final SOUnagi unagi;
  private final int score;
  private final SOSound sound;
  
  SResult(List<SOUnagi> results) {
    int     score_best = -1;
    SOUnagi result_best = null; 
    for (SOUnagi result : results) {
      if (calc(result) > score_best) {
        score_best = calc(result);
        result_best = result;
      }
    }
    
    score = score_best;
    unagi = result_best;
    
    final SOTiming timing = new SOTiming(
      false,
      false,
      15, // to manaita
      15, // to unagi
      15, // to cook
      (result_best.size() - 3) * 2, // cooking
      15, // to score,
      15  // to message
    );
    
    final SOBack back = new SOBack(0);
    
    final SOSize size = new SOSize(
      SIZE_X,
      SIZE_Y,
      result_best
    );
    final SOQuality quality = new SOQuality(
      QUALITY_X,
      QUALITY_Y,
      result_best
    );
    final SOTimingWrapper size_wrapped = new SOTimingWrapper(
      timing,
      SOCook.TARGET_INIT,
      size
    );
    
    final SOTimingWrapper quality_wrapped = new SOTimingWrapper(
      timing,
      SOCook.TARGET_INIT,
      quality
    );
    
    final SOManaita manaita = new SOManaita(MANAITA_X, MANAITA_Y, timing);
    
    final SOCook cook = new SOCook(MANAITA_X + UnagiUnit.SIZE / 2, MANAITA_Y + UnagiUnit.SIZE / 2, timing, result_best);
    
    final SOScore score = new SOScore(SCORE_X, SCORE_Y, timing, score_best);
    
    final SOMessage message = new SOMessage(MESSAGE_X, MESSAGE_Y, MESSAGE_TEXTSIZE, 0, 255, MESSAGE);
    final SOTimingWrapper message_wrapped = new SOTimingWrapper(
      timing,
      -1,
      message
    );
    
    sound = new SOSound(timing);
    
    this.pressed = new SOTimingWrapper(timing, -1, new SOPressed());
    
    addObjects(timing, back, manaita, cook, size_wrapped, quality_wrapped, score, message_wrapped, sound, pressed);
  }
  
  @Override
  public Scene next() {
    if (((SOPressed)pressed.content()).pressed()) {
      sound.close();
      return new SRanking(null, score, unagi, null);
    }
    
    return this;
  }
  
  private int calc(SOUnagi unagi) {
    final int price =
      unagi.quality() == 0 ? 400 :
      unagi.quality() == 1 ? 500 :
      unagi.quality() == 2 ? 700 : 1000;
    
    return (unagi.size() - 2) * price;
  }
  
  private static final int MANAITA_X = 48;
  private static final int MANAITA_Y = 48;
  
  private static final int SCORE_X   = __WIDTH__ - SOScore.W - 40;
  private static final int SIZE_X    = SCORE_X;
  private static final int SIZE_Y    = 300;
  private static final int QUALITY_X = SCORE_X;
  private static final int QUALITY_Y = SIZE_Y + 80;
  private static final int SCORE_Y   = QUALITY_Y + 80;
  
  
  private static final String MESSAGE = "ボタンをおしてつぎへ";
  private static final int MESSAGE_TEXTSIZE = 20;
  private static final int MESSAGE_W = MESSAGE_TEXTSIZE * 10;
  private static final int MESSAGE_X = SCORE_X;// (__WIDTH__ - MESSAGE_W) / 2;
  private static final int MESSAGE_Y = 800;
}

class SOManaita extends SceneObject {
  private final SOTiming timing;
  private boolean init;
  
  SOManaita(int x, int y, SOTiming timing) {
    super(x, y);
    this.timing = timing;
    init = true;
  }
  
  @Override
  public void RENDER_INIT() {}
  
  @Override
  public void RENDER() {
    if (!init) {
      return;
    }
    
    if (timing.now() != TARGET) {
      return;
    }
    
    image(loadImage("sprite/manaita.png"), 0, 0);
    image(loadImage("sprite/sumibi.png"), SUMIBI_X, 0);
    
    init = false;
  }
  
  @Override
  public void UPDATE(Input input) {}
  
  private static final int TARGET = 1;
  private static final int SUMIBI_X = 64;
}

class SOCook extends SceneObject {
  private final SOTiming timing;
  private final SOUnagi unagi;
  
  private final PImage pic_body;
  private final PImage pic_bone;
  private final PImage pic_kabayaki;
  
  private boolean render_init;
  private int idx;
  
  private boolean cook;
  
  SOCook(int x, int y, SOTiming timing, SOUnagi unagi) {
    super(x, y);
    
    this.timing = timing;
    this.unagi = unagi;
    
    pic_body = loadImage("sprite/unagi/body-x-3-3.png");
    pic_bone = loadImage("sprite/bone.png");
    pic_kabayaki = loadImage("sprite/kabayaki.png");
    
    render_init = true;
    idx = 1;
    cook = true;
  }
  
  @Override
  public void RENDER_INIT() {}
  
  @Override
  public void RENDER() {
    if (render_init && timing.now() == TARGET_INIT) {
      image(loadImage("sprite/unagi/head-1-x-3.png"), 0, UnagiUnit.SIZE * 0);
      image(loadImage("sprite/unagi/neck-1-3-3.png"), 0, UnagiUnit.SIZE * 1);
      for (int i = 2; i < unagi.size() - 1; i++) {
        image(pic_body, 0, UnagiUnit.SIZE * i);
      }
      image(loadImage("sprite/unagi/tail-1-3-3.png"), 0, UnagiUnit.SIZE * (unagi.size() - 1));
      
      render_init = true;
    }
    
    if (timing.now() == TARGET_COOK) {
      if (cook) {
        image(pic_bone, 0, UnagiUnit.SIZE * idx);
        image(pic_kabayaki, KABAYAKI_X, UnagiUnit.SIZE * idx);
        idx++;
      }
      
      cook = !cook;
    }
  }
  
  @Override
  public void UPDATE(Input input) {}
  
  public static final int TARGET_INIT = 2;
  public static final int TARGET_COOK = 3;
  
  private static final int KABAYAKI_X = SOManaita.SUMIBI_X - 8;
}

class SOScore extends SceneObject {
  private final SOTiming timing;
  private final int score;
  
  private boolean init;
  
  SOScore(int x, int y, SOTiming timing, int score) {
    super(x, y);
    
    this.timing = timing;
    this.score = score;
    
    init = true;
  }
  
  @Override
  public void RENDER_INIT() {}
  
  @Override
  public void RENDER() {
    if (!init) {
      return;
    }
    
    if (timing.now() != TARGET) {
      return;
    }
    
    textAlign(LEFT, TOP);
    textSize(TEXTSIZE);
    text(String.format("%0" + DIGIT + "d" + "円", score), 0, 0);
    init = false;
  }
  
  @Override
  public void UPDATE(Input input) {}
  
  public static final int TARGET = 5;
  
  private static final int TEXTSIZE = 60;
  
  private static final int DIGIT = 5;
  
  private static final int W = TEXTSIZE / 2 * 5 + TEXTSIZE;
}

class SOSound extends SceneObject {
  private final SOTiming timing;
  private final AudioPlayer taiko_sound;
  private final AudioPlayer register_sound;
  
  private boolean cook;
  private int timing_prev;
  
  SOSound(SOTiming timing) {
    super(0, 0);
    
    this.timing = timing;
    taiko_sound = __load__("sound/drum-japanese1.mp3");
    register_sound = __load__("sound/clearing1.mp3");
    cook = true;
  }
  
  @Override
  public void RENDER_INIT() {}
  
  @Override
  public void RENDER() {
    switch (timing.now) {
      case SOManaita.TARGET:
      case SOCook.TARGET_INIT:
        if (timing_prev != timing.now()) {
          taiko_sound.play();
          taiko_sound.rewind();
        }
        break;
      case SOCook.TARGET_COOK:
        if (cook) {
          taiko_sound.play();
          taiko_sound.rewind();
        }
        cook = !cook;
        break;
      case SOScore.TARGET:
        if (timing_prev != timing.now()) {
          register_sound.play();
          register_sound.rewind();
        }
        break;
    }
    
    timing_prev = timing.now();
  }
  
  @Override
  public void UPDATE(Input input) {}
  
  public void close() {
    taiko_sound.close();
    register_sound.close();
  }
}
