class Applications_DraggableExample extends Window {
  float bx;
  float by;
  int boxSizeX = 20;
  int boxSizeY = 20;
  boolean overBox = false;
  boolean locked = false;
  float xOffset = 0.0;
  float yOffset = 0.0;
    
  @Override
  void setup() {
    graphics.beginDraw();
    // if this is called after a resize then
    // the user will lose the current position of the box after a resize
    bx = width/2.0;
    by = height/2.0;
    // move rectMode into draw as PGraphics recreation seems to reset rectMode
    graphics.endDraw();
  }
  
  @Override
  void draw() { 
    graphics.beginDraw();
    graphics.background(0);
    // reset rectMode here
    graphics.rectMode(RADIUS);
    
    // we risk loosing the box entirely if the user resizes the graphics object
    // to less than bx, by
    // if this happens the user will need to resize the graphics object
    // move the box to a suitible location
    // then resize the graphics object again
    
    // Test if the cursor is over the box 
    if (mouseX > bx-boxSizeX && mouseX < bx+boxSizeX && 
        mouseY > by-boxSizeY && mouseY < by+boxSizeY) {
      overBox = true;
      if(!locked) {
        graphics.stroke(255); 
        graphics.fill(153);
      } 
    } else {
      graphics.stroke(153);
      graphics.fill(153);
      overBox = false;
    }
    
    // Draw the box
    graphics.rect(bx, by, boxSizeX, boxSizeY);
    graphics.endDraw();
  }
  
  @Override
  void mousePressed() {
    if(overBox) { 
      locked = true; 
      graphics.fill(255, 255, 255);
    } else {
      locked = false;
    }
    xOffset = mouseX-bx; 
    yOffset = mouseY-by; 
  
  }
  
  @Override
  void mouseDragged() {
    if(locked) {
      bx = mouseX-xOffset;
      by = mouseY-yOffset; 
    }
  }
  
  @Override
  void mouseReleased() {
    locked = false;
  }
}
