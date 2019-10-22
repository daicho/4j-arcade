import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
Minim minim = new Minim(this);

final int TITLESCENE = 0;
final int GAMESCENE  = 1;
final int RESULTSCENE = 2;
  
public class Sound{
  private AudioPlayer bgm;  //テトリスBGM
  private AudioPlayer se2, se1;

  private int start1, end1;
  private int start2, end2;
  private int start_gameBGM, start_trBGM, end_gameBGM;

  private int nowBGM;
      
  Sound(){
    setupSounds();
  }
  
  private void setupSounds(){
    start1 = 0;
    end1= 0;

    start2 =  1;
    end2 = 2;

    start_gameBGM = 0;
    end_gameBGM = 50;
    start_trBGM = 50;

    bgm = minim.loadFile("sounds/bgm.mp3");

    se1 = minim.loadFile("sounds/se.mp3");
    //se2 = minim.loadFile("sounds/se.mp3");
  }

  /* BGMを再生する関数 */
  public void playBGM(int museNum) {
    nowBGM = museNum;
    switch (nowBGM) {
      case 0:
        bgm.cue(start_trBGM * 2000);
        bgm.setGain(-10);
        break;
      case 1:
        bgm.cue(start_gameBGM * 2000);
        bgm.shiftGain(-50, 0.0, 500);
        break;
    }
    bgm.play();
  }
  
  public void stopAllSounds() {
    bgm.close();
    //se2.close();
    se1.close();
  }

  public void stopBgm() {
    bgm.close();
  }

  public void endingBgm() {
    bgm.shiftGain(-10, -50, 3000);
  }

  public void stopCheck() {
    //if (se2.position() >= this.end2 * 2000 - 200) se2.pause();
    if (se1.position() >= this.end1 * 2000 - 200) se1.pause();
  }

  public void bgmRoop() {
    switch (nowBGM) {
      case 0: if (!bgm.isPlaying()) bgm.cue(start_trBGM); break;
      case 1: if (bgm.position() >= this.end_gameBGM * 2000 - 200) bgm.cue(start_gameBGM); break;
    }
  }

  /* SEを再生する関数 呼び出しは文字列型を引数に */
  public void playSE(String soundName) {
    switch(soundName) {
      case "hold"    : start1 =  2; end1= 3; break;
      case "aline"   : start1 =  3; end1= 5; break;
      case "twoLine" : start1 =  5; end1= 7; break;
      case "tetris"  : start1 =  7; end1=  9; break;
      case "allclear": start1 =  9; end1= 10; break;
      case "tSpin1"  : start1 = 10; end1= 12; break;
      case "tSpin2"  : start1 = 12; end1= 14; break;
      case "tSpin3"  : start1 = 14; end1= 16; break;
      case "score"   : start1 = 16; break;
      
      case "soft": start2 = 1; end2 = 2; break;
      case "drop": start1 = 0; end1 = 2; break;
    }
    
    switch(soundName) {
      /*case "soft":
        se2.cue(start2 * 2000);
        se2.play();
        break;*/
      case "drop":
      default :
        se1.cue(start1 * 2000);
        se1.play();
        break;	
    }
  }
}
