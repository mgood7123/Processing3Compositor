// TODO: rename to Window manager and split to WindowManager and Compositor
// for now, assume that the compositor draws what the window manager renders
// however this may be incorrect, so avoid doing this for the time being
// untill more information is available on the difference between a
// compositor and a window manager

// from https://github.com/mgood7123/AndroidCompositor/blob/5232f327e22df10368c780287822bc2320b22f06/app/src/main/jni/compositor.cpp#L17
// my current understanding of all this is that a compositor will render each
// application's frame buffer, and a window manager such as KDE or GNOME or I3,
// will work WITH the compositor retrieving information about windows and their
// position, then draw boarders around those windows and implement either stacking
// or tiling like functionality depending on the windowing system type and assumably
// send information back to the compositor such as updates on window changes.

// for example if the window is minimized or its position changes, the compositor
// will then redraw itself as it sees fit according to the received information

// end from https://github.com/mgood7123/AndroidCompositor/blob/5232f327e22df10368c780287822bc2320b22f06/app/src/main/jni/compositor.cpp#L17

// TODO: optimize focus algorithm

class Compositor {
  public PGraphics graphics;
  ArrayList<WindowObject> windows = new ArrayList<WindowObject>();
  WindowObject w;
  int windowFocus = -1;
  int lastWindowFocus = -1;
  boolean wantsToReorder = false;
  boolean canReorder = false;
  boolean reorderComplete = false;
  
  Compositor(int width, int height) {
    graphics = createGraphics(width, height, P3D);
  }
  
  void add(Window window, int width, int height) {
    w = new WindowObject(width, height);
    windows.add(w);
    w.attach(window);
  }
  
  void setLocation(int x, int y) {
    w.x = x;
    w.y = y;
  }
  
  void reorder_array() {
    // re order the array based on last item clicked
    ArrayList<WindowObject> focusableWindows = new ArrayList<WindowObject>();
    boolean found = false;
    for (WindowObject window: windows) {
      if (window.focusable) {
        window.focusable = false;
        found = true;
        focusableWindows.add(window);
      }
    }
    if (found) {
      // we have a list of focusable windows, and we know windows are drawn
      // from first to last
      // how would we determine what window needs to set to be focused
      // so we can then move it to the end of the array...
      
      // locate the top most window
      int topMostIndex = 0;
      
      // assume last index is top most
      topMostIndex = focusableWindows.size()-1;

      WindowObject target = focusableWindows.get(topMostIndex);

      windows.remove(windows.indexOf(target));
      windows.add(target);
      windowFocus = windows.size()-1;
    } else windowFocus = -1;
  }

  void setup() {
    graphics.beginDraw();
    for (WindowObject window: windows) {
      window.setup();
      graphics.image(window.graphics, window.x, window.y); //<>//
    }
    graphics.endDraw();
    image(graphics, 0, 0);
  }
  
  void draw() {
    graphics.beginDraw();
    graphics.background(0);
    for (WindowObject window: windows) {
      window.draw();
      graphics.image(window.graphics, window.x, window.y);
    }
    graphics.endDraw();
    image(graphics, 0, 0);
  }
  
  void mousePressed() {
    for (WindowObject window: windows) window.canFocus();
    if (lastWindowFocus != -1) {
      WindowObject win = windows.get(lastWindowFocus);
      win.focus = false;
    }
    reorder_array();
    if (windowFocus != -1) {
      lastWindowFocus = windowFocus;
      WindowObject win = windows.get(windowFocus);
      win.focus = true;
      win.mousePressed();
      graphics.beginDraw();
      graphics.image(win.graphics, win.x, win.y);
      graphics.endDraw();      
      image(graphics, 0, 0);
    }
  }
  
  void mouseDragged() {
    graphics.beginDraw();
    for (WindowObject window: windows) {
      window.mouseDragged();
      graphics.image(window.graphics, window.x, window.y);
    }
    graphics.endDraw();
    image(graphics, 0, 0);
  }
  
  void mouseReleased() {
    graphics.beginDraw();
    for (WindowObject window: windows) {
      window.mouseReleased();
      graphics.image(window.graphics, window.x, window.y);
    }
    graphics.endDraw();
    image(graphics, 0, 0);
  }
}
