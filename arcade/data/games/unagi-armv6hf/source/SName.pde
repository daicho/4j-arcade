/*
  ====================================================
  File name: SName.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/

import java.util.Map;
import java.util.HashMap;

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
    final SOCursor cursor = new SOCursor(
      KEYBOARD_X, KEYBOARD_Y,
      0, 0,
      SOKeyboard.KEY_H - 1, SOKeyboard.KEY_V - 1
    );
    this.name = new SOName(NAME_X, NAME_Y);
    final SOKeyboard keyboard = new SOKeyboard(KEYBOARD_X, KEYBOARD_Y, cursor, name);
    
    addObjects(back, message, howto, cursor, keyboard, name);
  }
  
  @Override
  public Scene next() {
    if (name.complete() != null && name.complete().length() > 0) {
      name.close();
      return new SRanking(name.complete(), score, unagi, null);
    }
    
    return this;
  }
  
  private static final String HOWTO = "ひだり-けす なか-おわる みぎ-にゅうりょく";
  private static final int HOWTO_TEXTSIZE = 20;
  private static final int HOWTO_W = HOWTO_TEXTSIZE * 18 + HOWTO_TEXTSIZE / 2 * 5;
  private static final int HOWTO_X = (__WIDTH__ - HOWTO_W) / 2;
  private static final int HOWTO_Y = 10;
  private static final int HOWTO_COLOR = #ffff00;
  
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
