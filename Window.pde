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
    graphics.beginDraw();
    graphics.background(0);
    graphics.endDraw();
  }
  void draw() {
    graphics.beginDraw();
    graphics.background(0);
    graphics.endDraw();
  }
  void mousePressed() {}
  void mouseDragged() {}
  void mouseReleased() {}
}
