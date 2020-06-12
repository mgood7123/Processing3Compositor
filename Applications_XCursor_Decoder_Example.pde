class Applications_XCursor_Decoder_Example extends Window {
  XCursorDecoder.CursorData cursorData = null;

  @Override
  void setup() {
    cursorData = new XCursorDecoder().loadAndDecode("cursors/aerodrop/right_ptr");
  }
  
  @Override
  void draw() {
    graphics.background(0);
    graphics.image(cursorData.image, (width/2)+cursorData.xhot, (height/2)+cursorData.yhot);
  }
}
