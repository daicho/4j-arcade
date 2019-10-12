import ddf.minim.*;
import ddf.minim.ugens.*;

//BGM
public class BGM {
  protected Minim minim;
  protected AudioPlayer player;
  //protected int length; 

  public BGM(Minim minim) {
    // 音楽ファイル読み込み
    this.minim = minim;
    player = this.minim.loadFile("sounds/schoolSong.mp3");
    //length = player.length();
    player.cue(3500);
  }

  // 再生
  public void play() {
    if (player.position() >= 52000) {
      player.cue(4100);
    }
    player.play();
  }

  // 停止
  public void stop() {
    player.close();
    minim.stop();
    //super.stop();
  }
}

// 効果音
public class SoundEffect {
  protected final float VOLUME = 0.1; // 音量

  protected final float P1 = 787.330; // 音程
  protected final float P2 = 864.255;
  protected final float P3 = 908.456;
  protected final float P4 = 998.991;
  protected final float P5 = 1100.000;
  protected final float P6 = 1212.767;
  protected final float P7 = 1276.562;
  protected final float P8 = 1409.659;

  protected final float P9 = 174.614;
  protected final float P10 = 195.998;
  protected final float P11 = 220;

  protected AudioOutput out;

  public SoundEffect(Minim minim) {
    out = minim.getLineOut();
  }

  // パワーエサを食べたとき
  public void eatPowerFood() {  
    float soundWidth = 0.02, cycle = 0.16; 
    int i;
    for (i = 0; i < 4; i++) {
      out.playNote(soundWidth * 0 + cycle * i, soundWidth, new SquareInstrument(P1, VOLUME, out));
      out.playNote(soundWidth * 1 + cycle * i, soundWidth, new SquareInstrument(P2, VOLUME, out));
      out.playNote(soundWidth * 2 + cycle * i, soundWidth, new SquareInstrument(P3, VOLUME, out));
      out.playNote(soundWidth * 3 + cycle * i, soundWidth, new SquareInstrument(P4, VOLUME, out));
      out.playNote(soundWidth * 4 + cycle * i, soundWidth, new SquareInstrument(P5, VOLUME, out));
      out.playNote(soundWidth * 5 + cycle * i, soundWidth, new SquareInstrument(P6, VOLUME, out));
      out.playNote(soundWidth * 6 + cycle * i, soundWidth, new SquareInstrument(P7, VOLUME, out));
      out.playNote(soundWidth * 7 + cycle * i, soundWidth, new SquareInstrument(P8, VOLUME, out));
    }
  }

  // 普通のエサを食べたとき
  public void eatFood(boolean flag) {
    float soundWidth = 0.015;
    if (flag) {
      out.playNote(soundWidth * 0, soundWidth, new SquareInstrument(P9, VOLUME, out));
      out.playNote(soundWidth * 1, soundWidth, new SquareInstrument(P10, VOLUME, out));
      out.playNote(soundWidth * 2, soundWidth * 2, new SquareInstrument(P11, VOLUME, out));
    } else {
      out.playNote(soundWidth * 0, soundWidth * 2, new SquareInstrument(P11, VOLUME, out));
      out.playNote(soundWidth * 2, soundWidth, new SquareInstrument(P10, VOLUME, out));
      out.playNote(soundWidth * 3, soundWidth, new SquareInstrument(P9, VOLUME, out));
    }
  }
}

// 矩形波を生成
public class SquareInstrument implements Instrument {
  protected Oscil oscil;
  protected AudioOutput out;

  public SquareInstrument(float frequency, float amplitude, AudioOutput out) {
    oscil = new Oscil(frequency, amplitude, Waves.SQUARE);
    this.out = out;
  }

  public void noteOn(float duration) {
    oscil.patch(out);
  }

  public void noteOff() {
    oscil.unpatch(out);
  }
}
