// タイマー
public class Timer {
  protected int time; // 設定時間
  protected int left; // 残り時間

  public Timer(int time) {
    this.time = time;
    this.left = time;
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
    left--;
    if (left < 0) {
      left = time;
      return true;
    } else {
      return false;
    }
  }

  // リセット
  public void reset() {
    left = time;
  }
}
