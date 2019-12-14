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
