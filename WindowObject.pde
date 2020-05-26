class WindowObject {
  public PGraphics graphics;
  Window window;
  
  boolean displayFPS = false;
  
  int height;
  int minimumHeight = 65;
  int minimumWidth = 65;
  int width;
  int previewHeight;
  int previewWidth;
  int x;
  int y;
  
  boolean locked = false;
  boolean resizing = false;
  
  boolean focus = false;
  boolean focusable = false;
  boolean draggable = true;
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

  int resizeTop = 3;
  int resizeLeft = 3;
  int resizeBottom = 3;
  int resizeRight = 3;

  int borderTop = 20;
  int borderLeft = 3;
  int borderBottom = 3;
  int borderRight = 3;
    
  WindowObject() {} // implicit super constructor required

  WindowObject(int width, int height) {
    this.width = width;
    this.height = height;
    previewWidth = width;
    previewHeight = height;
    graphics = createGraphics(width, height, P3D);
  }
  
  void attach(Window window) {
    this.window = window;
    
    this.window.x = borderLeft+1;
    this.window.width = width-borderLeft-borderRight-2;

    this.window.y = borderTop+1;
    this.window.height = height-borderTop-borderBottom-2;
  }
  
  void correctMouseLocation() {
    // is -1 and -2 correct for MacOS mouse pointer?
    window.mouseX = mouseX-x-window.x-1;
    window.mouseY = mouseY-y-window.y-2;
  }

  boolean mouseIsInWindow() {
    return mouseX >= x && mouseX < width+x &&
      mouseY >= y && mouseY < height+y;
  }
  
  boolean mouseIsInApp() {
    return mouseX >= x+window.x && mouseX < x+window.x+window.width &&
      mouseY >= y+window.y && mouseY < y+window.y+window.height;
  }
  
  boolean mouseIsInBorder() {
    return mouseIsInWindow() && (
      mouseX <= x+borderLeft || mouseX >= (width+x)-borderRight-1 ||
      mouseY <= y+borderTop || mouseY >= (height+y)-borderBottom-2
    );
  }

  boolean mouseIsInResizeBorder() {
    return resizable ? (
      mouseIsInWindow() && (
        mouseX <= x+resizeLeft || mouseX >= (width+x)-resizeRight-1 ||
        mouseY <= y+resizeTop || mouseY >= (height+y)-resizeBottom-2
      )
    ) : false;
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
      window.x,
      window.y,
      window.width,
      window.height
    );
    if (displayFPS) {
      graphics.textSize(16);
      graphics.text("FPS: " + frameRate, 10, borderTop+20);
    }
    graphics.endDraw();
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
    window.onResize();
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
      widthOffset = mouseX-width;
      heightOffset = mouseY-height;
      originalWidth = width;
      originalHeight = height;
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
      int previewWidth_ = 0;
      int previewHeight_ = 0;
      if (resizeTopLeft) {
        // subtract
        previewWidth_ = originalWidth - ((mouseX-widthOffset) - originalWidth);
        previewHeight_ = originalHeight - ((mouseY-heightOffset) - originalHeight);
        if (previewWidth_ > minimumWidth) x = mouseX-xOffset;
        if (previewHeight_ > minimumHeight) y = mouseY-yOffset;
      } else if (resizeBottomRight) {
        // add
        previewWidth_ = originalWidth + ((mouseX-widthOffset) - originalWidth);
        previewHeight_ = originalHeight + ((mouseY-heightOffset) - originalHeight);
      }
      if (previewWidth_ <= minimumWidth) previewWidth = minimumWidth;
      else previewWidth = previewWidth_;
      if (previewHeight_ <= minimumHeight) previewHeight = minimumHeight;
      else previewHeight = previewHeight_;
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
      width = previewWidth;
      height = previewHeight;
      window.width = width-borderLeft-borderRight-2;
      window.height = height-borderTop-borderBottom-2;
      window.onResize();
      window.setup();
      graphics = createGraphics(width, height, P3D);
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
