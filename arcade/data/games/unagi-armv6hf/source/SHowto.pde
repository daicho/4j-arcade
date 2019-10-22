/*
  ====================================================
  File name: SHowto.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/

class SHowto extends Scene {
  private final SOPressed pressed;
  
  SHowto() {
    pressed = new SOPressed();
    
    final SOMessage title = new SOMessage(
      TITLE_X, TITLE_Y,
      TITLE_TEXTSIZE, TITLE_SPACE, TITLE_COLOR,
      TITLE
    );
    
    final SOMessage howto = new SOMessage(
      HOWTO_X, HOWTO_Y,
      HOWTO_TEXTSIZE, HOWTO_SPACE, HOWTO_COLOR,
      HOWTO
    );
    
    final SOMessage section_item = new SOMessage(
      SECTION_ITEM_X, SECTION_ITEM_Y,
      SECTION_ITEM_TEXTSIZE, SECTION_ITEM_SPACE, SECTION_ITEM_COLOR,
      SECTION_ITEM
    );
    
    final SOMessage item = new SOMessage(
      ITEM_X, ITEM_Y,
      ITEM_TEXTSIZE, ITEM_SPACE, ITEM_COLOR,
      ITEM
    );
    
    final SOImage back_feed  = new SOImage(PIC_X, FEED_Y,  "sprite/back.png");
    final SOImage back_sfeed = new SOImage(PIC_X, SFEED_Y, "sprite/back.png");
    final SOImage back_net   = new SOImage(PIC_X, NET_Y,   "sprite/back.png");
    final SOImage back_hook  = new SOImage(PIC_X, HOOK_Y,  "sprite/back.png");
    
    final SOImage pic_feed  = new SOImage(PIC_X, FEED_Y,  "sprite/feed.png");
    final SOImage pic_sfeed = new SOImage(PIC_X, SFEED_Y, "sprite/sfeed.png");
    final SOImage pic_net   = new SOImage(PIC_X, NET_Y,   "sprite/net.png");
    final SOImage pic_hook  = new SOImage(PIC_X, HOOK_Y,  "sprite/hook.png");
    
    addObjects(
      new SOBack(0),
      title,
      howto,
      section_item,
      item,
      back_feed,
      back_sfeed,
      back_net,
      back_hook,
      pic_feed,
      pic_sfeed,
      pic_net,
      pic_hook,
      pressed
    );
  }
  
  @Override
  public Scene next() {
    if (pressed.pressed()) {
      return new STitle();
    }
    
    return this;
  }
  
  private static final String TITLE = "あそびかた";
  private static final int TITLE_TEXTSIZE = 30;
  private static final int TITLE_SPACE = 0;
  private static final int TITLE_COLOR = #ffff00;
  private static final int TITLE_W = TITLE_TEXTSIZE * 5;
  private static final int TITLE_H = TITLE_TEXTSIZE;
  private static final int TITLE_X = (__WIDTH__ - TITLE_W) / 2;;
  private static final int TITLE_Y = 100;
  
  private final String[] HOWTO = {
    "ウナギをようしょくしよう！",
    "えさをたべると、ながくなったり、",
    "おいしくなったりする。",
    "じぶんのからだや、あみ・つりばりに",
    "あたると、ウナギはほかくされる。",
    "せいげんじかんは５ふん、チャンスは",
    "３かい。",
    "いちばんいい１ぴきだけが、けっかに",
    "のこるので、できるだけいいウナギを",
    "そだてよう。"
  };
  private static final int HOWTO_TEXTSIZE = 20;
  private static final int HOWTO_SPACE = 5;
  private static final int HOWTO_COLOR = 255;
  private static final int HOWTO_W = HOWTO_TEXTSIZE * 17;
  private static final int HOWTO_H = (HOWTO_TEXTSIZE + HOWTO_SPACE) * 10 - HOWTO_SPACE;
  private static final int HOWTO_X = (__WIDTH__ - HOWTO_W) / 2;
  private static final int HOWTO_Y = TITLE_Y + TITLE_H + 20;
  
  private static final String SECTION_ITEM = "アイテム";
  private static final int SECTION_ITEM_TEXTSIZE = 30;
  private static final int SECTION_ITEM_SPACE = 0;
  private static final int SECTION_ITEM_COLOR = 255;
  private static final int SECTION_ITEM_W = SECTION_ITEM_TEXTSIZE * 4;
  private static final int SECTION_ITEM_H = SECTION_ITEM_TEXTSIZE;
  private static final int SECTION_ITEM_X = (__WIDTH__ - SECTION_ITEM_W) / 2;
  private static final int SECTION_ITEM_Y = HOWTO_Y + HOWTO_H + 40;
  
  private static final int PIC_X = HOWTO_X;
  private static final int PIC_W = 16;
  
  private final String[] ITEM = {
    "エビをたべるなんてぜいたくだ\nウナギがながくなる",
    "めずらしいきんいろのエビ\nたべるとおいしくなる",
    "ほかくようのあみ\nあたるとほかくされる",
    "だれかさんのつりばり\nあたるとほかくされる"
  };
  private static final int ITEM_TEXTSIZE = 20;
  private static final int ITEM_SPACE = ITEM_TEXTSIZE * 2 + 5;
  private static final int ITEM_COLOR = 255;
  private static final int ITEM_W = ITEM_TEXTSIZE * 18;
  private static final int ITEM_X = PIC_X + PIC_W + 16;
  private static final int ITEM_Y = SECTION_ITEM_Y + SECTION_ITEM_H + 20;
  
  private static final int FEED_Y  = ITEM_Y + (ITEM_TEXTSIZE + ITEM_SPACE) * 0 + 2;
  private static final int SFEED_Y = ITEM_Y + (ITEM_TEXTSIZE + ITEM_SPACE) * 1 + 2;
  private static final int NET_Y   = ITEM_Y + (ITEM_TEXTSIZE + ITEM_SPACE) * 2 + 2;
  private static final int HOOK_Y  = ITEM_Y + (ITEM_TEXTSIZE + ITEM_SPACE) * 3 + 2;
}
