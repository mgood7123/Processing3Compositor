class WindowObject {
  public PGraphics graphics;
  Window window;
  
  int height;
  int width;
  int x;
  int y;

  int borderTop = 16;
  int borderLeft = 3;
  int borderBottom = 3;
  int borderRight = 3;
  
  // with a window size of 20 on each side
  // to the application it is 0,0 to 200,200
  // to the window manager it is 0,0 to 240,240
  
  // i would draw a rectangle of 0,0 x 240,240
  // then render my view at 20,20 x 220,220
  // then add buttons to the top of my rectangle
    
  boolean draggable = true;
  
  WindowObject() {} // implicit super constructor required

  WindowObject(int width, int height) {
    this.width = width;
    this.height = height;
    graphics = createGraphics(width, height, P3D);
  }
  
  void attach(Window window) {
    this.window = window;
    this.window.startX = borderLeft+1;
    this.window.startY = borderTop+1;
    this.window.endX = height-borderTop-borderBottom-2;
    this.window.endY = width-borderLeft-borderRight-2;
    this.window.height = this.window.endX;
    this.window.width = this.window.endY;
  }
  
  void correctMouseLocation() {
    // is -1 and -2 correct for MacOS mouse pointer?
    window.mouseX = mouseX-window.startX-1;
    window.mouseY = mouseY-window.startY-2;
    println("mouseX        = " + mouseX +        ", mouseY        = " + mouseY);
    println("borderLeft    = " + borderLeft +    ", borderTop     = " + borderTop);
    println("window.mouseX = " + window.mouseX + ", window.mouseY = " + window.mouseY);
    println("window.startX = " + window.startX + ", window.startY = " + window.startY);
  }

  void clearScreen() {
    graphics.beginDraw();
    graphics.background(0);
    graphics.endDraw();
  }
    
  
  void drawBorders() {
    graphics.beginDraw();
    graphics.rectMode(CORNER);
    graphics.stroke(0);
    graphics.fill(157);
    graphics.rect(0, 0, width, height, 10);
    graphics.endDraw();
  }
  
  void drawGraphics() {
    graphics.beginDraw();
    graphics.image(
      window.graphics,
      window.startX,
      window.startY,
      window.endY,
      window.endX
    );
    graphics.endDraw();
  }
  
  void drawWindow() {
    clearScreen();
    drawBorders();
    drawGraphics();
  }

  void setup() {
    correctMouseLocation();
    window.setup();
    drawWindow();
  }
  
  void draw() {
    correctMouseLocation();
    window.draw();
    drawWindow();
  }
  
  void mousePressed() {
    correctMouseLocation();
    window.mousePressed();
    drawWindow();
  }
  
  void mouseDragged() {
    correctMouseLocation();
    window.mouseDragged();
    drawWindow();
  }
  
  void mouseReleased() {
    correctMouseLocation();
    window.mouseReleased();
    drawWindow();
  }
}
