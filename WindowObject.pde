class WindowObject {
  public PGraphics graphics;
  Window window;
  
  int height;
  int width;
  int x;
  int y;
  int borderWidth = 20;
  
  // with a window size of 20 on each side
  // to the application it is 0,0 to 200,200
  // to the window manager it is 0,0 to 240,240
  
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
