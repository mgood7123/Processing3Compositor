class Window {
  public PGraphics graphics;
  Window object;
  
  int height;
  int width;
  
  Window() {} // implicit super constructor required

  Window(int width, int height) {
    this.width = width;
    this.height = height;
  }
  
  void attach(Window object) {
    this.object = object;
    this.object.height = height;
    this.object.width = width;
  }
  
  void setup() {
    object.setup();
    graphics = object.graphics;
  }
  
  void draw() {
    object.draw();
    graphics = object.graphics;
  }
}
