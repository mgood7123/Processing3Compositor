class Cube extends Window {

  @Override
  void onResize() {
    graphics = createGraphics(width, height, P3D);
  }
  
  @Override
  void draw() {
    graphics.beginDraw();
    graphics.lights();
    graphics.background(0);
    graphics.noStroke();
    graphics.translate(width/2, height/2);
    graphics.rotateX(frameCount/100.0);
    graphics.rotateY(frameCount/200.0);
    graphics.box(40);
    graphics.endDraw();
  }
}
