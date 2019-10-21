public class UNAGI implements Demo {
  public static final int __WIDTH__  = 480;
  public static final int __FRAMERATE__ = 15;

  private boolean draw = true;
  private SGame sgame  = new SGame(300, 2, new LinkedList<SOUnagi>());
  private boolean init = true;
  
  private IRepeat input = new IRepeat(
    UNAGIInput.R, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    UNAGIInput.D, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    UNAGIInput.L, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    UNAGIInput.U, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    UNAGIInput.R, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    UNAGIInput.D, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    UNAGIInput.L, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    UNAGIInput.U, -1,
    -1, -1,
    -1, -1,
    UNAGIInput.R, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    UNAGIInput.D, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    UNAGIInput.R, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    -1, -1,
    UNAGIInput.U, -1
  );
  
  @Override
  public void draw() {
    sgame.render_init();
    
    if (!draw) {
      input.update();
      sgame.update(input);
      draw = true;
      return;
    }
    
    draw = false;
  }
  
  @Override
  public void reset() {
    sgame = new SGame(300, 2, new LinkedList<SOUnagi>());
    input = new IRepeat(
      UNAGIInput.R, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      UNAGIInput.D, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      UNAGIInput.L, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      UNAGIInput.U, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      UNAGIInput.R, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      UNAGIInput.D, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      UNAGIInput.L, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      UNAGIInput.U, -1,
      -1, -1,
      -1, -1,
      UNAGIInput.R, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      UNAGIInput.D, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      UNAGIInput.R, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      -1, -1,
      UNAGIInput.U, -1
    );
  }
}

abstract class UNAGIInput {
  private   final boolean[] prev;
  protected final boolean[] crnt;
  
  UNAGIInput() {
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

class IRepeat extends UNAGIInput {
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

import java.util.List;
import java.util.LinkedList;
import java.util.Random;
import java.util.Iterator;
import java.lang.Iterable;

abstract class UNAGIScene {
  private List<UNAGISceneObject> objects;
  
  UNAGIScene() {
    objects = new LinkedList<UNAGISceneObject>();
  }

  public void render_init() {
    rectMode(CORNER);
    ellipseMode(CENTER);
    imageMode(CORNER);

    for (UNAGISceneObject objects: objects) {
      objects.render_init();
    }
  }

  public void render() {
    for (UNAGISceneObject objects : objects) {
      objects.render();
    }
  }

  public void update(UNAGIInput input) {
    for (UNAGISceneObject objects : objects) {
      objects.update(input);
    }
  }

  abstract public UNAGIScene next();

  protected void addObjects(UNAGISceneObject... objects) {
    for (UNAGISceneObject object : objects) {
      this.objects.add(object);
    }
  }
}

abstract class UNAGISceneObject {
  private final Vector matrix;
  
  UNAGISceneObject() {
    matrix = null;
  }

  UNAGISceneObject(int x, int y) {
    matrix = new Vector(x, y);
  }

  abstract public void RENDER_INIT();
  abstract public void RENDER();
  abstract public void UPDATE(UNAGIInput input);

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
  
  public void update(UNAGIInput input) {
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

class SGame extends UNAGIScene {
  private final List<SOUnagi> results;
  
  private final SOUnagi unagi;
  private final SOStage stage;
  private final SOTime  time;
  private final SOStock stock;
  
  SGame(int seconds, int stock, List<SOUnagi> results) {
    final SOBack back = new SOBack(0);
    
    final SOImage logo = new SOImage(LOGO_X, LOGO_Y, "UNAGI/logo/logo-250.png");
    
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
    
    textFont(createFont("UNAGI/PixelMplus10-Regular.ttf", 20));
    noStroke();
  }
  
  @Override
  public UNAGIScene next() {
    return this;
  }
  
  private static final int LOGO_W = 250;
  private static final int LOGO_H = 70;
  private static final int LOGO_X = (UNAGI.__WIDTH__ - LOGO_W) / 2;
  private static final int LOGO_Y = 50;
  
  private static final int STAGE_GW = 23;
  private static final int STAGE_GH = 23;
  private static final int STAGE_W = UnagiUnit.SIZE * STAGE_GW;
  private static final int STAGE_H = UnagiUnit.SIZE * STAGE_GH;
  private static final int STAGE_X = (UNAGI.__WIDTH__  - STAGE_W) / 2;
  private static final int STAGE_Y = LOGO_Y + LOGO_H + 50;
  
  private static final int TIME_X = STAGE_X;
  private static final int TIME_Y = STAGE_Y + STAGE_H + 50;
  
  private static final int SIZE_X = STAGE_X;
  private static final int SIZE_Y = TIME_Y + 80;
  
  private static final int QUALITY_X = STAGE_X;
  private static final int QUALITY_Y = SIZE_Y + 80;
  
  private static final int STOCK_X = STAGE_X + STAGE_W - SOStock.W;
  private static final int STOCK_Y = TIME_Y;
  
  private static final int BLACKOUT_COUNT = UNAGI.__FRAMERATE__ * 1;
}

class SOBack extends UNAGISceneObject {
  private final color c;
  
  SOBack(color c) {
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
  public void UPDATE(UNAGIInput input) {}
}

class SOImage extends UNAGISceneObject {
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
  public void UPDATE(UNAGIInput input) {}
}

class SOUnagi extends UNAGISceneObject implements Iterable<UnagiUnit> {
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
    sprite(PIC_TAIL[pass == null ? ANIMATION : animation][animation == ANIMATION ? tail.to : tail.from][tail.to], tail);
    
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
  }
  
  @Override
  public void UPDATE(UNAGIInput input) {
    if (!start && input.posedgeAny()) {
      start = true;
    }
    
    switch (head.to) {
      case 0:
      case 2:
        if      (input.posedge(UNAGIInput.U) && !input.posedge(UNAGIInput.D)) to = 3;
        else if (input.posedge(UNAGIInput.D) && !input.posedge(UNAGIInput.U)) to = 1;
        break;
      case 1:
      case 3:
        if      (input.posedge(UNAGIInput.R) && !input.posedge(UNAGIInput.L)) to = 0;
        else if (input.posedge(UNAGIInput.L) && !input.posedge(UNAGIInput.R)) to = 2;
        break;
    }
    
    if (!start) {
      return;
    }
    
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

  private static final int BACK_ODD  = #89c3eb;
  private static final int BACK_EVEN = #bcd8eb;
  
  private static final int QUALITY_MATSU = 9;
  private static final int QUALITY_TAKE  = 6;
  private static final int QUALITY_UME   = 3;
  
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
            PIC_HEAD[i][0][to] = loadImage("UNAGI/sprite/unagi/head-" + i + "-x-" + to + ".png");
          }
          
          if (i == DONTCARE && from == DONTCARE) {
            PIC_PASS[DONTCARE][DONTCARE][to] = loadImage("UNAGI/sprite/unagi/pass-x-x-" + to + ".png");
          }
          
          if (from != to && (from + to) % 2 == 0) {
            continue;
          }
          
          PIC_NECK[i][from][to] = loadImage("UNAGI/sprite/unagi/neck-" + i + "-" + from + "-" + to + ".png");
          
          if (i == DONTCARE) {
            PIC_BODY[DONTCARE][from][to] = loadImage("UNAGI/sprite/unagi/body-x-" + from + "-" + to + ".png");
          }
          
          PIC_TAIL[i][from][to] = loadImage("UNAGI/sprite/unagi/tail-" + i + "-" + from + "-" + to + ".png");
          
          
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

class SOStage extends UNAGISceneObject {
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
  
  private final Vector[] demo_food;
  private final Vector[] demo_hook;
  
  private int demo_food_idx;
  private int demo_hook_idx;
  
  SOStage(int x, int y, int w, int h, SOUnagi unagi) {
    super(x, y);
    
    demo_food = new Vector[] {
      new Vector(17, 15),
      new Vector(17, 3),
      new Vector(7, 17),
      new Vector(12, 16),
      new Vector(19, 7)
    };
    
    demo_hook = new Vector[] {
      new Vector(15, 18),
      new Vector(11, 16)
    };

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
    image(loadImage("UNAGI/init/SOStage.png"), 0, 0);
    unagi.RENDER_INIT();
    sprite(PIC_FEED, feed);
    
    if (appear_hook) {
      sprite(PIC_HOOK, hook);
    }
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
      else  {
        none(sfeed);
      }
    }
    
    if (render_hook) {
      if (appear_hook) {
        sprite(PIC_HOOK, hook);
      }
      else  {
        none(hook);
      }
    }
  }
  
  @Override
  public void UPDATE(UNAGIInput input) {
    if (!start && input.posedgeAny()) {
      start = true;
    }
    
    if (!start) {
      return;
    }
    
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
    
    println(unagi.head().x, unagi.head().y);
    
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
    else {
      render_sfeed = false;
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
    else {
      render_hook = false;
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
    return demo_food[demo_food_idx++];
  }

  private Vector search(Vector v, int dist) {
    return demo_hook[demo_hook_idx++];
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
  
  public static final color BACK_ODD  = #89c3eb;
  public static final color BACK_EVEN = #bcd8eb;
  
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
    PIC_FEED  = loadImage("UNAGI/sprite/feed.png");
    PIC_SFEED = loadImage("UNAGI/sprite/sfeed.png");
    PIC_HOOK  = loadImage("UNAGI/sprite/hook.png");
  }
}

enum StageObject {
  NONE,
  UNAGI,
  CAPTURE,
  FEED,
  SFEED
}

class SOStock extends UNAGISceneObject {
  private final SOUnagi[] stocks;
  private final UNAGIInput[]   stockinputs;

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
        UNAGIInput.D, -1,
        UNAGIInput.R, -1,
        UNAGIInput.R, -1,
        UNAGIInput.R, -1,
        UNAGIInput.U, -1,
        UNAGIInput.U, -1,
        UNAGIInput.U, -1,
        UNAGIInput.U, -1,
        UNAGIInput.U, -1,
        UNAGIInput.L, -1,
        UNAGIInput.L, -1,
        UNAGIInput.L, -1,
        UNAGIInput.D, -1,
        UNAGIInput.D, -1,
        UNAGIInput.D, -1,
        UNAGIInput.D, -1
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
          UNAGIInput.U, -1,
          UNAGIInput.L, -1,
          UNAGIInput.L, -1,
          UNAGIInput.L, -1,
          UNAGIInput.D, -1,
          UNAGIInput.D, -1,
          UNAGIInput.D, -1,
          UNAGIInput.D, -1,
          UNAGIInput.D, -1,
          UNAGIInput.R, -1,
          UNAGIInput.R, -1,
          UNAGIInput.R, -1,
          UNAGIInput.U, -1,
          UNAGIInput.U, -1,
          UNAGIInput.U, -1,
          UNAGIInput.U, -1
        );
      }
    }
  }

  @Override
  public void RENDER_INIT() {
    image(loadImage("UNAGI/init/SOStock.png"), 0, 0);
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
  public void UPDATE(UNAGIInput input) {
    for (int i = 0; i < stocks.length; i++) {
      stockinputs[i].update();
      stocks[i].update(stockinputs[i]);
    }
  }
  
  public int stock() {
    return stocks.length;
  }
  
  public static final int W = UnagiUnit.SIZE * 8;
}

class SOTime extends UNAGISceneObject {
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
  public void UPDATE(UNAGIInput input) {
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

  private static final int FPS = UNAGI.__FRAMERATE__;
  
  private static final int TEXTSIZE_SMALL = 20;
  private static final int TEXTSIZE_BIG   = 40;
  
  private static final int TEXT_SPACE = 8;
  
  private static final int TAG_W = TEXTSIZE_SMALL * 4;
  private static final int TAG_XL = 0;
  
  private static final int NUMBER_W = TEXTSIZE_BIG / 2 * 3;
  private static final int NUMBER_XR = TAG_XL + TAG_W + NUMBER_W + TEXT_SPACE;
  
  private static final int UNIT_XL   = NUMBER_XR + TEXT_SPACE;
}

class SOSize extends UNAGISceneObject {
  private final SOUnagi unagi;
  private int size;
  private boolean render;

  SOSize(int x, int y, SOUnagi unagi) {
    super(x, y);
    this.unagi = unagi;
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
    text(size * 2, NUMBER_XR, 0);
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
    text(size * 2, NUMBER_XR, 0);
  }

  @Override
  public void UPDATE(UNAGIInput input) {
    render = size != unagi.size();
    size   = unagi.size();
  }
  
  private static final int TEXTSIZE_SMALL = 20;
  private static final int TEXTSIZE_BIG   = 40;
  
  private static final int TEXT_SPACE = 8;
  
  private static final int TAG_W = TEXTSIZE_SMALL * 4;
  private static final int TAG_XL = 0;
  
  private static final int NUMBER_W = TEXTSIZE_BIG / 2 * 3;
  private static final int NUMBER_XR = TAG_XL + TAG_W + NUMBER_W + TEXT_SPACE;
  
  private static final int UNIT_XL   = NUMBER_XR + TEXT_SPACE;
}

class SOQuality extends UNAGISceneObject {
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
  public void UPDATE(UNAGIInput input) {
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
