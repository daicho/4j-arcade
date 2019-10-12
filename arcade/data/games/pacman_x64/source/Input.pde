// 入力のインターフェース
public abstract class InputInterface {
  // 前回の状態
  public boolean prevRight = false;
  public boolean prevUp = false;
  public boolean prevLeft = false;
  public boolean prevDown = false;
  public boolean prevButtonA = false;
  public boolean prevButtonB = false;
  public boolean prevButtonC = false;

  public abstract boolean right();   // →
  public abstract boolean up();      // ↑
  public abstract boolean left();    // ←
  public abstract boolean down();    // ↓
  public abstract boolean buttonA(); // A
  public abstract boolean buttonB(); // B
  public abstract boolean buttonC(); // C

  public boolean rightPress() {
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

  public boolean upPress() {
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

  public boolean leftPress() {
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

  public boolean downPress() {
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

  public boolean buttonAPress() {
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

  public boolean buttonBPress() {
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
  
  public boolean buttonCPress() {
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

  public boolean rightRelease() {
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

  public boolean upRelease() {
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

  public boolean leftRelease() {
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

  public boolean downRelease() {
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

  public boolean buttonARelease() {
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

  public boolean buttonBRelease() {
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
  
  public boolean buttonCRelease() {
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
}

// キーボードからの入力
public class KeyboardInput extends InputInterface {
  public boolean right() {
    if (keyPressed && keyCode == RIGHT) {
      return true;
    } else {
      return false;
    }
  }

  public boolean up() {
    if (keyPressed && keyCode == UP) {
      return true;
    } else {
      return false;
    }
  }

  public boolean left() {
    if (keyPressed && keyCode == LEFT) {
      return true;
    } else {
      return false;
    }
  }

  public boolean down() {
    if (keyPressed && keyCode == DOWN) {
      return true;
    } else {
      return false;
    }
  }

  public boolean buttonA() {
    if (keyPressed && key == 'z') {
      return true;
    } else {
      return false;
    }
  }

  public boolean buttonB() {
    if (keyPressed && key == 'x') {
      return true;
    } else {
      return false;
    }
  }
  
  public boolean buttonC() {
    if (keyPressed && key == 'c') {
      return true;
    } else {
      return false;
    }
  }
}

// アーケードからの入力
public class ArcadeInput extends InputInterface {
  public boolean right() {
    if (keyPressed && key == 'a') {
      return true;
    } else {
      return false;
    }
  }

  public boolean up() {
    if (keyPressed && key == 'b') {
      return true;
    } else {
      return false;
    }
  }

  public boolean left() {
    if (keyPressed && key == 'c') {
      return true;
    } else {
      return false;
    }
  }

  public boolean down() {
    if (keyPressed && key == 'd') {
      return true;
    } else {
      return false;
    }
  }

  public boolean buttonA() {
    if (keyPressed && key == 'e') {
      return true;
    } else {
      return false;
    }
  }

  public boolean buttonB() {
    if (keyPressed && key == 'f') {
      return true;
    } else {
      return false;
    }
  }
  
  public boolean buttonC() {
    if (keyPressed && key == 'g') {
      return true;
    } else {
      return false;
    }
  }
}

// 入力
public static class Input {
  protected static InputInterface inputInterface;

  public static void setInputInterface(InputInterface inputInterface) {
    Input.inputInterface = inputInterface;
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

  public static boolean rightPress() {
    return inputInterface.rightPress();
  }

  public static boolean upPress() {
    return inputInterface.upPress();
  }

  public static boolean leftPress() {
    return inputInterface.leftPress();
  }

  public static boolean downPress() {
    return inputInterface.downPress();
  }

  public static boolean buttonAPress() {
    return inputInterface.buttonAPress();
  }

  public static boolean buttonBPress() {
    return inputInterface.buttonBPress();
  }
  
  public static boolean buttonCPress() {
    return inputInterface.buttonCPress();
  }

  public static boolean rightRelease() {
    return inputInterface.rightRelease();
  }

  public static boolean upRelease() {
    return inputInterface.upRelease();
  }

  public static boolean leftRelease() {
    return inputInterface.leftRelease();
  }

  public static boolean downRelease() {
    return inputInterface.downRelease();
  }

  public static boolean buttonARelease() {
    return inputInterface.buttonARelease();
  }

  public static boolean buttonBRelease() {
    return inputInterface.buttonBRelease();
  }
  
  public static boolean buttonCRelease() {
    return inputInterface.buttonCRelease();
  }
}
