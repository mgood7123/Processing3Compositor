class WindowObject {
  public PGraphics graphics;
  Window window;
  
  int height;
  int width;
  int x;
  int y;
  
  boolean locked = false;
  
  boolean focus = false;

  boolean clickedOnBorder = false;
  boolean clickedOnApp = false;
  
  int xOffset = 0;
  int yOffset = 0;

  int borderTop = 16;
  int borderLeft = 3;
  int borderBottom = 3;
  int borderRight = 3;
    
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
    this.window.endX = width-borderLeft-borderRight-2;
    this.window.width = this.window.endX;

    this.window.startY = borderTop+1;
    this.window.endY = height-borderTop-borderBottom-2;
    this.window.height = this.window.endY;
  }
  
  void correctMouseLocation() {
    // is -1 and -2 correct for MacOS mouse pointer?
    window.mouseX = mouseX-x-window.startX-1;
    window.mouseY = mouseY-y-window.startY-2;
  }

  void clearScreen() {
    graphics.beginDraw();
    graphics.background(0);
    graphics.endDraw();
  }
  
  void drawBordersWithFill(int fill__) {
    graphics.beginDraw();
    graphics.rectMode(CORNER);
    graphics.stroke(0);
    graphics.fill(fill__);
    graphics.rect(0, 0, width, height, 10);
    graphics.endDraw();
  }
  
  void drawBordersLocked() {
    drawBordersWithFill(157+20);
  }

  void drawBordersHighlighted() {
    drawBordersWithFill(157+60);
  }

  void drawBorders() {
    drawBordersWithFill(87);
  }
  
  void drawGraphics() {
    graphics.beginDraw();
    graphics.image(
      window.graphics,
      window.startX,
      window.startY,
      window.endX,
      window.endY
    );
    graphics.endDraw();
  }
  
  boolean mouseIsInWindow() {
    return mouseX >= x && mouseX < width+x &&
      mouseY >= y && mouseY < height+y;
  }
  
  boolean mouseIsInApp() {
    return mouseX >= x+window.startX && mouseX < x+window.startX+window.endX &&
      mouseY >= y+window.startY && mouseY < y+window.startY+window.endY;
  }
  
  boolean mouseIsInBorder() {
    return mouseIsInWindow() && !mouseIsInApp();
  }

  void drawWindow() {
    clearScreen();
    if (focus) {
      if (clickedOnBorder && locked) drawBordersLocked();
      else drawBordersHighlighted();
    } else {
      drawBorders();
    }
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
    if (mouseIsInWindow()) {
      focus = true;
      if (mouseIsInBorder()) {
        clickedOnBorder = true;
        locked = true;
        xOffset = mouseX-x;
        yOffset = mouseY-y;
      } else {
        clickedOnApp = true;
        correctMouseLocation();
        window.mousePressed();
      }
    } else focus = false;
    drawWindow();
  }
  
  void mouseDragged() {
    if(clickedOnBorder && locked) {
      x = mouseX-xOffset; 
      y = mouseY-yOffset; 
    } else {
      if (clickedOnApp) {
        correctMouseLocation();
        window.mouseDragged();
      }
    }
    drawWindow();
  }
  
  void mouseReleased() {
    if (clickedOnBorder) {
      clickedOnBorder = false;
      locked = false;
    } else if (clickedOnApp) {
      clickedOnApp = false;
      correctMouseLocation();
      window.mouseReleased();
    }
    drawWindow();
  }
}
