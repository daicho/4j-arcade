import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import processing.io.GPIO; 
import java.util.List; 
import java.util.LinkedList; 
import java.util.Random; 
import java.util.Iterator; 
import java.lang.Iterable; 
import java.util.Map; 
import java.util.HashMap; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class UNAGI extends PApplet {

/*
  ====================================================
  File name: UNAGI.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/



private SceneController sc;

private Minim minim;

public void setup() {
  
  noCursor();
  // size(480, 848);
  frameRate(12);
  noStroke();
  textFont(createFont("PixelMplus10-Regular.ttf", 20, false));
  
  minim = new Minim(this);
  
  sc = new SceneController(
    new IGPIO(),
    // new IKey(),
    new STitle()
    // new SHowto()
    // new SGame(0, 2, new LinkedList<SOUnagi>())
    // new SRanking("TEST", 0, null)
    // new SName(100, null)
    // new SStaff()
  );
}

public void draw() {
  if (sc.action()) {
    exit();
  }
}

public void stop() {
  minim.stop();
}
public AudioPlayer __load__(String s) {
  return minim.loadFile(s);
}
/*
  ====================================================
  File name: CONSTANT.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/

private static final int __WIDTH__  = 480;
private static final int __HEIGHT__ = 848;

private static final int __FRAMERATE__ = 12;
/*
  ====================================================
  File name: Input.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/



abstract class Input {
  private   final boolean[] prev;
  protected final boolean[] crnt;
  
  Input() {
    prev = new boolean[INPUTS];
    crnt = new boolean[INPUTS];
  }
  
  public abstract void UPDATE();
  public void update() {
    for (int i = 0 ; i < INPUTS; i++) {
      prev[i] = crnt[i];
    }
    UPDATE();
  }
  
  public boolean posedge(int i) {
    return !prev[i] && crnt[i];
  }
  
  public boolean posedgeAny() {
    for (int i = 0; i < INPUTS; i++) {
      if (!prev[i] && crnt[i]) {
        return true;
      }
    }
    
    return false;
  }
  
  private static final int INPUTS = 7;
  public  static final int U  = 0;
  public  static final int D  = 1;
  public  static final int R  = 2;
  public  static final int L  = 3;
  public  static final int RU = 4;
  public  static final int RR = 5;
  public  static final int RL = 6;
}

class IGPIO extends Input {
  IGPIO() {
    GPIO.pinMode(PIN_U,  GPIO.INPUT_PULLUP);
    GPIO.pinMode(PIN_D,  GPIO.INPUT_PULLUP);
    GPIO.pinMode(PIN_R,  GPIO.INPUT_PULLUP);
    GPIO.pinMode(PIN_L,  GPIO.INPUT_PULLUP);
    GPIO.pinMode(PIN_RU, GPIO.INPUT_PULLUP);
    GPIO.pinMode(PIN_RR, GPIO.INPUT_PULLUP);
    GPIO.pinMode(PIN_RL, GPIO.INPUT_PULLUP);
  }
  
  @Override
  public void UPDATE() {
    crnt[U]  = GPIO.digitalRead(PIN_U)  == GPIO.LOW;
    crnt[D]  = GPIO.digitalRead(PIN_D)  == GPIO.LOW;
    crnt[R]  = GPIO.digitalRead(PIN_R)  == GPIO.LOW;
    crnt[L]  = GPIO.digitalRead(PIN_L)  == GPIO.LOW;
    crnt[RU] = GPIO.digitalRead(PIN_RU) == GPIO.LOW;
    crnt[RR] = GPIO.digitalRead(PIN_RR) == GPIO.LOW;
    crnt[RL] = GPIO.digitalRead(PIN_RL) == GPIO.LOW;
  }
  
  private static final int PIN_U  = 4;
  private static final int PIN_D  = 17;
  private static final int PIN_R  = 18;
  private static final int PIN_L  = 27;
  private static final int PIN_RU = 22;
  private static final int PIN_RR = 23;
  private static final int PIN_RL = 24;
}

class IKey extends Input {
  @Override
  public void UPDATE() {
    if (!keyPressed) {
      key = ' ';
    }
    
    crnt[U]  = key == 'w';
    crnt[D]  = key == 's';
    crnt[R]  = key == 'd';
    crnt[L]  = key == 'a';
    crnt[RU] = key == ';';
    crnt[RR] = key == ':';
    crnt[RL] = key == 'l';
  }
}

class IRepeat extends Input {
  private final int[] inputs;
  private int   inputs_idx;

  IRepeat(int... inputs) {
    this.inputs = inputs;
  }

  @Override
  public void UPDATE() {
    for (int i = 0; i < crnt.length; i++) {
      crnt[i] = false;
    }

    if (inputs[inputs_idx] > -1) {
      crnt[inputs[inputs_idx]] = true;
    }

    if (++inputs_idx > inputs.length - 1) {
      inputs_idx = 0;
    }
  }
}

class IOnce extends Input {
  IOnce(int input) {
    for (int i = 0; i < crnt.length; i++) {
      crnt[i] = false;
    }
    crnt[input] = true;
  }
  
  @Override
  public void UPDATE() {}
}
/*
  ====================================================
  File name: SBlackout.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/

class SBlackout extends Scene {
  private final SOCount count;
  
  private final int seconds;
  private final int stock;
  private final List<SOUnagi> results;
  
  SBlackout(int count, int seconds, int stock, List<SOUnagi> results) {
    this.seconds = seconds;
    this.stock = stock;
    this.results = results;
    
    this.count = new SOCount(count);
    addObjects(new SOBack(0), this.count);
  }
  
  @Override
  public Scene next() {
    return count.zero() ? new SGame(seconds, stock, results) : this;
  }
}

class SOCount extends SceneObject {
  private int frame;
  
  SOCount(int frame) {
    this.frame = frame;
  }
  
  @Override
  public void RENDER_INIT() {}
  
  @Override
  public void RENDER() {}
  
  @Override
  public void UPDATE(Input input) {
    frame--;
  }
  
  public boolean zero() {
    return frame == 0;
  }
}
/*
  ====================================================
  File name: SGame.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/







class SGame extends Scene {
  private final List<SOUnagi> results;
  
  private final SOUnagi unagi;
  private final SOStage stage;
  private final SOTime  time;
  private final SOStock stock;
  
  SGame(int seconds, int stock, List<SOUnagi> results) {
    final SOBack back = new SOBack(0);
    
    final SOImage logo = new SOImage(LOGO_X, LOGO_Y, "logo/logo-250.png");
    
    unagi = new SOUnagi(
      STAGE_X,
      STAGE_Y,
      new UnagiUnit(STAGE_GW / 2, STAGE_GH / 2 + 0, UnagiUnit.U, UnagiUnit.U),
      new UnagiUnit(STAGE_GW / 2, STAGE_GH / 2 + 1, UnagiUnit.U, UnagiUnit.U),
      new UnagiUnit(STAGE_GW / 2, STAGE_GH / 2 + 2, UnagiUnit.U, UnagiUnit.U),
      new UnagiUnit(STAGE_GW / 2, STAGE_GH / 2 + 3, UnagiUnit.U, UnagiUnit.U)
    );
    
    stage = new SOStage(
      STAGE_X,
      STAGE_Y,
      STAGE_GW,
      STAGE_GH,
      unagi
    );
    
    this.stock = new SOStock(
      STOCK_X,
      STOCK_Y,
      stock
    );
    
    time = new SOTime(TIME_X, TIME_Y, seconds);
    
    final SOSize size = new SOSize(SIZE_X, SIZE_Y, unagi);
    
    final SOQuality quality = new SOQuality(QUALITY_X, QUALITY_Y, unagi);
    
    addObjects(back, logo, unagi, stage, this.stock, time, size, quality);
    
    this.results = results;
    this.results.add(unagi);
  }
  
  @Override
  public Scene next() {
    if (stage.unagiCaptured()) {
      unagi.close();
      stock.close();
      return stock.stock() == 0 ? 
        new SResult(results) :
        new SBlackout(BLACKOUT_COUNT, time.now(), stock.stock() - 1, results);
    }
    
    if (time.now() == -1) {
      unagi.close();
      stock.close();
      return new SResult(results);
    }
    
    return this;
  }
  
  private static final int LOGO_W = 250;
  private static final int LOGO_H = 70;
  private static final int LOGO_X = (__WIDTH__ - LOGO_W) / 2;
  private static final int LOGO_Y = 50;
  
  private static final int STAGE_GW = 23;
  private static final int STAGE_GH = 23;
  private static final int STAGE_W = UnagiUnit.SIZE * STAGE_GW;
  private static final int STAGE_H = UnagiUnit.SIZE * STAGE_GH;
  private static final int STAGE_X = (__WIDTH__  - STAGE_W) / 2;
  private static final int STAGE_Y = LOGO_Y + LOGO_H + 50;
  
  private static final int TIME_X = STAGE_X;
  private static final int TIME_Y = STAGE_Y + STAGE_H + 50;
  
  private static final int SIZE_X = STAGE_X;
  private static final int SIZE_Y = TIME_Y + 80;
  
  private static final int QUALITY_X = STAGE_X;
  private static final int QUALITY_Y = SIZE_Y + 80;
  
  private static final int STOCK_X = STAGE_X + STAGE_W - SOStock.W;
  private static final int STOCK_Y = TIME_Y;
  
  private static final int BLACKOUT_COUNT = __FRAMERATE__ * 1;
}

class SOUnagi extends SceneObject implements Iterable<UnagiUnit> {
  private LinkedList<UnagiUnit> units;
  private UnagiUnit head;
  private UnagiUnit neck;
  private UnagiUnit body;
  private UnagiUnit tail;
  private UnagiUnit pass;
  
  private boolean start;
  
  private int quality;
  private int quality_sub;
  
  private int to;
  private boolean eat;
  
  private boolean move_first;
  private int animation;
  
  private boolean eating;
  private final AudioPlayer eating_sound;
  
  
  SOUnagi(int x, int y, UnagiUnit... units) {
    super(x, y);

    this.units = new LinkedList();
    for (int i = 0; i < units.length; i++){
      if (i == 0) {
        head = units[i];
      }
      else if (i == 1) {
        neck = units[i];
      }
      else if (i == 2) {
        body = units[i];
      }
      else if (i == units.length - 1) {
        tail = units[i];
      }
      this.units.addLast(units[i]);
    }
    
    to = head.to;
    
    move_first = true;
    animation = ANIMATION;
    
    eating_sound = __load__("sound/egg-break1.mp3");
  }
  
  @Override
  public void RENDER_INIT() {
    // ===== pass =====
    if (pass != null) {
      none(pass);
      
      if (animation < ANIMATION) {
        sprite(PIC_PASS[DONTCARE][DONTCARE][pass.to], pass);
      }
    }
    
    // ===== tail =====
    sprite(PIC_TAIL[animation][animation == ANIMATION ? tail.to : tail.from][tail.to], tail);
    
    // ===== body =====
    int i = 0;
    for (UnagiUnit unit : units) {
      if (i < 2) {
        i++;
        continue;
      }
      
      if (i == units.size() - 1) {
        break;
      }
      
      sprite(PIC_BODY[DONTCARE][unit.from][unit.to], unit);
      i++;
    }
    
    // ===== neck =====
    sprite(PIC_NECK[animation][neck.from][neck.to], neck);
    
    // ===== head =====
    sprite(PIC_HEAD[animation][DONTCARE][head.to], head);
  }
  
  @Override
  public void RENDER() {
    if (!start) {
      return;
    }
    
    // ===== pass =====
    if (pass != null) {
      none(pass);
      
      if (animation < ANIMATION) {
        sprite(PIC_PASS[DONTCARE][DONTCARE][pass.to], pass);
      }
    }
    
    // ===== tail =====
    if (pass != null) {
      none(tail);
      sprite(PIC_TAIL[animation][animation == ANIMATION ? tail.to : tail.from][tail.to], tail);
    }
    
    // ===== body =====
    none(body);
    sprite(PIC_BODY[DONTCARE][body.from][body.to], body);
    
    // ===== neck =====
    none(neck);
    sprite(PIC_NECK[animation][neck.from][neck.to], neck);
    
    // ===== head =====
    none(head);
    sprite(PIC_HEAD[animation][DONTCARE][head.to], head);
    
    // ===== eating =====
    if (eating) {
      eating_sound.play();
      eating_sound.rewind();
    }
  }
  
  @Override
  public void UPDATE(Input input) {
    if (!start && input.posedgeAny()) {
      start = true;
    }
    
    switch (head.to) {
      case 0:
      case 2:
        if      (input.posedge(Input.U) && !input.posedge(Input.D)) to = 3;
        else if (input.posedge(Input.D) && !input.posedge(Input.U)) to = 1;
        break;
      case 1:
      case 3:
        if      (input.posedge(Input.R) && !input.posedge(Input.L)) to = 0;
        else if (input.posedge(Input.L) && !input.posedge(Input.R)) to = 2;
        break;
    }
    
    if (!start) {
      return;
    }
    
    eating = false;
    
    if (animation < ANIMATION) {
      animation++;
      return;
    }
    
    if (move_first) {
      final UnagiUnit head_invalid = units.removeFirst();
      head = new UnagiUnit(head_invalid.x, head_invalid.y, head_invalid.from, to);
      units.addFirst(head);
    }
    
    // ===== pass =====
    pass = eat ? null : units.removeLast();
    
    // ===== tail =====
    tail = eat ? tail : units.getLast();
    
    // ===== body =====
    body = neck;
    
    // ===== neck =====
    neck = head;
    
    // ===== head =====
    switch (to) {
      case 0:
        head = new UnagiUnit(neck.x + 1, neck.y, neck.to, to);
        break;
      case 1:
        head = new UnagiUnit(neck.x, neck.y + 1, neck.to, to);
        break;
      case 2:
        head = new UnagiUnit(neck.x - 1, neck.y, neck.to, to);
        break;
      case 3:
        head = new UnagiUnit(neck.x, neck.y - 1, neck.to, to);
        break;
    }
    units.addFirst(head);
    
    eat = false;
    animation = 0;
  }
  
  public void eat(StageObject so) {
    if (so == StageObject.FEED) {
      eat = true;
      eating = true;
    }
    else if (so == StageObject.SFEED) {
      switch (++quality_sub) {
        case QUALITY_UME:
        case QUALITY_TAKE:
        case QUALITY_MATSU:
          quality++;
          break;
        case QUALITY_MATSU + 1:
          quality_sub--;
          break;
      }
      eating = true;
    }
  }
  
  public Vector head() {
    return head.position();
  }
  
  public Vector pass() {
    return pass == null ? null : pass.position();
  }
  
  public int size() {
    return units.size();
  }
  
  public int quality() {
    return quality;
  }
  
  public boolean moved() {
    return animation == 0;
  }
  
  public void close() {
    eating_sound.close();
  }

  private void none(UnagiUnit uu) {
    fill((uu.x + uu.y) % 2 == 0 ? BACK_ODD : BACK_EVEN);
    rect(uu.x * UnagiUnit.SIZE, uu.y * UnagiUnit.SIZE, UnagiUnit.SIZE, UnagiUnit.SIZE);
  }

  private void sprite(PImage sprite, UnagiUnit uu) {
    image(sprite, uu.x * UnagiUnit.SIZE, uu.y * UnagiUnit.SIZE);
  }
  
  @Override
  public Iterator<UnagiUnit> iterator() {
    return units.iterator();
  }

  private static final int BACK_ODD  = 0xff89c3eb;
  private static final int BACK_EVEN = 0xffbcd8eb;
  
  private static final int QUALITY_MATSU = 6;
  private static final int QUALITY_TAKE  = 4;
  private static final int QUALITY_UME   = 2;
  
  private static final int ANIMATION = 1;

  private static final int DONTCARE = 0;
  
  private final PImage[][][] PIC_HEAD;
  private final PImage[][][] PIC_NECK;
  private final PImage[][][] PIC_BODY;
  private final PImage[][][] PIC_TAIL;
  private final PImage[][][] PIC_PASS;

  {
    PIC_HEAD = new PImage[2][1][4];
    PIC_NECK = new PImage[2][4][4];
    PIC_BODY = new PImage[1][4][4];
    PIC_TAIL = new PImage[2][4][4];
    PIC_PASS = new PImage[1][1][4];
    
    for (int i = 0; i < ANIMATION + 1; i++) {
      for (int from = 0; from < 4; from++) {
        for (int to = 0; to < 4; to++) {
          if (from == DONTCARE) {
            PIC_HEAD[i][0][to] = loadImage("sprite/unagi/head-" + i + "-x-" + to + ".png");
          }
          
          if (i == DONTCARE && from == DONTCARE) {
            PIC_PASS[DONTCARE][DONTCARE][to] = loadImage("sprite/unagi/pass-x-x-" + to + ".png");
          }
          
          if (from != to && (from + to) % 2 == 0) {
            continue;
          }
          
          PIC_NECK[i][from][to] = loadImage("sprite/unagi/neck-" + i + "-" + from + "-" + to + ".png");
          
          if (i == DONTCARE) {
            PIC_BODY[DONTCARE][from][to] = loadImage("sprite/unagi/body-x-" + from + "-" + to + ".png");
          }
          
          if (i == ANIMATION) {
            if (from != to) {
              continue;
            }
            PIC_TAIL[i][from][to] = loadImage("sprite/unagi/tail-" + i + "-" + from + "-" + to + ".png");
          }
          else {
            PIC_TAIL[i][from][to] = loadImage("sprite/unagi/tail-" + i + "-" + from + "-" + to + ".png");
          }
        }
      }
    }
  }
  
}

class UnagiUnit {
  private final int x;
  private final int y;
  private final int from;
  private final int to;
  
  UnagiUnit(int x, int y, int from, int to) {
    this.x = x;
    this.y = y;
    this.from = from;
    this.to = to;
  }
  
  public Vector position() {
    return new Vector(x, y);
  }
  
  public static final int SIZE = 16;
  public static final int U = 3;
  public static final int D = 1;
  public static final int R = 0;
  public static final int L = 2;
}

class SOStage extends SceneObject {
  private final StageObject[][] map;
  private final SOUnagi unagi;
  private final Random random;
  
  private Vector feed;
  private Vector sfeed;
  private Vector hook;
  
  private boolean render_feed;

  private boolean render_sfeed;
  private boolean render_hook;

  private boolean appear_sfeed;
  private boolean appear_hook;

  private int step_sfeed;
  private int step_hook;

  private boolean captured;
  
  private boolean start;
  
  SOStage(int x, int y, int w, int h, SOUnagi unagi) {
    super(x, y);

    map = new StageObject[w][h];
    for (int sx = 0; sx < w; sx++) {
      for (int sy = 0; sy < h; sy++) {
        map[sx][sy] = (sx == 0 || sy == 0 || sx == w - 1 || sy == h - 1) ? 
          StageObject.CAPTURE : StageObject.NONE;
      }
    }

    this.unagi = unagi;
    for (UnagiUnit unit : unagi) {
      map[unit.position().x][unit.position().y] = StageObject.UNAGI;
    }
    
    random = new Random();
    
    feed = search();
    put(StageObject.FEED, feed);
    
    step_sfeed = STEP_SFEED_APPEAR;
    step_hook  = STEP_HOOK_APPEAR;
  }
  
  @Override
  public void RENDER_INIT() {
    image(loadImage("init/SOStage.png"), 0, 0);
    unagi.RENDER_INIT();
    sprite(PIC_FEED, feed);
  }
  
  @Override
  public void RENDER() {
    if (!start) {
      return;
    }
    
    if (render_feed) {
      sprite(PIC_FEED, feed);
    }
    
    if (render_sfeed) {
      if (appear_sfeed) {
        sprite(PIC_SFEED, sfeed);
      }
      else {
        none(sfeed);
      }
    }
    
    if (render_hook) {
      if (appear_hook) {
        sprite(PIC_HOOK, hook);
      }
      else {
        none(hook);
      }
    }
  }
  
  @Override
  public void UPDATE(Input input) {
    if (!start && input.posedgeAny()) {
      start = true;
    }
    
    if (!start) {
      return;
    }
    
    render_sfeed = false;
    render_hook  = false;
    
    if (!unagi.moved()) {
      return;
    }
    
    // ===== sfeed, hook =====
    step_sfeed--;
    step_hook--;
    
    // ===== unagi =====
    if (unagi.pass() != null) {
      put(StageObject.NONE, unagi.pass());
    }
    
    switch (map[unagi.head().x][unagi.head().y]) {
      case NONE:
        break;
      case UNAGI:
      case CAPTURE:
        captured = true;
        break;
      case FEED:
        unagi.eat(StageObject.FEED);
        feed = search();
        put(StageObject.FEED, feed);
        render_feed = true;
        break;
      case SFEED:
        unagi.eat(StageObject.SFEED);
        step_sfeed = STEP_SFEED_APPEAR;
        break;
    }
    
    put(StageObject.UNAGI, unagi.head());

    // ===== sfeed, hook =====
    if (step_sfeed == 0) {
      if (appear_sfeed) {
        put(StageObject.NONE, sfeed);
        step_sfeed   = STEP_SFEED_APPEAR;
        appear_sfeed = false;
      }
      else {
        sfeed = search();
        put(StageObject.SFEED, sfeed);
        step_sfeed   = STEP_SFEED_DISAPPEAR;
        appear_sfeed = true;
      }
      render_sfeed = true;
    }
    
    if (step_hook == 0) {
      if (appear_hook) {
        put(StageObject.NONE, hook);
        step_hook   = STEP_HOOK_APPEAR;
        appear_hook = false;
        render_hook = true;
      }
      else {
        hook = search(unagi.head(), DIST_HOOK);
        if (hook != null) {
          put(StageObject.CAPTURE, hook);
          step_hook   = STEP_HOOK_DISAPPEAR;
          appear_hook = true;
          render_hook = true;
        }
        else {
          step_hook = 1;
        }
      }
    }
  }

  public boolean unagiCaptured() {
    return captured;
  }
  
  private void none(Vector v) {
    fill((v.x + v.y) % 2 == 0 ? BACK_ODD : BACK_EVEN);
    rect(v.x * UnagiUnit.SIZE, v.y * UnagiUnit.SIZE, UnagiUnit.SIZE, UnagiUnit.SIZE);
  }
  
  private Vector search() {
    Vector candidate;
    while (true) {
      candidate = new Vector(
        random.nextInt(map.length - 2) + 1,
        random.nextInt(map[0].length - 2) + 1
      );
      if (get(candidate) == StageObject.NONE) {
        return candidate;
      }
    }
  }

  private Vector search(Vector v, int dist) {
    final List<Vector> candidates = new ArrayList<Vector>();
    for (int x = -dist; x <= dist + 1; x++) {
      for (int pm = -1; pm < 2; pm += 2) {
        final Vector candidate = new Vector(
          v.x + x,
          v.y + (dist - Math.abs(x)) * (0 - pm)
        );

        if (candidate.x < 0 || candidate.x > map.length - 1) {
          continue;
        }

        if (candidate.y < 0 || candidate.y > map[0].length - 1) {
          continue;
        }

        if (get(candidate) == StageObject.NONE) {
          candidates.add(candidate);
        }
      }
    }

    if (candidates.isEmpty()) {
      return null;
    }

    return candidates.get(random.nextInt(candidates.size()));
  }

  private void put(StageObject so, Vector v) {
    map[v.x][v.y] = so;
  }

  private StageObject get(Vector v) {
    return map[v.x][v.y];
  }
  
  private void sprite(PImage sprite, Vector v) {
    image(sprite, v.x * GRIDSIZE, v.y * GRIDSIZE);
  }
  
  public static final int BACK_ODD  = 0xff89c3eb;
  public static final int BACK_EVEN = 0xffbcd8eb;
  
  private static final int GRIDSIZE = 16;
  
  private static final int STEP_SFEED_APPEAR   = 100;
  private static final int STEP_SFEED_DISAPPEAR =  40;
  
  private static final int STEP_HOOK_APPEAR   = 10;
  private static final int STEP_HOOK_DISAPPEAR = 40;
  
  private static final int DIST_HOOK = 5;
  
  private final PImage PIC_FEED;
  private final PImage PIC_SFEED;
  private final PImage PIC_HOOK;
  
  {
    PIC_FEED  = loadImage("sprite/feed.png");
    PIC_SFEED = loadImage("sprite/sfeed.png");
    PIC_HOOK  = loadImage("sprite/hook.png");
  }
}

enum StageObject {
  NONE,
  UNAGI,
  CAPTURE,
  FEED,
  SFEED
}

class SOStock extends SceneObject {
  private final SOUnagi[] stocks;
  private final Input[]   stockinputs;

  SOStock(int x, int y, int stock) {
    super(x, y);

    stocks      = new SOUnagi[stock];
    stockinputs = new IRepeat[stock];

    if (stock > 0) {
      stocks[0] = new SOUnagi(
        0, 0,
        new UnagiUnit(2, 6, UnagiUnit.D, UnagiUnit.D),
        new UnagiUnit(2, 5, UnagiUnit.D, UnagiUnit.D),
        new UnagiUnit(2, 4, UnagiUnit.D, UnagiUnit.D),
        new UnagiUnit(2, 3, UnagiUnit.D, UnagiUnit.D)
      );
      stockinputs[0] = new IRepeat(
        Input.D, -1,
        Input.R, -1,
        Input.R, -1,
        Input.R, -1,
        Input.U, -1,
        Input.U, -1,
        Input.U, -1,
        Input.U, -1,
        Input.U, -1,
        Input.L, -1,
        Input.L, -1,
        Input.L, -1,
        Input.D, -1,
        Input.D, -1,
        Input.D, -1,
        Input.D, -1
      );

      if (stock > 1) {
        stocks[1] = new SOUnagi(
          0, 0,
          new UnagiUnit(5, 3, UnagiUnit.U, UnagiUnit.U),
          new UnagiUnit(5, 4, UnagiUnit.U, UnagiUnit.U),
          new UnagiUnit(5, 5, UnagiUnit.U, UnagiUnit.U),
          new UnagiUnit(5, 6, UnagiUnit.U, UnagiUnit.U)
        );
        stockinputs[1] = new IRepeat(
          Input.U, -1,
          Input.L, -1,
          Input.L, -1,
          Input.L, -1,
          Input.D, -1,
          Input.D, -1,
          Input.D, -1,
          Input.D, -1,
          Input.D, -1,
          Input.R, -1,
          Input.R, -1,
          Input.R, -1,
          Input.U, -1,
          Input.U, -1,
          Input.U, -1,
          Input.U, -1
        );
      }
    }
  }

  @Override
  public void RENDER_INIT() {
    image(loadImage("init/SOStock.png"), 0, 0);
    for (SOUnagi stock : stocks) {
      stock.render_init();
    }
  }

  @Override
  public void RENDER() {
    for (SOUnagi stock : stocks) {
      stock.render();
    }
  }

  @Override
  public void UPDATE(Input input) {
    for (int i = 0; i < stocks.length; i++) {
      stockinputs[i].update();
      stocks[i].update(stockinputs[i]);
    }
  }
  
  public int stock() {
    return stocks.length;
  }
  
  public void close() {
    for (SOUnagi stock : stocks) {
      stock.close();
    }
  }
  
  public static final int W = UnagiUnit.SIZE * 8;
}

class SOTime extends SceneObject {
  private int     seconds;
  private int     frame;
  private boolean render;
  private boolean start;
  
  SOTime(int x, int y, int seconds) {
    super(x, y);
    this.seconds = seconds;
    frame = FPS;
  }

  @Override
  public void RENDER_INIT() {
    fill(255);
    
    textAlign(LEFT, BOTTOM);
    textSize(TEXTSIZE_SMALL);
    text("のこり：", TAG_XL, TEXTSIZE_BIG);
    text("びょう", UNIT_XL, TEXTSIZE_BIG);
    
    textAlign(RIGHT, TOP);
    textSize(TEXTSIZE_BIG);
    text(seconds, NUMBER_XR, 0);
  }

  @Override
  public void RENDER() {
    if (!render) {
      return;
    }
    
    fill(0);
    rect(NUMBER_XR, 0, -NUMBER_W, TEXTSIZE_BIG);
    
    fill(255);
    textAlign(RIGHT, TOP);
    textSize(TEXTSIZE_BIG);
    text(seconds, NUMBER_XR, 0);
  }

  @Override
  public void UPDATE(Input input) {
    if (!start && input.posedgeAny()) {
      start = true;
    }
    
    if (!start) {
      return;
    }
    
    if (--frame == 0) {
      render = true;
      seconds--;
      frame = FPS;
    }
    else {
      render = false;
    }
  }

  public int now() {
    return seconds;
  }

  private static final int FPS = __FRAMERATE__;
  
  private static final int TEXTSIZE_SMALL = 20;
  private static final int TEXTSIZE_BIG   = 40;
  
  private static final int TEXT_SPACE = 8;
  
  private static final int TAG_W = TEXTSIZE_SMALL * 4;
  private static final int TAG_XL = 0;
  
  private static final int NUMBER_W = TEXTSIZE_BIG / 2 * 3;
  private static final int NUMBER_XR = TAG_XL + TAG_W + NUMBER_W + TEXT_SPACE;
  
  private static final int UNIT_XL   = NUMBER_XR + TEXT_SPACE;
}
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
    
    final SOMessage message = new SOMessage(MESSAGE_X, MESSAGE_Y, MESSAGE_TEXTSIZE, 0, 255, MESSAGE);
    
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
      message,
      pressed
    );
  }
  
  @Override
  public Scene next() {
    if (pressed.pressed()) {
      return new SGame(
        SGAME_TIME,
        SGAME_STOCK,
        new LinkedList<SOUnagi>()
      );
    }
    
    return this;
  }
  
  private static final int SGAME_TIME  = 300;
  private static final int SGAME_STOCK = 2;
  
  private static final String TITLE = "あそびかた";
  private static final int TITLE_TEXTSIZE = 30;
  private static final int TITLE_SPACE = 0;
  private static final int TITLE_COLOR = 0xffffff00;
  private static final int TITLE_W = TITLE_TEXTSIZE * 5;
  private static final int TITLE_H = TITLE_TEXTSIZE;
  private static final int TITLE_X = (__WIDTH__ - TITLE_W) / 2;;
  private static final int TITLE_Y = 70;
  
  private final String[] HOWTO = {
    "ウナギをようしょくしよう！",
    "ウナギはとまらず、すすみつづける。",
    "ウナギはうしろにすすめない。",
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
  private static final int HOWTO_H = (HOWTO_TEXTSIZE + HOWTO_SPACE) * 12 - HOWTO_SPACE;
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
  
  private static final String MESSAGE = "ボタンをおしてはじめる";
  private static final int MESSAGE_TEXTSIZE = 20;
  private static final int MESSAGE_W = MESSAGE_TEXTSIZE * 11;
  private static final int MESSAGE_X = (__WIDTH__ - MESSAGE_W) / 2;
  private static final int MESSAGE_Y = 800;
}
/*
  ====================================================
  File name: SName.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/




class SName extends Scene {
  private final int score;
  private final SOUnagi unagi;
  
  private final SOName name;
  
  SName(int score, SOUnagi unagi) {
    this.score = score;
    this.unagi = unagi;
    
    final SOBack back = new SOBack(0);
    final SOMessage message = new SOMessage(
      MESSAGE_X, MESSAGE_Y,
      MESSAGE_TEXTSIZE, 0, MESSAGE_COLOR,
      MESSAGE
    );
    final SOMessage howto = new SOMessage(
      HOWTO_X, HOWTO_Y,
      HOWTO_TEXTSIZE, 0, HOWTO_COLOR,
      HOWTO
    );
    final SOMessage howto_complete = new SOMessage(
      HOWTO_X, HOWTO_Y,
      HOWTO_TEXTSIZE, 0, HOWTO_COMPLETE_COLOR,
      HOWTO_COMPLETE
    );
    final SOCursor cursor = new SOCursor(
      KEYBOARD_X, KEYBOARD_Y,
      0, 0,
      SOKeyboard.KEY_H - 1, SOKeyboard.KEY_V - 1
    );
    this.name = new SOName(NAME_X, NAME_Y);
    final SOKeyboard keyboard = new SOKeyboard(KEYBOARD_X, KEYBOARD_Y, cursor, name);
    
    addObjects(back, message, howto, howto_complete, cursor, keyboard, name);
  }
  
  @Override
  public Scene next() {
    if (name.complete() != null) {
      name.close();
      return new SRanking(
        name.complete().length() > 0 ? name.complete() : DEFAULTNAME,
        score,
        unagi,
        null
      );
    }
    
    return this;
  }
  
  private static final String DEFAULTNAME = "ななしのせいさんしゃ";
  
  private static final String HOWTO = "ひだり-けす 　　 　　　 みぎ-にゅうりょく";
  private static final int HOWTO_TEXTSIZE = 20;
  private static final int HOWTO_W = HOWTO_TEXTSIZE * 18 + HOWTO_TEXTSIZE / 2 * 5;
  private static final int HOWTO_X = (__WIDTH__ - HOWTO_W) / 2;
  private static final int HOWTO_Y = 10;
  private static final int HOWTO_COLOR = 0xffff0000;
  
  private static final String HOWTO_COMPLETE = "　　　 　　 なか-おわる";
  private static final int HOWTO_COMPLETE_COLOR = 0xff00ffff;
  
  private static final String MESSAGE = "あなたのなまえ";
  private static final int MESSAGE_TEXTSIZE = 30;
  private static final int MESSAGE_W = 7 * MESSAGE_TEXTSIZE;
  private static final int MESSAGE_X = (__WIDTH__ - MESSAGE_W) / 2;
  private static final int MESSAGE_Y = HOWTO_X + 30;
  private static final int MESSAGE_COLOR = 255;
  
  private static final int NAME_X = (__WIDTH__ - SOName.W) / 2;
  private static final int NAME_Y = MESSAGE_Y + MESSAGE_TEXTSIZE + 10;
  
  private static final int KEYBOARD_X = (__WIDTH__ - SOKeyboard.W) / 2;
  private static final int KEYBOARD_Y = NAME_Y + 60;
}

class SOCursor extends SceneObject {
  private final int x_limit;
  private final int y_limit;
  
  private int x;
  private int y;
  
  private int x_prev;
  private int y_prev;
  
  private boolean flash;
  private int cycle_flash;
  private boolean dark;
  
  SOCursor(int x, int y, int cursor_x, int cursor_y, int x_limit, int y_limit) {
    super(x, y);
    this.x = cursor_x;
    this.y = cursor_y;
    this.x_limit = x_limit;
    this.y_limit = y_limit;
    cycle_flash = CYCLE_FLASH;
  }
  
  @Override
  public void RENDER_INIT() {
    fill(255);
    render_cursor(x, y);
  }
  
  @Override
  public void RENDER() {
    if (x != x_prev || y != y_prev) {
      fill(0);
      render_cursor(x_prev, y_prev);
      fill(255);
      render_cursor(x, y);
      return;
    }
    
    if (flash) {
      fill(dark ? 0 : 255);
      render_cursor(x, y);
    }
  }
  
  @Override
  public void UPDATE(Input input) {
    y_prev = y;
    if (input.posedge(Input.U) && !input.posedge(Input.D)) {
      y = y != 0 ? y - 1 : y_limit;
    }
    else if (input.posedge(Input.D) && !input.posedge(Input.U)) {
      y = y != y_limit ? y + 1 : 0;
    }
    
    x_prev = x;
    if (input.posedge(Input.R) && !input.posedge(Input.L)) {
      x = x != x_limit ? x + 1 : 0;
    }
    else if (input.posedge(Input.L) && !input.posedge(Input.R)) {
      x = x != 0 ? x - 1 : x_limit;
    }
    
    if (--cycle_flash == 0) {
      cycle_flash = CYCLE_FLASH;
      dark = !dark;
      flash = true;
    }
    else {
      flash = false;
    }
  }
  
  private void render_cursor(int x, int y) {
    rect((W + SPACE_H) * x, TEXTSIZE + (SPACE_V + TEXTSIZE) * y + UNDER, W, H);
  }
  
  public Vector position() {
    return new Vector(x, y);
  }
  
  private static final int TEXTSIZE = 30;
  
  private static final int W = TEXTSIZE;
  private static final int H = TEXTSIZE / 10;
  
  private static final int SPACE_H = 5;
  private static final int SPACE_V = 12;
  private static final int UNDER   = 5;
  
  private static final int CYCLE_FLASH = 15;
}

class SOName extends SceneObject {
  private final AudioPlayer sound;
  
  private final SOCursor cursor;
  private int cursor_input;
  
  private final char[] name;
  
  private boolean put;
  private boolean replace;
  private boolean delete;
  
  private String  complete;
  
  SOName(int x, int y) {
    super(x, y);
    
    sound = __load__("sound/drum-japanese1.mp3");
    
    cursor = new SOCursor(0, 0, 0, 0, LENGTH - 1, 0);
    name   = new char[LENGTH];
    
    cursor_input = 0;
  }
  
  @Override
  public void RENDER_INIT() {
    for (int i = 0; i < LENGTH; i++) {
      new SOCursor(0, 0, i, 0, 0, 0).RENDER_INIT();
    }
  }
  
  @Override
  public void RENDER() {
    final int idx = cursor.position().x;
    cursor.RENDER();
    
    textAlign(LEFT, TOP);
    
    if (put) {
      if (idx == LENGTH - 1 && name[idx] != '\0') {
        fill(0);
        rect((TEXTSIZE + SPACE) * idx, 0, TEXTSIZE, TEXTSIZE);
        fill(255);
        text(name[idx], (TEXTSIZE + SPACE) * idx, 0);
      }
      else {
        new SOCursor(0, 0, idx - 1, 0, 0, 0).RENDER_INIT();
        fill(255);
        text(name[idx - 1], (TEXTSIZE + SPACE) * (idx - 1), 0);
      }
      put = false;
      sound.play();
      sound.rewind();
      return;
    }
    
    if (replace) {
      if (idx == LENGTH - 1 && name[idx] != '\0') {
        fill(0);
        rect((TEXTSIZE + SPACE) * idx, 0, TEXTSIZE, TEXTSIZE);
        fill(255);
        text(name[idx], (TEXTSIZE + SPACE) * idx, 0);
      }
      else {
        fill(0);
        rect((TEXTSIZE + SPACE) * (idx - 1), 0, TEXTSIZE, TEXTSIZE);
        fill(255);
        text(name[idx - 1], (TEXTSIZE + SPACE) * (idx - 1), 0);
      }
      
      replace = false;
      sound.play();
      sound.rewind();
      return;
    }
    
    if (delete) {
      if (idx < LENGTH - 1) {
        new SOCursor(0, 0, idx + 1, 0, 0, 0).RENDER_INIT();
      }
      fill(0);
      rect((TEXTSIZE + SPACE) * idx, 0, TEXTSIZE, TEXTSIZE);
      delete = false;
      sound.play();
      sound.rewind();
      return;
    }
  }
  
  @Override
  public void UPDATE(Input input) {
    cursor.UPDATE(new IOnce(cursor_input));
    cursor_input = 0;
    
    if (input.posedge(Input.RU)) {
      complete = "";
      for (int i = 0; i < LENGTH; i++) {
        if (name[i] == '\0') {
          return;
        }
        complete += name[i];
      }
    }
  }
  
  public void put(char c) {
    final int idx = cursor.position().x;
    
    name[idx] = c;
    if (idx < LENGTH - 1) {
      cursor_input = Input.R;
    }
    
    put = true;
  }
  
  public void dakuten() {
    final int idx = cursor.position().x;
    
    if (idx == 0) {
      return;
    }
    
    if (idx == LENGTH - 1 && name[idx] != '\0') {
      if (DAKUTEN.get(name[idx]) != null) {
        name[idx] = DAKUTEN.get(name[idx]);
        replace = true;
      }
    }
    else {
      if (DAKUTEN.get(name[idx - 1]) != null) {
        name[idx - 1] = DAKUTEN.get(name[idx - 1]);
        replace = true;
      }
    }
  }
  
  public void handakuten() {
    final int idx = cursor.position().x;
    
    if (idx == 0) {
      return;
    }
    
    if (idx == LENGTH - 1 && name[idx] != '\0') {
      if (HANDAKUTEN.get(name[idx]) != null) {
        name[idx] = HANDAKUTEN.get(name[idx]);
        replace = true;
      }
    }
    else {
      if (HANDAKUTEN.get(name[idx - 1]) != null) {
        name[idx - 1] = HANDAKUTEN.get(name[idx - 1]);
        replace = true;
      }
    }
  }
  
  public void small() {
    final int idx = cursor.position().x;
    
    if (idx == 0) {
      return;
    }
    
    if (idx == LENGTH - 1 && name[idx] != '\0') {
      if (SMALL.get(name[idx]) != null) {
        name[idx] = SMALL.get(name[idx]);
        replace = true;
      }
    }
    else {
      if (SMALL.get(name[idx - 1]) != null) {
        name[idx - 1] = SMALL.get(name[idx - 1]);
        replace = true;
      }
    }
  }
  
  public void delete() {
    final int idx = cursor.position().x;
    
    if (idx == 0) {
      return;
    }
    
    if (idx == LENGTH -1 && name[idx] != '\0') {
      name[idx] = '\0';
    }
    else {
      cursor_input = Input.L;
      name[idx - 1] = '\0';
    }
    
    delete = true;
  }
  
  public String complete() {
    return complete;
  }
  
  public void close() {
    sound.close();
  }
  
  private static final int TEXTSIZE = 30;
  private static final int SPACE = 5;
  private static final int LENGTH = 10;
  
  public static final int W = (TEXTSIZE + SPACE) * LENGTH - SPACE;
  public static final int H = TEXTSIZE;
  
  public static final int BAR_W = TEXTSIZE;
  
  private final Map<Character, Character> DAKUTEN = new HashMap<Character, Character>() {{
    put('か', 'が'); put('き', 'ぎ'); put('く', 'ぐ'); put('け', 'げ'); put('こ', 'ご');
    put('さ', 'ざ'); put('し', 'じ'); put('す', 'ず'); put('せ', 'ぜ'); put('そ', 'ぞ');
    put('た', 'だ'); put('ち', 'ぢ'); put('つ', 'づ'); put('て', 'で'); put('と', 'ど');
    put('は', 'ば'); put('ひ', 'び'); put('ふ', 'ぶ'); put('へ', 'べ'); put('ほ', 'ぼ');
    put('ぱ', 'ば'); put('ぴ', 'び'); put('ぷ', 'ぶ'); put('ぺ', 'べ'); put('ぽ', 'ぼ');
    put('が', 'か'); put('ぎ', 'き'); put('ぐ', 'く'); put('げ', 'け'); put('ご', 'こ');
    put('ざ', 'さ'); put('じ', 'し'); put('ず', 'す'); put('ぜ', 'せ'); put('ぞ', 'そ');
    put('だ', 'た'); put('ぢ', 'ち'); put('づ', 'つ'); put('で', 'て'); put('ど', 'と');
    put('ば', 'は'); put('び', 'ひ'); put('ぶ', 'ふ'); put('べ', 'へ'); put('ぼ', 'ほ');
    put('カ', 'ガ'); put('キ', 'ギ'); put('ク', 'グ'); put('ケ', 'ゲ'); put('コ', 'ゴ');
    put('サ', 'ザ'); put('シ', 'ジ'); put('ス', 'ズ'); put('セ', 'ゼ'); put('ソ', 'ゾ');
    put('タ', 'ダ'); put('チ', 'ヂ'); put('ツ', 'ヅ'); put('テ', 'デ'); put('ト', 'ド');
    put('ハ', 'バ'); put('ヒ', 'ビ'); put('フ', 'ブ'); put('ヘ', 'ベ'); put('ホ', 'ボ');
    put('パ', 'バ'); put('ピ', 'ビ'); put('プ', 'ブ'); put('ペ', 'ベ'); put('ポ', 'ポ');
    put('ガ', 'カ'); put('ギ', 'キ'); put('グ', 'ク'); put('ゲ', 'ケ'); put('ゴ', 'コ');
    put('ザ', 'サ'); put('ジ', 'シ'); put('ズ', 'ス'); put('ゼ', 'セ'); put('ゾ', 'ソ');
    put('ダ', 'タ'); put('ヂ', 'チ'); put('ヅ', 'ツ'); put('デ', 'テ'); put('ド', 'ト');
    put('バ', 'ハ'); put('ビ', 'ヒ'); put('ブ', 'フ'); put('ベ', 'ヘ'); put('ボ', 'ホ');
  }};
  
  private final Map<Character, Character> HANDAKUTEN = new HashMap<Character, Character>() {{
    put('は', 'ぱ'); put('ひ', 'ぴ'); put('ふ', 'ぷ'); put('へ', 'ぺ'); put('ほ', 'ぽ');
    put('ば', 'ぱ'); put('び', 'ぴ'); put('ぶ', 'ぷ'); put('べ', 'ぺ'); put('ぼ', 'ぽ');
    put('ぱ', 'は'); put('ぴ', 'ひ'); put('ぷ', 'ふ'); put('ぺ', 'へ'); put('ぽ', 'ほ');
    put('ハ', 'パ'); put('ヒ', 'ピ'); put('フ', 'プ'); put('ヘ', 'ペ'); put('ホ', 'ポ');
    put('バ', 'パ'); put('ビ', 'ピ'); put('ブ', 'プ'); put('ベ', 'ペ'); put('ボ', 'ポ');
    put('パ', 'ハ'); put('ヒ', 'ヒ'); put('プ', 'フ'); put('ペ', 'ヘ'); put('ポ', 'ホ');
  }};
  
  private final Map<Character, Character> SMALL = new HashMap<Character, Character>() {{
    put('あ', 'ぁ'); put('い', 'ぃ'); put('う', 'ぅ'); put('え', 'ぇ'); put('お', 'ぉ');
    put('つ', 'っ');
    put('や', 'ゃ'); put('ゆ', 'ゅ'); put('よ', 'ょ');
    put('わ', 'ゎ');
    put('ぁ', 'あ'); put('ぃ', 'い'); put('ぅ', 'う'); put('ぇ', 'え'); put('ぉ', 'お');
    put('っ', 'つ');
    put('ゃ', 'や'); put('ゅ', 'ゆ'); put('ょ', 'よ');
    put('ゎ', 'わ');
    put('ア', 'ァ'); put('イ', 'ィ'); put('ウ', 'ゥ'); put('エ', 'ェ'); put('オ', 'ォ');
    put('カ', 'ヵ'); put('ケ', 'ヶ');
    put('ツ', 'ッ');
    put('ヤ', 'ャ'); put('ユ', 'ュ'); put('ヨ', 'ョ');
    put('ワ', 'ヮ');
    put('ァ', 'ア'); put('ィ', 'イ'); put('ゥ', 'ウ'); put('ェ', 'エ'); put('ォ', 'オ');
    put('ヵ', 'カ'); put('ヶ', 'ケ');
    put('ッ', 'ツ');
    put('ャ', 'ヤ'); put('ュ', 'ユ'); put('ョ', 'ヨ');
    put('ヮ', 'ワ');
  }};
}

class SOKeyboard extends SceneObject {
  private final SOCursor cursor;
  private final SOName name;
  
  SOKeyboard(int x, int y, SOCursor cursor, SOName name) {
    super(x, y);
    
    this.cursor = cursor;
    this.name = name;
  }
  
  @Override
  public void RENDER_INIT() {
    fill(255);
    textSize(TEXTSIZE);
    textAlign(LEFT, TOP);
    
    for (int y = 0; y < KEYBOARD.length; y++) {
      for (int x = 0; x < KEYBOARD[y].length; x++) {
        text(
          KEYBOARD[y][x], 
          (TEXTSIZE + KEY_SPACE_H) * x,
          (TEXTSIZE + KEY_SPACE_V) * y
        );
      }
    }
  }
  
  @Override
  public void RENDER() {}
  
  @Override
  public void UPDATE(Input input) {
    if (input.posedge(Input.RR) && !input.posedge(Input.RL)) {
      switch (KEYBOARD[cursor.position().y][cursor.position().x]) {
        case '゛':
          name.dakuten();
          break;
        case '゜':
          name.handakuten();
          break;
        case '小':
          name.small();
          break;
        default:
          name.put(KEYBOARD[cursor.position().y][cursor.position().x]);
          break;
      }
      return;
    }
    
    if (input.posedge(Input.RL) && !input.posedge(Input.RR)) {
      name.delete();
      return;
    }
  }
  
  public static final int KEY_H = 11;
  public static final int KEY_V = 16;
  
  private static final int TEXTSIZE = 30;
  private static final int KEY_SPACE_H = 5;
  private static final int KEY_SPACE_V = 12;
  
  public static final int W = (TEXTSIZE + KEY_SPACE_H) * KEY_H - KEY_SPACE_H;
  
  private final char[][] KEYBOARD = {
    { '゛', 'わ', 'ら', 'や', 'ま', 'は', 'な', 'た', 'さ', 'か', 'あ' },
    { '゜', 'を', 'り', '　', 'み', 'ひ', 'に', 'ち', 'し', 'き', 'い' },
    { '小', 'ん', 'る', 'ゆ', 'む', 'ふ', 'ぬ', 'つ', 'す', 'く', 'う' },
    { 'ー', '　', 'れ', '　', 'め', 'へ', 'ね', 'て', 'せ', 'け', 'え' },
    { '！', '　', 'ろ', 'よ', 'も', 'ほ', 'の', 'と', 'そ', 'こ', 'お' },
    { '？', 'ワ', 'ラ', 'ヤ', 'マ', 'ハ', 'ナ', 'タ', 'サ', 'カ', 'ア' },
    { '０', 'ヲ', 'リ', '　', 'ミ', 'ヒ', 'ニ', 'チ', 'シ', 'キ', 'イ' },
    { '１', 'ン', 'ル', 'ユ', 'む', 'フ', 'ヌ', 'ツ', 'ス', 'ク', 'ウ' },
    { '２', '　', 'レ', '　', 'め', 'ヘ', 'ネ', 'テ', 'セ', 'ケ', 'エ' },
    { '３', '　', 'ロ', 'ヨ', 'も', 'ホ', 'ノ', 'ト', 'ソ', 'コ', 'オ' },
    { '４', 'ｑ', 'ｗ', 'ｅ', 'ｒ', 'ｔ', 'ｙ', 'ｕ', 'ｉ', 'ｏ', 'ｐ' },
    { '５', 'ａ', 'ｓ', 'ｄ', 'ｆ', 'ｇ', 'ｈ', 'ｊ', 'ｋ', 'ｌ', '　' },
    { '６', 'ｚ', 'ｘ', 'ｃ', 'ｖ', 'ｂ', 'ｎ', 'ｍ', '　', '　', '　' },
    { '７', 'Ｑ', 'Ｗ', 'Ｅ', 'Ｒ', 'Ｔ', 'Ｙ', 'Ｕ', 'Ｉ', 'Ｏ', 'Ｐ' },
    { '８', 'Ａ', 'Ｓ', 'Ｄ', 'Ｆ', 'Ｇ', 'Ｈ', 'Ｊ', 'Ｋ', 'Ｌ', '　' },
    { '９', 'Ｚ', 'Ⅹ', 'Ｃ', 'Ｖ', 'Ｂ', 'Ｎ', 'Ｍ', '　', '　', '　' }
  };
}
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
    fill(dark ? 255 : 0xffffff00);
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
        case SOChoice.PLAY:
          return new SHowto();
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
  
  private static final String COPYRIGHT = "Copyright (c) NNCT-J2016-UNAGI-TEAM 2019.\nAll rights reserved.";
  private static final int COPYRIGHT_TEXTSIZE = 20;
  private static final int COPYRIGHT_SPACE = 0;
  private static final int COPYRIGHT_COLOR = 0xffffff00;
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
  
  public static final int PLAY    = 0;
  public static final int RANKING = 1;
  public static final int STAFF   = 2;
  
  private static final int CHOICE_LIMIT = 2;
  
  private static final int TEXTSIZE = 30;
  private static final int TEXT_W   = TEXTSIZE * 5;
  private static final int TEXT_SPACE = TEXTSIZE;
  private static final int TEXT_XC  = 0;
  
  private static final int CURSOR_W  = TEXTSIZE;
  private static final int CURSOR_H  = TEXTSIZE;
  private static final int CURSOR_XL = TEXT_XC - TEXT_W / 2 - TEXTSIZE - CURSOR_W;
}
/*
  ====================================================
  File name: Scene.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/

abstract class Scene {
  private List<SceneObject> objects;
  
  Scene() {
    objects = new LinkedList<SceneObject>();
  }

  public void render_init() {
    for (SceneObject objects: objects) {
      objects.render_init();
    }
  }

  public void render() {
    for (SceneObject objects : objects) {
      objects.render();
    }
  }

  public void update(Input input) {
    for (SceneObject objects : objects) {
      objects.update(input);
    }
  }

  abstract public Scene next();

  protected void addObjects(SceneObject... objects) {
    for (SceneObject object : objects) {
      this.objects.add(object);
    }
  }
}

abstract class SceneObject {
  private final Vector matrix;
  
  SceneObject() {
    matrix = null;
  }

  SceneObject(int x, int y) {
    matrix = new Vector(x, y);
  }

  abstract public void RENDER_INIT();
  abstract public void RENDER();
  abstract public void UPDATE(Input input);

  public void render_init() {
    if (matrix != null) {
      pushMatrix();
      translate(matrix.x, matrix.y);
      RENDER_INIT();
      popMatrix();
    }
  }

  public void render() {
    if (matrix != null) {
      pushMatrix();
      translate(matrix.x, matrix.y);
      RENDER();
      popMatrix();
    }
  }
  
  public void update(Input input) {
    UPDATE(input);
  }
}

class Vector {
  public final int x;
  public final int y;
  
  Vector(int x, int y) {
    this.x = x;
    this.y = y;
  }
}

class SOBack extends SceneObject {
  private final int c;
  
  SOBack(int c) {
    super(0, 0);
    this.c = c;
  }
  
  @Override
  public void RENDER_INIT() {
    background(c);
  }
  
  @Override
  public void RENDER() {}
  
  @Override
  public void UPDATE(Input input) {}
}

class SOMessage extends SceneObject {
  private final String[] messages;
  private final int textsize;
  private final int space;
  private final int c;
  
  SOMessage(int x, int y, int textsize, int space, int c, String... messages) {
    super(x, y);
    this.messages = new String[messages.length];
    for (int i = 0; i < messages.length; i++) {
      this.messages[i] = messages[i];
    }
    this.textsize = textsize;
    this.space = space;
    this.c = c;
  }
  
  @Override
  public void RENDER_INIT() {
    fill(c);
    textAlign(LEFT, TOP);
    textSize(textsize);
    
    for (int i = 0; i < messages.length; i++) {
      text(messages[i], 0, (textsize + space) * i);
    }
  }
  
  @Override
  public void RENDER() {}
  
  @Override
  public void UPDATE(Input input) {}
}

class SOImage extends SceneObject {
  private final String imagename;
  
  SOImage(int x, int y, String imagename) {
    super(x, y);
    this.imagename = imagename;
  }

  @Override
  public void RENDER_INIT() {
    image(loadImage(imagename), 0, 0);
  }

  @Override
  public void RENDER() {}

  @Override
  public void UPDATE(Input input) {}
}

class SOSize extends SceneObject {
  private final SOUnagi unagi;
  private int size;
  private boolean render;

  SOSize(int x, int y, SOUnagi unagi) {
    super(x, y);
    this.unagi = unagi;
    size = unagi.size();
  }

  @Override
  public void RENDER_INIT() {
    fill(255);
    
    textAlign(LEFT, BOTTOM);
    textSize(TEXTSIZE_SMALL);
    text("ながさ：", TAG_XL, TEXTSIZE_BIG);
    text("cm", UNIT_XL, TEXTSIZE_BIG);
    
    textAlign(RIGHT, TOP);
    textSize(TEXTSIZE_BIG);
    text(size * CM, NUMBER_XR, 0);
  }

  @Override
  public void RENDER() {
    if (!render) {
      return;
    }

    fill(0);
    rect(NUMBER_XR, 0, -NUMBER_W, TEXTSIZE_BIG);
    
    fill(255);
    textAlign(RIGHT, TOP);
    textSize(TEXTSIZE_BIG);
    text(size * CM, NUMBER_XR, 0);
  }

  @Override
  public void UPDATE(Input input) {
    render = size != unagi.size();
    size   = unagi.size();
  }
  
  public static final int CM = 6;
  
  private static final int TEXTSIZE_SMALL = 20;
  private static final int TEXTSIZE_BIG   = 40;
  
  private static final int TEXT_SPACE = 8;
  
  private static final int TAG_W = TEXTSIZE_SMALL * 4;
  private static final int TAG_XL = 0;
  
  private static final int NUMBER_W = TEXTSIZE_BIG / 2 * 3;
  private static final int NUMBER_XR = TAG_XL + TAG_W + NUMBER_W + TEXT_SPACE;
  
  private static final int UNIT_XL   = NUMBER_XR + TEXT_SPACE;
}

class SOQuality extends SceneObject {
  private final SOUnagi unagi;
  private int quality;
  private boolean render;
  
  SOQuality(int x, int y, SOUnagi unagi) {
    super(x, y);
    this.unagi = unagi;
  }
  
  @Override
  public void RENDER_INIT() {
    fill(255);
    
    textAlign(LEFT, BOTTOM);
    textSize(TEXTSIZE_SMALL);
    text("ランク：", TAG_XL, TEXTSIZE_BIG);
    
    textAlign(CENTER, TOP);
    textSize(TEXTSIZE_BIG);
    text(
      quality == 0 ? '草':
      quality == 1 ? '梅':
      quality == 2 ? '竹': '松',
      QUALITY_XC, 0
    );
  }

  @Override
  public void RENDER() {
    if (!render) {
      return;
    }

    fill(0);
    rect(QUALITY_XC - QUALITY_W / 2, 0, QUALITY_W, TEXTSIZE_BIG);
    
    fill(255);
    textAlign(CENTER, TOP);
    textSize(TEXTSIZE_BIG);
    text(
      quality == 0 ? '草':
      quality == 1 ? '梅':
      quality == 2 ? '竹': '松',
      QUALITY_XC, 0
    );
  }

  @Override
  public void UPDATE(Input input) {
    if (!unagi.moved()) {
      return;
    }
    
    render  = quality != unagi.quality();
    quality = unagi.quality();
  }
  
  private static final int TEXTSIZE_SMALL = 20;
  private static final int TEXTSIZE_BIG   = 40;
  
  private static final int TEXT_SPACE = 8;
  
  private static final int TAG_W = TEXTSIZE_SMALL * 4;
  private static final int TAG_XL = 0;
  
  private static final int QUALITY_W  = TEXTSIZE_BIG;
  private static final int QUALITY_XC = TAG_XL + TAG_W + TEXTSIZE_BIG / 2 * 3 / 2 + TEXT_SPACE;
}

class SOTiming extends SceneObject {
  private final int[] frames;
  private int frame;
  private int idx;
  private int now;
  
  private final boolean once;
  private final boolean loop;
  
  SOTiming(boolean once, boolean loop, int... frames) {
    this.once = once;
    this.loop = loop;
    
    this.frames = new int[frames.length];
    for (int i = 0; i < frames.length; i++) {
      this.frames[i] = frames[i];
    }
    
    frame = frames[0];
  }
  
  @Override
  public void RENDER_INIT() {}
  
  @Override
  public void RENDER() {}
  
  @Override
  public void UPDATE(Input input) {
    if (once) {
      now = -1;
    }
    
    if (idx == -1) {
      return;
    }
    
    if (frame-- == 0) {
      if (idx == frames.length - 1) {
        idx   = !loop ? -1 : 0;
        frame = !loop ? -1 : frames[idx];
      }
      else {
        frame = frames[++idx];
      }
      
      now = idx;
    }
  }
  
  public int now() {
    return now;
  }
}

class SOTimingWrapper extends SceneObject {
  private final SOTiming timing;
  private final int target;
  private final SceneObject object;
  
  private boolean init;
  
  SOTimingWrapper(SOTiming timing, int target, SceneObject object) {
    super(0, 0);
    this.timing = timing;
    this.target = target;
    this.object = object;
    init = true;
  }
  
  @Override
  public void RENDER_INIT() {}
  
  @Override
  public void RENDER() {
    if (timing.now() != target) {
      return;
    }
    
    if (init) {
      object.render_init();
      init = false;
    }
    else {
      object.render();
    }
  }
  
  @Override
  public void UPDATE(Input input) {
    if (timing.now() != target) {
      return;
    }
    
    object.update(input);
  }
  
  public SceneObject content() {
    return object;
  }
}

class SOPressed extends SceneObject {
  private boolean pressed;
  
   @Override
  public void RENDER_INIT() {}
  
  @Override
  public void RENDER() {}
  
  @Override
  public void UPDATE(Input input) {
    pressed = input.posedgeAny();
  }
  
  public boolean pressed() {
    return pressed;
  }
}
/*
  ====================================================
  File name: SceneController.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/

class SceneController {
  private final Input input;
  
  private Scene prev;
  private Scene crnt;
  
  SceneController(Input input, Scene first) {
    this.input = input;
    crnt = first;
  }
  
  public boolean action() {
    input.update();
    
    if (crnt != prev) {
      crnt.render_init();
    }
    else {
      crnt.render();
    }
    
    crnt.update(input);
    prev = crnt;
    crnt = crnt.next();
    
    return crnt == null;
  }
}
  public void settings() {  fullScreen(); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "UNAGI" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
