class Window {
  public PGraphics graphics = null;
  
  int height;
  int width;
  int x, y;
  int mouseX, mouseY;
  Window() {} // implicit super constructor required
  void onBeforeResize() {}
  String onRequestType() { return P3D; }
  void onAfterResize() {}
  void setup() {
    graphics.background(0);
  }
  void draw() {
    graphics.background(0);
  }
  void mousePressed() {}
  void mouseDragged() {}
  void mouseReleased() {}
  void mouseMoved() {}
}
