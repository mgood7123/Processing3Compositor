class WindowObject {
  public PGraphics graphics;
  Window window;
  
  int height;
  int width;
  int x;
  int y;
  
  boolean draggable = true;
  
  WindowObject() {} // implicit super constructor required

  WindowObject(int width, int height) {
    this.width = width;
    this.height = height;
  }
  
  void attach(Window window) {
    this.window = window;
    this.window.height = height;
    this.window.width = width;
  }
  
  void setup() {
    window.setup();
    graphics = window.graphics;
  }
  
  void draw() {
    window.draw();
    graphics = window.graphics;
  }
  
  void mousePressed() {
    window.mousePressed();
    graphics = window.graphics;
  }
  
  void mouseDragged() {
    window.mouseDragged();
    graphics = window.graphics;
  }
  
  void mouseReleased() {
    window.mouseReleased();
    graphics = window.graphics;
  }
}
