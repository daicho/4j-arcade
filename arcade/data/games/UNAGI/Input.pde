/*
  ====================================================
  File name: Input.pde
  Copyright (c) Haga Nanami 2019. All rights reserved.
  ====================================================
*/

import processing.io.GPIO;

abstract class Input {
  private   final boolean[] prev;
  protected final boolean[] crnt;
  
  Input() {
    prev = new boolean[INPUTS];
    crnt = new boolean[INPUTS];
  }
  
  public abstract void UPDATE();
  public void update() {
    for (int i = 0 ; i < INPUTS; i++) {
      prev[i] = crnt[i];
    }
    UPDATE();
  }
  
  public boolean posedge(int i) {
    return !prev[i] && crnt[i];
  }
  
  public boolean posedgeAny() {
    for (int i = 0; i < INPUTS; i++) {
      if (!prev[i] && crnt[i]) {
        return true;
      }
    }
    
    return false;
  }
  
  private static final int INPUTS = 7;
  public  static final int U  = 0;
  public  static final int D  = 1;
  public  static final int R  = 2;
  public  static final int L  = 3;
  public  static final int RU = 4;
  public  static final int RR = 5;
  public  static final int RL = 6;
}

class IGPIO extends Input {
  IGPIO() {
    GPIO.pinMode(PIN_U,  GPIO.INPUT_PULLUP);
    GPIO.pinMode(PIN_D,  GPIO.INPUT_PULLUP);
    GPIO.pinMode(PIN_R,  GPIO.INPUT_PULLUP);
    GPIO.pinMode(PIN_L,  GPIO.INPUT_PULLUP);
    GPIO.pinMode(PIN_RU, GPIO.INPUT_PULLUP);
    GPIO.pinMode(PIN_RR, GPIO.INPUT_PULLUP);
    GPIO.pinMode(PIN_RL, GPIO.INPUT_PULLUP);
  }
  
  @Override
  public void UPDATE() {
    crnt[U]  = GPIO.digitalRead(PIN_U)  == GPIO.LOW;
    crnt[D]  = GPIO.digitalRead(PIN_D)  == GPIO.LOW;
    crnt[R]  = GPIO.digitalRead(PIN_R)  == GPIO.LOW;
    crnt[L]  = GPIO.digitalRead(PIN_L)  == GPIO.LOW;
    crnt[RU] = GPIO.digitalRead(PIN_RU) == GPIO.LOW;
    crnt[RR] = GPIO.digitalRead(PIN_RR) == GPIO.LOW;
    crnt[RL] = GPIO.digitalRead(PIN_RL) == GPIO.LOW;
  }
  
  private static final int PIN_U  = 4;
  private static final int PIN_D  = 17;
  private static final int PIN_R  = 18;
  private static final int PIN_L  = 27;
  private static final int PIN_RU = 22;
  private static final int PIN_RR = 23;
  private static final int PIN_RL = 24;
}

class IKey extends Input {
  @Override
  public void UPDATE() {
    if (!keyPressed) {
      key = ' ';
    }
    
    crnt[U]  = key == 'w';
    crnt[D]  = key == 's';
    crnt[R]  = key == 'd';
    crnt[L]  = key == 'a';
    crnt[RU] = key == ';';
    crnt[RR] = key == ':';
    crnt[RL] = key == 'l';
  }
}

class IRepeat extends Input {
  private final int[] inputs;
  private int   inputs_idx;

  IRepeat(int... inputs) {
    this.inputs = inputs;
  }

  @Override
  public void UPDATE() {
    for (int i = 0; i < crnt.length; i++) {
      crnt[i] = false;
    }

    if (inputs[inputs_idx] > -1) {
      crnt[inputs[inputs_idx]] = true;
    }

    if (++inputs_idx > inputs.length - 1) {
      inputs_idx = 0;
    }
  }
}

class IOnce extends Input {
  IOnce(int input) {
    for (int i = 0; i < crnt.length; i++) {
      crnt[i] = false;
    }
    crnt[input] = true;
  }
  
  @Override
  public void UPDATE() {}
}
