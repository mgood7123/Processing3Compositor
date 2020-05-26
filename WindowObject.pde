class WindowObject {
  public PGraphics graphics;
  Window window;
  
  int height;
  int width;
  int height2;
  int width2;
  int x;
  int y;
  
  boolean locked = false;
  boolean resizing = false;
  
  boolean focus = false;
  boolean focusable = false;
  boolean draggable = false;
  boolean resizable = true;

  boolean clickedOnResizeBorder = false;
  boolean clickedOnBorder = false;
  boolean clickedOnApp = false;
  
  int xOffset = 0;
  int yOffset = 0;
  int windowStartXOffset = 0;
  int windowStartYOffset = 0;
  int windowEndXOffset = 0;
  int windowEndYOffset = 0;
  int widthOffset = 0;
  int heightOffset = 0;

  int resizeTop = 16;
  int resizeLeft = 3;
  int resizeBottom = 3;
  int resizeRight = 3;

  int borderTop = 16;
  int borderLeft = 3;
  int borderBottom = 3;
  int borderRight = 3;
    
  WindowObject() {} // implicit super constructor required

  WindowObject(int width, int height) {
    this.width = width;
    this.height = height;
    width2 = width;
    height2 = height;
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
    window.mouseX = (mouseX-x-window.startX-1);
    window.mouseY = (mouseY-y-window.startY-2);
    if ((width2-width) != 0) {
      window.mouseX -= (width2-width) / 2;
    }
    if ((height2-height) != 0) {
      window.mouseY -= (height2-height) / 2;
    }
  }

  void clearScreen() {
    graphics.beginDraw();
    graphics.background(255, 0, 0);
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
    return mouseX >= x && mouseX < width2+x &&
      mouseY >= y && mouseY < height2+y;
  }
  
  boolean mouseIsInApp() {
    return mouseX >= x+window.startX && mouseX < x+window.startX+window.endX &&
      mouseY >= y+window.startY && mouseY < y+window.startY+window.endY;
  }
  
  boolean mouseIsInBorder() {
    return mouseIsInWindow() && !mouseIsInApp();
  }

  boolean mouseIsInResizeBorder() {
    return resizable && (mouseIsInWindow() && !mouseIsInApp());
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
  
  void canFocus() {
    focusable = mouseIsInWindow();
  }
  
  boolean resizeTopLeft = false;
  boolean resizeBottomRight = !resizeTopLeft;
  
  int originalWidth;
  int originalHeight;

  void mousePressed() {
    if (mouseIsInResizeBorder()) {
      clickedOnResizeBorder = true;
      resizing = true;
      widthOffset = mouseX-width2;
      heightOffset = mouseY-height2;
      originalWidth = width2;
      originalHeight = height2;
      if (resizeTopLeft) {
        xOffset = mouseX-x;
        yOffset = mouseY-y;
      }
    } else if (mouseIsInBorder()) {
      clickedOnBorder = true;
      locked = true;
      if (draggable) {
        xOffset = mouseX-x;
        yOffset = mouseY-y;
      }
    } else {
      clickedOnApp = true;
      correctMouseLocation();
      window.mousePressed();
    }
    drawWindow();
  }
  
  void mouseDragged() {
    if(clickedOnResizeBorder && resizing) {
      if (resizeTopLeft) {
        int newX = mouseX-xOffset;
        int newY = mouseY-yOffset;
        int newWidth = originalWidth - ((mouseX-widthOffset) - originalWidth);
        int newHeight = originalHeight - ((mouseY-heightOffset) - originalHeight);
        x = newX;
        y = newY;
        width2 = newWidth;
        height2 = newHeight;
        //window.endX = width2-borderLeft-borderRight-2;
        //window.width = window.endX;
        //window.endY = height2-borderTop-borderBottom-2;
        //window.height = window.endY;
      } else if (resizeBottomRight) {
        int newWidth = originalWidth + ((mouseX-widthOffset) - originalWidth);
        int newHeight = originalHeight + ((mouseY-heightOffset) - originalHeight);
        width2 = newWidth;
        height2 = newHeight;
        //window.endX = width2-borderLeft-borderRight-2;
        //window.width = window.endX;
        //window.endY = height2-borderTop-borderBottom-2;
        //window.height = window.endY;
      }
    } else if(clickedOnBorder && locked && draggable) {
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
    if (clickedOnResizeBorder) {
      clickedOnResizeBorder = false;
      resizing = false;
    } else if (clickedOnBorder) {
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
