// タイマー
public class Timer {
  protected int time;     // 設定時間
  protected int left;     // 残り時間
  protected boolean loop; // タイマーを繰り返すか

  public Timer(int time) {
    this.time = time;
    this.left = time;
    this.loop = true;
  }

  public Timer(int time, boolean loop) {
    this.time = time;
    this.left = time;
    this.loop = loop;
  }

  public int getTime() {
    return this.time;
  }

  public void setTime(int time) {
    this.time = time;
    this.left = time;
  }

  public int getLeft() {
    return this.left;
  }

  // 設定時間が経過したらtrueを返す
  public boolean update() {
    if (left <= 0) {
      if (loop) left = time;
      return true;
    } else {
      left--;
      return false;
    }
  }

  // リセット
  public void reset() {
    left = time;
  }
}
