import processing.io.*;

// 入力のインターフェイス
public interface InputInterface {
  public abstract boolean right();   // →
  public abstract boolean up();      // ↑
  public abstract boolean left();    // ←
  public abstract boolean down();    // ↓
  public abstract boolean buttonA(); // A
  public abstract boolean buttonB(); // B
  public abstract boolean buttonC(); // C
}

// キーボードからの入力
public class KeyboardInput implements InputInterface {
  public boolean right() {
    return keyPressed && keyCode == RIGHT;
  }

  public boolean up() {
    return keyPressed && keyCode == UP;
  }

  public boolean left() {
    return keyPressed && keyCode == LEFT;
  }

  public boolean down() {
    return keyPressed && keyCode == DOWN;
  }

  public boolean buttonA() {
    return keyPressed && key == 'z';
  }

  public boolean buttonB() {
    return keyPressed && key == 'x';
  }

  public boolean buttonC() {
    return keyPressed && key == 'c';
  }
}

// アーケードからの入力
public class ArcadeInput implements InputInterface {
  public static final int RIGHT = 18;
  public static final int UP = 4;
  public static final int LEFT = 27;
  public static final int DOWN = 17;
  public static final int ROUND_UP = 22;
  public static final int ROUND_LEFT = 24;
  public static final int ROUND_RIGHT = 23;

  public ArcadeInput() {
    GPIO.pinMode(RIGHT, GPIO.INPUT_PULLUP);
    GPIO.pinMode(UP, GPIO.INPUT_PULLUP);
    GPIO.pinMode(LEFT, GPIO.INPUT_PULLUP);
    GPIO.pinMode(DOWN, GPIO.INPUT_PULLUP);
    GPIO.pinMode(ROUND_UP, GPIO.INPUT_PULLUP);
    GPIO.pinMode(ROUND_LEFT, GPIO.INPUT_PULLUP);
    GPIO.pinMode(ROUND_RIGHT, GPIO.INPUT_PULLUP);
  }

  public boolean right() {
    return GPIO.digitalRead(RIGHT) == GPIO.LOW;
  }

  public boolean up() {
    return GPIO.digitalRead(UP) == GPIO.LOW;
  }

  public boolean left() {
    return GPIO.digitalRead(LEFT) == GPIO.LOW;
  }

  public boolean down() {
    return GPIO.digitalRead(DOWN) == GPIO.LOW;
  }

  public boolean buttonA() {
    return GPIO.digitalRead(ROUND_UP) == GPIO.LOW;
  }

  public boolean buttonB() {
    return GPIO.digitalRead(ROUND_LEFT) == GPIO.LOW;
  }

  public boolean buttonC() {
    return GPIO.digitalRead(ROUND_RIGHT) == GPIO.LOW;
  }
}

// キーボード・アーケード同時対応
public class MixInput implements InputInterface {
  private KeyboardInput keyboardInput = new KeyboardInput();
  private ArcadeInput arcadeInput = new ArcadeInput();

  public boolean right() {
    return keyboardInput.right() || arcadeInput.right();
  }

  public boolean up() {
    return keyboardInput.up() || arcadeInput.up();
  }

  public boolean left() {
    return keyboardInput.left() || arcadeInput.left();
  }

  public boolean down() {
    return keyboardInput.down() || arcadeInput.down();
  }

  public boolean buttonA() {
    return keyboardInput.buttonA() || arcadeInput.buttonA();
  }

  public boolean buttonB() {
    return keyboardInput.buttonB() || arcadeInput.buttonB();
  }

  public boolean buttonC() {
    return keyboardInput.buttonC() || arcadeInput.buttonC();
  }
}

// 入力
public static class Input_title {
  protected static InputInterface inputInterface;

  // 前回の状態
  protected static boolean prevRight = false;
  protected static boolean prevUp = false;
  protected static boolean prevLeft = false;
  protected static boolean prevDown = false;
  protected static boolean prevButtonA = false;
  protected static boolean prevButtonB = false;
  protected static boolean prevButtonC = false;

  public static void setInputInterface(InputInterface inputInterface) {
    Input_title.inputInterface = inputInterface;
    prevRight = false;
    prevUp = false;
    prevLeft = false;
    prevDown = false;
    prevButtonA = false;
    prevButtonB = false;
    prevButtonC = false;
  }

  public static boolean right() {
    return inputInterface.right();
  }

  public static boolean up() {
    return inputInterface.up();
  }

  public static boolean left() {
    return inputInterface.left();
  }

  public static boolean down() {
    return inputInterface.down();
  }

  public static boolean buttonA() {
    return inputInterface.buttonA();
  }

  public static boolean buttonB() {
    return inputInterface.buttonB();
  }

  public static boolean buttonC() {
    return inputInterface.buttonC();
  }

  public static boolean anyButton() {
    return right() || up() || left() || down() || buttonA() || buttonB() || buttonC();
  }

  public static boolean rightPress() {
    if (right()) {
      if (prevRight) {
        return false;
      } else {
        prevRight = true;
        return true;
      }
    } else {
      prevRight = false;
      return false;
    }
  }

  public static boolean upPress() {
    if (up()) {
      if (prevUp) {
        return false;
      } else {
        prevUp = true;
        return true;
      }
    } else {
      prevUp = false;
      return false;
    }
  }

  public static boolean leftPress() {
    if (left()) {
      if (prevLeft) {
        return false;
      } else {
        prevLeft = true;
        return true;
      }
    } else {
      prevLeft = false;
      return false;
    }
  }

  public static boolean downPress() {
    if (down()) {
      if (prevDown) {
        return false;
      } else {
        prevDown = true;
        return true;
      }
    } else {
      prevDown = false;
      return false;
    }
  }

  public static boolean buttonAPress() {
    if (buttonA()) {
      if (prevButtonA) {
        return false;
      } else {
        prevButtonA = true;
        return true;
      }
    } else {
      prevButtonA = false;
      return false;
    }
  }

  public static boolean buttonBPress() {
    if (buttonB()) {
      if (prevButtonB) {
        return false;
      } else {
        prevButtonB = true;
        return true;
      }
    } else {
      prevButtonB = false;
      return false;
    }
  }

  public static boolean buttonCPress() {
    if (buttonC()) {
      if (prevButtonC) {
        return false;
      } else {
        prevButtonC = true;
        return true;
      }
    } else {
      prevButtonC = false;
      return false;
    }
  }
  
  public static boolean anyButtonPress() {
    return rightPress() || upPress() || leftPress() || downPress() || buttonAPress() || buttonBPress() || buttonCPress();
  }

  public static boolean rightRelease() {
    if (right()) {
      prevRight = true;
      return false;
    } else {
      if (prevRight) {
        prevRight = false;
        return true;
      } else {
        return false;
      }
    }
  }

  public static boolean upRelease() {
    if (up()) {
      prevUp = true;
      return false;
    } else {
      if (prevUp) {
        prevUp = false;
        return true;
      } else {
        return false;
      }
    }
  }

  public static boolean leftRelease() {
    if (left()) {
      prevLeft = true;
      return false;
    } else {
      if (prevLeft) {
        prevLeft = false;
        return true;
      } else {
        return false;
      }
    }
  }

  public static boolean downRelease() {
    if (down()) {
      prevDown = true;
      return false;
    } else {
      if (prevDown) {
        prevDown = false;
        return true;
      } else {
        return false;
      }
    }
  }

  public static boolean buttonARelease() {
    if (buttonA()) {
      prevButtonA = true;
      return false;
    } else {
      if (prevButtonA) {
        prevButtonA = false;
        return true;
      } else {
        return false;
      }
    }
  }

  public static boolean buttonBRelease() {
    if (buttonB()) {
      prevButtonB = true;
      return false;
    } else {
      if (prevButtonB) {
        prevButtonB = false;
        return true;
      } else {
        return false;
      }
    }
  }

  public static boolean buttonCRelease() {
    if (buttonC()) {
      prevButtonC = true;
      return false;
    } else {
      if (prevButtonC) {
        prevButtonC = false;
        return true;
      } else {
        return false;
      }
    }
  }

  public static boolean anyButtonRelease() {
    return rightRelease() || upRelease() || leftRelease() || downRelease() || buttonARelease() || buttonBRelease() || buttonCRelease();
  }
}
