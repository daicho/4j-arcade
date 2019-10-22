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
