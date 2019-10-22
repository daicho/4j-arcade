// シーン
public interface Scene {
  public void update();
  public void draw();
}

// シーン管理
public static class SceneManager {
  protected static Scene scene;

  public static void setScene(Scene scene) {
    SceneManager.scene = scene;
  }

  public static void update() {
    scene.update();
  }

  public static void draw() {
    scene.draw();
  }
}
