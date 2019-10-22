class InputKey extends Input {

  InputKey() {
   super();
 }
  
  public void update(int delta_time)
  { 
    super.update(delta_time);
  }
  
  public void checkInput() {
    if (key == 'd') {
      keyState[R_MOVE] = true;
    }
    if (key == 'a') {
      keyState[L_MOVE] = true;
    }
    if (key == 'w') {
      keyState[H_DROP] = true;
    }
    if (key == 's') {
      keyState[S_DROP] = true;
    }
    if (key == ' ') {
      keyState[HOLD] = true;
    }
    if (key == 'l') {
      keyState[R_TURN] = true;
    }
    if (key == 'j') {
      keyState[L_TURN] = true;
    }
  }

  public void checkRelease() {
    if (key == 'd') {
      keyState[R_MOVE] = false;
    }
    if (key == 'a') {
      keyState[L_MOVE] = false;
    }
    if (key == 'w') {
      keyState[H_DROP] = false;
    }
    if (key == 's') {
      keyState[S_DROP] = false;
    }
    if (key == ' ') {
      keyState[HOLD] = false;
    }
    if (key == 'l') {
      keyState[R_TURN] = false;
    }
    if (key == 'j') {
      keyState[L_TURN] = false;
    }
  }
}
