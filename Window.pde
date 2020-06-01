class Window {
  public PGraphics graphics;
  
  int height;
  int width;
  int x, y;
  int mouseX, mouseY;
  Window() {} // implicit super constructor required
  void onBeforeResize() {}
  String onRequestType() { return P3D; }
  void onAfterResize() {}
  void setup() {}
  void draw() {}
  void mousePressed() {}
  void mouseDragged() {}
  void mouseReleased() {}
}
