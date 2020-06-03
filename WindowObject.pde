class WindowObject {
  public PGraphics graphics;
  Window window;
  
  boolean displayFPS = false;
  boolean debug = false;
  
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
  
  private class RectangleCorners {
    int topLeftX, topLeftY;
    int topRightX, topRightY;
    int bottomLeftX, bottomLeftY;
    int bottomRightX, bottomRightY;
    
    RectangleCorners(int startX, int startY, int endX, int endY) {
      topLeftX = startX;
      topLeftY = startY;
      topRightX = endX;
      topRightY = startY;
      bottomLeftX = startX;
      bottomLeftY = endY;
      bottomRightX = endX;
      bottomRightY = endY;
    }
  }
  
  class Hitbox {
    RectangleCorners hitbox;
    int size = -1;
    boolean hit = false;
    boolean debug = false;
    
    void drawHitbox(int red, int green, int blue) {
      graphics.beginDraw();
      graphics.rectMode(CORNER);
      graphics.stroke(0);
      graphics.fill(red, green, blue);
      graphics.rect(hitbox.topLeftX, hitbox.topLeftY, hitbox.bottomRightX+size, hitbox.bottomRightY+size);
      graphics.endDraw();
    }
    
    void drawHitboxUnhit() {
      drawHitbox(255, 0, 0);
    }
    
    void drawHitboxMaybeHit() {
      drawHitbox(128, 128, 0);
    }

    void drawHitboxHit() {
      drawHitbox(0, 255, 0);
    }

    private int roundToNearestMultiple(int x, int n) {
      int mod = x % n;
      if(mod >= (float) n / 2) {
        x += (n-mod);
      } else {
        x -= mod;
      }
      return x;
    }

    Hitbox(int x, int y, int size, boolean debug_) {
      debug = debug_;
      // 0, 1, [2], 3, 4
      //int sr = roundToNearestMultiple(size, 3)/2;
      int s = size/2;
      this.size = s;
      int x1 = x-s;
      int y1 = y-s;
      int x2 = x+s;
      int y2 = y+s;
      hitbox = new RectangleCorners(x1, y1, x2, y2);
    }
    
    void draw(int offsetX, int offsetY) {
      if (debug) {
        if (mouseIsInHitbox(offsetX, offsetY)) drawHitboxHit();
        else drawHitboxUnhit();
      }
    }
    
    boolean mouseIsInHitbox(int offsetX, int offsetY) {
      int x1 = hitbox.topLeftX+offsetX;
      int y1 = hitbox.topLeftY+offsetY;
      int x2 = hitbox.bottomRightX+offsetX;
      int y2 = hitbox.bottomRightY+offsetY;
      println("mouseX = " + mouseX + ", mouseY = " + mouseY);
      println("x1 = " + x1 + ", x2 = " + x2 + ", y1 = " + y1 + ", y2 = " + y2);
      boolean r1 = mouseX > x1;
      boolean r3 = mouseY > y1;
      boolean r2 = mouseX < x2;
      boolean r4 = mouseY < y2;
      hit = r1 && r2 && r2 && r3 && r4;
      return hit;
    }
    
    boolean mouseIsInHitbox() {
      return mouseIsInHitbox(0,0);
    }
  }
  
  Hitbox hitboxTopLeft;
  Hitbox hitboxTopRight;
  Hitbox hitboxBottomLeft;
  Hitbox hitboxBottomRight;
  
  final int MOUSE_CLICKED_NOTHING = -1;

  final int MOUSE_CLICKED_BORDER_LEFT = 1;
  final int MOUSE_CLICKED_BORDER_RIGHT = 2;
  final int MOUSE_CLICKED_BORDER_TOP = 3;
  final int MOUSE_CLICKED_BORDER_BOTTOM = 4;
  
  final int MOUSE_CLICKED_RESIZE_LEFT = 1;
  final int MOUSE_CLICKED_RESIZE_RIGHT = 2;
  final int MOUSE_CLICKED_RESIZE_TOP = 3;
  final int MOUSE_CLICKED_RESIZE_BOTTOM = 4;
  final int MOUSE_CLICKED_RESIZE_TOP_LEFT = 5;
  final int MOUSE_CLICKED_RESIZE_TOP_RIGHT = 6;
  final int MOUSE_CLICKED_RESIZE_BOTTOM_LEFT = 7;
  final int MOUSE_CLICKED_RESIZE_BOTTOM_RIGHT = 8;
  
  int clickedBorderType = MOUSE_CLICKED_NOTHING;
  int clickedResizeType = MOUSE_CLICKED_NOTHING;
  
  void getClickedBorderType() {
    clickedBorderType = MOUSE_CLICKED_NOTHING;

    if (mouseIsInWindow() && !mouseIsInApp()) {
      if (mouseX <= x+borderLeft) {
        clickedBorderType = MOUSE_CLICKED_BORDER_LEFT;
      } else if (mouseX >= (width+x)-borderRight-1) {
        clickedBorderType = MOUSE_CLICKED_BORDER_RIGHT;
      } else if (mouseY <= y+borderTop) {
        clickedBorderType = MOUSE_CLICKED_BORDER_TOP;
      } else if (mouseY >= (height+y)-borderBottom-2) {
        clickedBorderType = MOUSE_CLICKED_BORDER_BOTTOM;
      }
    }
  }
  
  boolean mouseIsInBorder() {
    getClickedBorderType();
    return clickedBorderType != MOUSE_CLICKED_NOTHING;
  }

  void getClickedResizeType() {
    clickedResizeType = MOUSE_CLICKED_NOTHING;
    
    if (!resizable) return;
        
    if (mouseIsInWindow() && !mouseIsInApp()) {
      if (hitboxTopLeft.mouseIsInHitbox(x, y)) {
        clickedResizeType = MOUSE_CLICKED_RESIZE_TOP_LEFT;
      } else if (hitboxBottomLeft.mouseIsInHitbox(x, y)) {
        clickedResizeType = MOUSE_CLICKED_RESIZE_BOTTOM_LEFT;
      } else if (mouseX <= x+resizeLeft) {
        clickedResizeType = MOUSE_CLICKED_RESIZE_LEFT;
      } else if (hitboxTopRight.mouseIsInHitbox(x, y)) {
        clickedResizeType = MOUSE_CLICKED_RESIZE_TOP_RIGHT;
      } else if (hitboxBottomRight.mouseIsInHitbox(x, y)) {
        clickedResizeType = MOUSE_CLICKED_RESIZE_BOTTOM_RIGHT;
      } else if (mouseX >= (width+x)-resizeRight-1) {
        clickedResizeType = MOUSE_CLICKED_RESIZE_RIGHT;
      } else if (mouseY <= y+resizeTop) {
        clickedResizeType = MOUSE_CLICKED_RESIZE_TOP;
      } else if (mouseY >= (height+y)-resizeBottom-2) {
        clickedResizeType = MOUSE_CLICKED_RESIZE_BOTTOM;
      }
    }
  }
  
  boolean mouseIsInResizeBorder() {
    getClickedResizeType();
    if (clickedResizeType == MOUSE_CLICKED_NOTHING) return false;
    return true;
  }

  void clearScreen() {
    graphics.beginDraw();
    graphics.background(0);
    graphics.endDraw();
  }
  
  boolean resizingTopLeft = false;
  boolean resizingTopRight = false;
  boolean resizingBottomLeft = false;
  boolean resizingBottomRight = false;
        //  if (resizingTopLeft) hitboxTopLeft.drawHitboxHit();
        //else hitboxTopLeft.drawHitboxMaybeHit();

  void drawBordersWithFill(int fill__) {
    graphics.beginDraw();
    graphics.rectMode(CORNER);
    graphics.stroke(0);
    graphics.fill(fill__);
    graphics.rect(0, 0, width, height, 10);
    graphics.endDraw();
    int cr = 50;
    RectangleCorners rc = new RectangleCorners(0, 0, width, height);
    hitboxTopLeft = new Hitbox(rc.topLeftX,rc.topLeftY,cr,debug);
    hitboxTopRight = new Hitbox(rc.topRightX,rc.topRightY,cr,debug);
    hitboxBottomLeft = new Hitbox(rc.bottomLeftX,rc.bottomLeftY,cr,debug);
    hitboxBottomRight = new Hitbox(rc.bottomRightX,rc.bottomRightY,cr,debug);

    if (!resizing) {
      if (mouseIsInWindow() && !mouseIsInApp()) {
        if (hitboxTopLeft.mouseIsInHitbox(x,y)) {
          hitboxTopLeft.drawHitboxMaybeHit();
          hitboxTopRight.drawHitboxUnhit();
          hitboxBottomLeft.drawHitboxUnhit();
          hitboxBottomRight.drawHitboxUnhit();
        } else if (hitboxTopRight.mouseIsInHitbox(x,y)) {
          hitboxTopLeft.drawHitboxUnhit();
          hitboxTopRight.drawHitboxMaybeHit();
          hitboxBottomLeft.drawHitboxUnhit();
          hitboxBottomRight.drawHitboxUnhit();
        } else if (hitboxBottomLeft.mouseIsInHitbox(x,y)) {
          hitboxTopLeft.drawHitboxUnhit();
          hitboxTopRight.drawHitboxUnhit();
          hitboxBottomLeft.drawHitboxMaybeHit();
          hitboxBottomRight.drawHitboxUnhit();
        } else if (hitboxBottomRight.mouseIsInHitbox(x,y)) {
          hitboxTopLeft.drawHitboxUnhit();
          hitboxTopRight.drawHitboxUnhit();
          hitboxBottomLeft.drawHitboxUnhit();
          hitboxBottomRight.drawHitboxMaybeHit();
        } else {
          hitboxTopLeft.drawHitboxUnhit();
          hitboxTopRight.drawHitboxUnhit();
          hitboxBottomLeft.drawHitboxUnhit();
          hitboxBottomRight.drawHitboxUnhit();
        }
      } else {
        hitboxTopLeft.drawHitboxUnhit();
        hitboxTopRight.drawHitboxUnhit();
        hitboxBottomLeft.drawHitboxUnhit();
        hitboxBottomRight.drawHitboxUnhit();
      }
    } else {
        if (resizingTopLeft) hitboxTopLeft.drawHitboxHit();
        else hitboxTopLeft.drawHitboxUnhit();
        if (resizingTopRight) hitboxTopRight.drawHitboxHit();
        else hitboxTopRight.drawHitboxUnhit();
        if (resizingBottomLeft) hitboxBottomLeft.drawHitboxHit();
        else hitboxBottomLeft.drawHitboxUnhit();
        if (resizingBottomRight) hitboxBottomRight.drawHitboxHit();
        else hitboxBottomRight.drawHitboxUnhit();
    }
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
  
  void resizeWindow() {
    String type = window.onRequestType();
    window.onBeforeResize();
    window.graphics = createGraphics(window.width, window.height, type);
    window.onAfterResize();
  }

  void setup() {
    correctMouseLocation();
    resizeWindow();
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
  
  final int MOUSE_DRAGGED_NONE = -1;
  final int MOUSE_DRAGGED_LEFT = 1;
  final int MOUSE_DRAGGED_RIGHT = 2;
  final int MOUSE_DRAGGED_UP = 3;
  final int MOUSE_DRAGGED_DOWN = 4;
  
  int getMouseDragDirection() {
    if (mouseX > pmouseX) return MOUSE_DRAGGED_RIGHT;
    if (mouseX < pmouseX) return MOUSE_DRAGGED_LEFT;
    if (mouseY > pmouseY) return MOUSE_DRAGGED_DOWN;
    if (mouseY < pmouseY) return MOUSE_DRAGGED_UP;
    return MOUSE_DRAGGED_NONE;
  }

  int originalWidth;
  int originalHeight;
  
  int resizeType;

  void mousePressed() {
    if (mouseIsInResizeBorder()) {
      resizingTopLeft = false;
      resizingTopRight = false;
      resizingBottomLeft = false;
      resizingBottomRight = false;
      clickedOnResizeBorder = true;
      resizing = true;
      widthOffset = mouseX-width;
      heightOffset = mouseY-height;
      originalWidth = width;
      originalHeight = height;
      mouseDragType = MOUSE_CLICKED_NOTHING;
      println("clickedResizeType = " + clickedResizeType);
      if (
        clickedResizeType == MOUSE_CLICKED_RESIZE_TOP ||
        clickedResizeType == MOUSE_CLICKED_RESIZE_LEFT ||
        clickedResizeType == MOUSE_CLICKED_RESIZE_TOP_LEFT ||
        clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM_LEFT
      ) {
        if (clickedResizeType == MOUSE_CLICKED_RESIZE_TOP_LEFT) {
          resizingTopLeft = true;
          xOffset = mouseX-x;
          yOffset = mouseY-y;
        } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_TOP_RIGHT) {
          resizingTopRight = true;
        } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM_LEFT) {
          resizingBottomLeft = true;
          xOffset = mouseX-x;
          yOffset = mouseY-y;
        } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM_RIGHT) {
          resizingBottomRight = true;
        }
      }
    } else if (mouseIsInBorder()) {
      clickedOnBorder = true;
      locked = true;
      mouseDragType = MOUSE_CLICKED_NOTHING;
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
  
  int mouseDragType = MOUSE_CLICKED_NOTHING;
    
  void mouseDragged() {
    if(clickedOnResizeBorder && resizing) {
      int previewWidth_ = 0;
      int previewHeight_ = 0;
      mouseDragType = getMouseDragDirection();
      if (
        clickedResizeType == MOUSE_CLICKED_RESIZE_TOP ||
        clickedResizeType == MOUSE_CLICKED_RESIZE_LEFT
      ) {
        // subtract
        if (clickedResizeType == MOUSE_CLICKED_RESIZE_LEFT) {
          previewWidth_ = originalWidth - ((mouseX-widthOffset) - originalWidth);
          if (previewWidth_ > minimumWidth) x = mouseX-xOffset;
          if (previewWidth_ <= minimumWidth) previewWidth = minimumWidth;
          else previewWidth = previewWidth_;
        } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_TOP) {
          previewHeight_ = originalHeight - ((mouseY-heightOffset) - originalHeight);
          if (previewHeight_ > minimumHeight) y = mouseY-yOffset;
          if (previewHeight_ <= minimumHeight) previewHeight = minimumHeight;
          else previewHeight = previewHeight_;
        }
      } else if (
        clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM ||
        clickedResizeType == MOUSE_CLICKED_RESIZE_RIGHT
      ) {
        // add
        if (clickedResizeType == MOUSE_CLICKED_RESIZE_RIGHT) {
          previewWidth_ = originalWidth + ((mouseX-widthOffset) - originalWidth);
          if (previewWidth_ <= minimumWidth) previewWidth = minimumWidth;
          else previewWidth = previewWidth_;
        } else if (resizeType == MOUSE_CLICKED_RESIZE_BOTTOM) {
          previewHeight_ = originalHeight + ((mouseY-heightOffset) - originalHeight);
          if (previewHeight_ <= minimumHeight) previewHeight = minimumHeight;
          else previewHeight = previewHeight_;
        }
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_TOP_LEFT) {
        resizingTopLeft = true;
        x = mouseX-xOffset;
        y = mouseY-yOffset;
        previewWidth_ = originalWidth - ((mouseX-widthOffset) - originalWidth);
        if (previewWidth_ > minimumWidth) x = mouseX-xOffset;
        if (previewWidth_ <= minimumWidth) previewWidth = minimumWidth;
        else previewWidth = previewWidth_;
        previewHeight_ = originalHeight - ((mouseY-heightOffset) - originalHeight);
        if (previewHeight_ > minimumHeight) y = mouseY-yOffset;
        if (previewHeight_ <= minimumHeight) previewHeight = minimumHeight;
        else previewHeight = previewHeight_;
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_TOP_RIGHT) {
        resizingTopRight = true;
        previewWidth_ = originalWidth + ((mouseX-widthOffset) - originalWidth);
        if (previewWidth_ <= minimumWidth) previewWidth = minimumWidth;
        else previewWidth = previewWidth_;
        previewHeight_ = originalHeight - ((mouseY-heightOffset) - originalHeight);
        if (previewHeight_ > minimumHeight) y = mouseY-yOffset;
        if (previewHeight_ <= minimumHeight) previewHeight = minimumHeight;
        else previewHeight = previewHeight_;
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM_LEFT) {
        resizingBottomLeft = true;
        previewWidth_ = originalWidth - ((mouseX-widthOffset) - originalWidth);
        if (previewWidth_ > minimumWidth) x = mouseX-xOffset;
        if (previewWidth_ <= minimumWidth) previewWidth = minimumWidth;
        else previewWidth = previewWidth_;
        previewHeight_ = originalHeight + ((mouseY-heightOffset) - originalHeight);
        if (previewHeight_ <= minimumHeight) previewHeight = minimumHeight;
        else previewHeight = previewHeight_;
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM_RIGHT) {
        resizingBottomRight = true;
        previewWidth_ = originalWidth + ((mouseX-widthOffset) - originalWidth);
        if (previewWidth_ <= minimumWidth) previewWidth = minimumWidth;
        else previewWidth = previewWidth_;
        previewHeight_ = originalHeight + ((mouseY-heightOffset) - originalHeight);
        if (previewHeight_ <= minimumHeight) previewHeight = minimumHeight;
        else previewHeight = previewHeight_;
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
      if (mouseDragType != MOUSE_CLICKED_NOTHING) {
        if (
          clickedResizeType == MOUSE_CLICKED_RESIZE_LEFT ||
          clickedResizeType == MOUSE_CLICKED_RESIZE_RIGHT
        ) {
          width = previewWidth;
          window.width = width-borderLeft-borderRight-2;
        } else if (
          clickedResizeType == MOUSE_CLICKED_RESIZE_TOP ||
          clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM
        ) {
          height = previewHeight;
          window.height = height-borderTop-borderBottom-2;
        } else if (
          clickedResizeType == MOUSE_CLICKED_RESIZE_TOP_LEFT ||
          clickedResizeType == MOUSE_CLICKED_RESIZE_TOP_RIGHT ||
          clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM_LEFT ||
          clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM_RIGHT
        ) {
          resizingTopLeft = false;
          resizingTopRight = false;
          resizingBottomLeft = false;
          resizingBottomRight = false;
          width = previewWidth;
          window.width = width-borderLeft-borderRight-2;
          height = previewHeight;
          window.height = height-borderTop-borderBottom-2;
        }
        resizeWindow();
        graphics = createGraphics(width, height, P3D);
        clickedResizeType = MOUSE_CLICKED_NOTHING;
      }
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
