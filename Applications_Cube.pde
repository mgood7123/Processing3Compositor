class Applications_Cube extends Window {
  
  @Override
  void draw() {
    graphics.lights();
    graphics.background(0);
    graphics.noStroke();
    graphics.translate(width/2, height/2);
    graphics.rotateX(frameCount/100.0);
    graphics.rotateY(frameCount/200.0);
    graphics.box(40);
  }
}
