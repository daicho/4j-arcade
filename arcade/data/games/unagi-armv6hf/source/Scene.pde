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
