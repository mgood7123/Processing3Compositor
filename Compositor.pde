class Compositor__ {
  public PGraphics graphics;  
  ArrayList<WindowObject> windows = new ArrayList<WindowObject>();
  WindowObject w;
  
  Compositor__(int width, int height) {
    graphics = createGraphics(width, height, P3D);
  }
    
  void add(Window window, int width, int height) {
    w = new WindowObject(width, height);
    windows.add(w);
    w.attach(window);
  }
  
  void setLocation(int x, int y) {
    w.x = x;
    w.y = y;
  }

  void setup() {
    graphics.beginDraw();
    for (WindowObject window: windows) {
      window.setup();
      graphics.image(window.graphics, window.x, window.y); //<>//
    }
    graphics.endDraw();
    image(graphics, 0, 0);
  }
  
  void draw() {
    graphics.beginDraw();
    graphics.background(0);
    for (WindowObject window: windows) {
      window.draw();
      graphics.image(window.graphics, window.x, window.y);
    }
    graphics.endDraw();
    image(graphics, 0, 0);
  }
  
  void mousePressed() {
    graphics.beginDraw();
    for (WindowObject window: windows) {
      window.mousePressed();
      graphics.image(window.graphics, window.x, window.y);
    }
    graphics.endDraw();
    image(graphics, 0, 0);
  }
  
  void mouseDragged() {
    graphics.beginDraw();
    for (WindowObject window: windows) {
      window.mouseDragged();
      graphics.image(window.graphics, window.x, window.y);
    }
    graphics.endDraw();
    image(graphics, 0, 0);
  }
  
  void mouseReleased() {
    graphics.beginDraw();
    for (WindowObject window: windows) {
      window.mouseReleased();
      graphics.image(window.graphics, window.x, window.y);
    }
    graphics.endDraw();
    image(graphics, 0, 0);
  }
}
