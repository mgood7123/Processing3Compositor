class Applications_XCursor_Decoder_Example extends Window {
  PImage image = null;

  @Override
  void setup() {
    XCursorDecoder XCD = new XCursorDecoder();
    XCD.load("cursors/aerodrop/right_ptr");
    image = XCD.decode();
  }
  
  @Override
  void draw() {
    graphics.beginDraw();
    graphics.background(0);
    graphics.image(image, width/2, height/2);
    graphics.endDraw();
  }
}
