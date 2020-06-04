// X11 provides an extremely basic programmatic WM
// if none is present, and the WM provides a
// user-interactable WM that effectively replaces
// and enhances X's built-in WM
// the enhanced WM calls X's built-in WM

// [22:46] <pq> smallville7123, windows have meta data.
// A *lot* of it, actually. If you real ICCCM, EWMH,
// wayland.xml and wayland-protocols XML files, you'll
// see almost everything is about something else than
// pixels themselves. there is also input, and
// inter-client activities like copy&paste

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
  int previewWidth_;
  int previewHeight_;
  int x;
  int y;
  
  boolean locked = false;
  boolean resizing = false;
  
  boolean focus = false;
  boolean focusable = false;
  boolean draggable = true;
  boolean resizable = true;

  void windowBeginMoveX(int _x) {
    xOffset = _x - x;
  }
  
  void windowBeginMoveY(int _y) {
    yOffset = _y - y;
  }
  
  void windowBeginMove(int _x, int _y) {
    windowBeginMoveX(_x);
    windowBeginMoveY(_y);
  }

  void windowMoveX(int _x) {
    x = _x - xOffset;
  }
  
  void windowMoveY(int _y) {
    y = _y - yOffset;
  }
  
  void windowMove(int _x, int _y) {
    windowMoveX(_x);
    windowMoveY(_y);
  }

  void windowBeginResize(int _x, int _y) {
    originalWidth = width;
    originalHeight = height;
    widthOffset = _x - width;
    heightOffset = _y - height;
  }
  
  void windowResizeLeft(int _x) {
    previewWidth_ = originalWidth - ((_x-widthOffset) - originalWidth);
    if (previewWidth_ > minimumWidth) {
      windowMoveX(_x);
    }
    if (previewWidth_ <= minimumWidth) previewWidth = minimumWidth;
    else previewWidth = previewWidth_;
  }
  
  void windowResizeRight(int _x) {
    previewWidth_ = originalWidth + ((_x-widthOffset) - originalWidth);
    if (previewWidth_ <= minimumWidth) previewWidth = minimumWidth;
    else previewWidth = previewWidth_;
  }
  
  void windowResizeTop(int _y) {
    previewHeight_ = originalHeight - ((_y-heightOffset) - originalHeight);
    if (previewHeight_ > minimumHeight) {
      windowMoveY(_y);
    }
    if (previewHeight_ <= minimumHeight) previewHeight = minimumHeight;
    else previewHeight = previewHeight_;
  }
  
  void windowResizeBottom(int _y) {
    previewHeight_ = originalHeight + ((_y-heightOffset) - originalHeight);
    if (previewHeight_ <= minimumHeight) previewHeight = minimumHeight;
    else previewHeight = previewHeight_;
  }

  void windowResize(int _width, int _height) {
    width = _width;
    window.width = width-borderLeft-borderRight;
    height = _height;
    window.height = height-borderTop-borderBottom;
  }
  
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

  int resizeTop = 6;
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
    
    this.window.x = borderLeft;
    this.window.width = width-borderLeft-borderRight;

    this.window.y = borderTop;
    this.window.height = height-borderTop-borderBottom;
  }
  
  void correctMouseLocation() {
    window.mouseX = mouseX-x-window.x;
    window.mouseY = mouseY-y-window.y;
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
    Hitbox(int x, int y, int size, boolean debug_) {
      debug = debug_;
      int s = size/2;
      this.size = s;
      int x1 = x-s;
      int y1 = y-s;
      int x2 = x+s;
      int y2 = y+s;
      hitbox = new RectangleCorners(x1, y1, x2, y2);
    }
    
    boolean mouseIsInHitbox(int offsetX, int offsetY) {
      int x1 = hitbox.topLeftX+offsetX;
      int y1 = hitbox.topLeftY+offsetY;
      int x2 = hitbox.bottomRightX+offsetX;
      int y2 = hitbox.bottomRightY+offsetY;
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
      } else if (mouseX >= (width+x)-borderRight) {
        clickedBorderType = MOUSE_CLICKED_BORDER_RIGHT;
      } else if (mouseY <= y+borderTop) {
        clickedBorderType = MOUSE_CLICKED_BORDER_TOP;
      } else if (mouseY >= (height+y)-borderBottom) {
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
      } else if (mouseX >= (width+x)-resizeRight) {
        clickedResizeType = MOUSE_CLICKED_RESIZE_RIGHT;
      } else if (mouseY <= y+resizeTop) {
        clickedResizeType = MOUSE_CLICKED_RESIZE_TOP;
      } else if (mouseY >= (height+y)-resizeBottom) {
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
  
  boolean resizingLeft = false;
  boolean resizingTop = false;
  boolean resizingRight = false;
  boolean resizingBottom = false;
  boolean resizingTopLeft = false;
  boolean resizingTopRight = false;
  boolean resizingBottomLeft = false;
  boolean resizingBottomRight = false;
  
  void drawResizeZoneLeft(int red, int green, int blue) {
    graphics.beginDraw();
    graphics.rectMode(CORNER);
    graphics.stroke(0);
    graphics.fill(red, green, blue);
    graphics.rect(0, 0, resizeLeft, height);
    graphics.endDraw();
  }

  void drawResizeZoneTop(int red, int green, int blue) {
    graphics.beginDraw();
    graphics.rectMode(CORNER);
    graphics.stroke(0);
    graphics.fill(red, green, blue);
    graphics.rect(0, 0, width, resizeTop);
    graphics.endDraw();
  }

  void drawResizeZoneRight(int red, int green, int blue) {
    graphics.beginDraw();
    graphics.rectMode(CORNER);
    graphics.stroke(0);
    graphics.fill(red, green, blue);
    graphics.rect(width-resizeRight, 0, resizeRight, height);
    graphics.endDraw();
  }

  void drawResizeZoneBottom(int red, int green, int blue) {
    graphics.beginDraw();
    graphics.rectMode(CORNER);
    graphics.stroke(0);
    graphics.fill(red, green, blue);
    graphics.rect(0, height-resizeBottom, width, resizeBottom);
    graphics.endDraw();
  }
  
  void drawResizeZoneLeftHit() {
    drawResizeZoneLeft(0, 255, 0);
  }

  void drawResizeZoneTopHit() {
    drawResizeZoneTop(0, 255, 0);
  }

  void drawResizeZoneRightHit() {
    drawResizeZoneRight(0, 255, 0);
  }

  void drawResizeZoneBottomHit() {
    drawResizeZoneBottom(0, 255, 0);
  }

  void drawResizeZoneLeftMaybeHit() {
    drawResizeZoneLeft(128, 128, 0);
  }

  void drawResizeZoneTopMaybeHit() {
    drawResizeZoneTop(128, 128, 0);
  }

  void drawResizeZoneRightMaybeHit() {
    drawResizeZoneRight(128, 128, 0);
  }

  void drawResizeZoneBottomMaybeHit() {
    drawResizeZoneBottom(128, 128, 0);
  }

  void drawResizeZoneLeftUnhit() {
    drawResizeZoneLeft(255, 0, 0);
  }

  void drawResizeZoneTopUnhit() {
    drawResizeZoneTop(255, 0, 0);
  }

  void drawResizeZoneRightUnhit() {
    drawResizeZoneRight(255, 0, 0);
  }

  void drawResizeZoneBottomUnhit() {
    drawResizeZoneBottom(255, 0, 0);
  }

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
    if (debug) {
      if (!resizing) {
        if (mouseIsInWindow() && !mouseIsInApp()) {
          if (mouseX <= x+resizeLeft) {
            // cursor can be in top left or bottom left
            if (hitboxTopLeft.mouseIsInHitbox(x,y)) {
              hitboxTopLeft.drawHitboxMaybeHit();
              hitboxBottomLeft.drawHitboxUnhit();
            } else {
              hitboxTopLeft.drawHitboxUnhit();
              if (hitboxBottomLeft.mouseIsInHitbox(x,y)) hitboxBottomLeft.drawHitboxMaybeHit();
              else {
                hitboxBottomLeft.drawHitboxUnhit();
                drawResizeZoneLeftMaybeHit();
              }
            }
          } else {
            hitboxTopLeft.drawHitboxUnhit();
            hitboxBottomLeft.drawHitboxUnhit();
            drawResizeZoneLeftUnhit();
          }

          if (mouseY <= y+resizeTop) {
            // cursor can be in top left or top right
            if (hitboxTopLeft.mouseIsInHitbox(x,y)) {
              hitboxTopLeft.drawHitboxMaybeHit();
              hitboxTopRight.drawHitboxUnhit();
            } else {
              hitboxTopLeft.drawHitboxUnhit();
              if (hitboxTopRight.mouseIsInHitbox(x,y)) hitboxTopRight.drawHitboxMaybeHit();
              else {
                hitboxTopRight.drawHitboxUnhit();
                drawResizeZoneTopMaybeHit();
              }
            }
          } else {
            hitboxTopLeft.drawHitboxUnhit();
            hitboxTopRight.drawHitboxUnhit();
            drawResizeZoneTopUnhit();
          }
          
          if (mouseX >= (width+x)-resizeRight) {
            // cursor can be in top right or bottom right
            if (hitboxTopRight.mouseIsInHitbox(x,y)) {
              hitboxTopRight.drawHitboxMaybeHit();
              hitboxBottomRight.drawHitboxUnhit();
            } else {
              hitboxTopRight.drawHitboxUnhit();
              if (hitboxBottomRight.mouseIsInHitbox(x,y)) hitboxBottomRight.drawHitboxMaybeHit();
              else {
                hitboxBottomRight.drawHitboxUnhit();
                drawResizeZoneRightMaybeHit();
              }
            }
          } else {
            hitboxTopRight.drawHitboxUnhit();
            hitboxBottomRight.drawHitboxUnhit();
            drawResizeZoneRightUnhit();
          }
          
          if (mouseY >= (height+y)-resizeBottom) {
            // cursor can be in bottom left or bottom right
            if (hitboxBottomLeft.mouseIsInHitbox(x,y)) {
              hitboxBottomLeft.drawHitboxMaybeHit();
              hitboxBottomRight.drawHitboxUnhit();
            } else {
              hitboxBottomLeft.drawHitboxUnhit();
              if (hitboxBottomRight.mouseIsInHitbox(x,y)) hitboxBottomRight.drawHitboxMaybeHit();
              else {
                hitboxBottomRight.drawHitboxUnhit();
                drawResizeZoneBottomMaybeHit();
              }
            }
          } else {
            hitboxBottomLeft.drawHitboxUnhit();
            hitboxBottomRight.drawHitboxUnhit();
            drawResizeZoneBottomUnhit();
          }
        } else {
          drawResizeZoneLeftUnhit();
          drawResizeZoneTopUnhit();
          drawResizeZoneRightUnhit();
          drawResizeZoneBottomUnhit();
          
          hitboxTopLeft.drawHitboxUnhit();
          hitboxTopRight.drawHitboxUnhit();
          hitboxBottomLeft.drawHitboxUnhit();
          hitboxBottomRight.drawHitboxUnhit();
        }
      } else {
          if (resizingLeft) drawResizeZoneLeftHit();
          else drawResizeZoneLeftUnhit();
          if (resizingTop) drawResizeZoneTopHit();
          else drawResizeZoneTopUnhit();
          if (resizingRight) drawResizeZoneRightHit();
          else drawResizeZoneRightUnhit();
          if (resizingBottom) drawResizeZoneBottomHit();
          else drawResizeZoneBottomUnhit();
          
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
    if (displayFPS) {
      window.graphics.beginDraw();
      int oldColor = window.graphics.fillColor;
      window.graphics.fill(255);
      window.graphics.textSize(16);
      window.graphics.text("FPS: " + frameRate, 10, 20);
      window.graphics.fill(oldColor);
      window.graphics.endDraw();
    }
    graphics.beginDraw();
    graphics.image(
      window.graphics,
      window.x,
      window.y,
      window.width,
      window.height
    );
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
      resizingLeft = false;
      resizingTop = false;
      resizingRight = false;
      resizingBottom = false;
      resizingTopLeft = false;
      resizingTopRight = false;
      resizingBottomLeft = false;
      resizingBottomRight = false;
      clickedOnResizeBorder = true;
      resizing = true;
      windowBeginResize(mouseX, mouseY);
      mouseDragType = MOUSE_CLICKED_NOTHING;
      println("clickedResizeType = " + clickedResizeType);
      if (clickedResizeType == MOUSE_CLICKED_RESIZE_TOP) {
        resizingTop = true;
        // window can only be moved vertically
        windowBeginMoveY(mouseY);
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_LEFT) {
        resizingLeft = true;
        // window can be moved horizontally
        windowBeginMoveX(mouseX);
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_RIGHT) {
        resizingRight = true;
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM) {
        resizingBottom = true;
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_TOP_LEFT) {
        resizingTopLeft = true;
        // window can be moved vertically or horizontally
        windowBeginMove(mouseX, mouseY);
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_TOP_RIGHT) {
        resizingTopRight = true;
        // window can only be moved vertically
        windowBeginMoveY(mouseY);
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM_LEFT) {
        resizingBottomLeft = true;
        // window can only be moved horizontally
        windowBeginMoveX(mouseX);
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM_RIGHT) {
        resizingBottomRight = true;
      }
    } else if (mouseIsInBorder()) {
      clickedOnBorder = true;
      locked = true;
      mouseDragType = MOUSE_CLICKED_NOTHING;
      if (draggable) windowBeginMove(mouseX, mouseY);
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
      mouseDragType = getMouseDragDirection();
      if (clickedResizeType == MOUSE_CLICKED_RESIZE_LEFT) {
        windowResizeLeft(mouseX);
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_RIGHT) {
        windowResizeRight(mouseX);
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_TOP) {
        windowResizeTop(mouseY);
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM) {
        windowResizeBottom(mouseY);
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_TOP_LEFT) {
        resizingTopLeft = true;
        windowResizeLeft(mouseX);
        windowResizeTop(mouseY);
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_TOP_RIGHT) {
        resizingTopRight = true;
        windowResizeRight(mouseX);
        windowResizeTop(mouseY);
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM_LEFT) {
        resizingBottomLeft = true;
        windowResizeLeft(mouseX);
        windowResizeBottom(mouseY);
      } else if (clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM_RIGHT) {
        resizingBottomRight = true;
        windowResizeRight(mouseX);
        windowResizeBottom(mouseY);
      }
    } else if(clickedOnBorder && locked && draggable) {
      windowMove(mouseX, mouseY);
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
          windowResize(previewWidth, height);
        } else if (
          clickedResizeType == MOUSE_CLICKED_RESIZE_TOP ||
          clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM
        ) {
          windowResize(width, previewHeight);
        } else if (
          clickedResizeType == MOUSE_CLICKED_RESIZE_TOP_LEFT ||
          clickedResizeType == MOUSE_CLICKED_RESIZE_TOP_RIGHT ||
          clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM_LEFT ||
          clickedResizeType == MOUSE_CLICKED_RESIZE_BOTTOM_RIGHT
        ) {
          windowResize(previewWidth, previewHeight);
        }
        resizeWindow();
        graphics = createGraphics(width, height, P3D);
      }
      clickedOnResizeBorder = false;
      resizing = false;
      resizingLeft = false;
      resizingTop = false;
      resizingRight = false;
      resizingBottom = false;
      resizingTopLeft = false;
      resizingTopRight = false;
      resizingBottomLeft = false;
      resizingBottomRight = false;
      clickedResizeType = MOUSE_CLICKED_NOTHING;
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
