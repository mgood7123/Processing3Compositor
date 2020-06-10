class CursorTools {
  
  XCursorDecoder x = new XCursorDecoder();
  XCursorDecoder.CursorData currentCursorData = null;

  void loadCursor(String cursor) {
    XCursorDecoder.CursorData data = x.loadAndDecode(cursor);
    if (data != null) {
      currentCursorData = data;
      cursor(data.image, data.xhot, data.yhot);
    }
  }
  
  void loadCursors() {
    
  }
}
