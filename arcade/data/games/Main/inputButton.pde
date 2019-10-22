class InputButton extends Input {
 
  public InputButton()
  {
   GPIO.pinMode(ArcadeInput.UP, GPIO.INPUT_PULLUP);  // UP
   GPIO.pinMode(ArcadeInput.DOWN, GPIO.INPUT_PULLUP); // Down
   GPIO.pinMode(ArcadeInput.RIGHT, GPIO.INPUT_PULLUP); // Right
   GPIO.pinMode(ArcadeInput.LEFT, GPIO.INPUT_PULLUP); // Left
   GPIO.pinMode(ArcadeInput.ROUND_UP, GPIO.INPUT_PULLUP); // RoundButton Up
   GPIO.pinMode(ArcadeInput.ROUND_RIGHT, GPIO.INPUT_PULLUP); // RoundButton Right
   GPIO.pinMode(ArcadeInput.ROUND_LEFT, GPIO.INPUT_PULLUP); // RoundButton Left
  }
  
  public void update(int delta_time)
  {
    // ---------- GPIO ----------------
    if (GPIO.digitalRead(ArcadeInput.UP) == GPIO.LOW) {
      keyState[H_DROP] = true;
    } else {
      keyState[H_DROP] = false;
    }
    if (GPIO.digitalRead(ArcadeInput.DOWN) == GPIO.LOW) {
      keyState[S_DROP] = true;
    } else {
      keyState[S_DROP] = false;
    }
    if (GPIO.digitalRead(ArcadeInput.RIGHT) == GPIO.LOW) {
      keyState[R_MOVE] = true;
    } else {
      keyState[R_MOVE] = false;
    }
    if (GPIO.digitalRead(ArcadeInput.LEFT) == GPIO.LOW) {
      keyState[L_MOVE] = true;
    } else {
      keyState[L_MOVE] = false;
    }
    if (GPIO.digitalRead(ArcadeInput.ROUND_UP) == GPIO.LOW) {
      keyState[HOLD] = true;
    } else {
      keyState[HOLD] = false;
    }
    if (GPIO.digitalRead(ArcadeInput.ROUND_RIGHT) == GPIO.LOW) {
      keyState[R_TURN] = true;
    } else {
      keyState[R_TURN] = false;
    }
    if (GPIO.digitalRead(ArcadeInput.ROUND_LEFT) == GPIO.LOW) {
      keyState[L_TURN] = true;
    } else {
      keyState[L_TURN] = false;
    }
    
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
