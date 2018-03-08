Game game;
boolean showHelp = true;
int cw,ch;
void setup(){
  frameRate(30);
  size(800, 640);
  cw = width;ch=height;
   surface.setResizable(true);
  game = new Game(this);
  registerMethod ("pre", this ) ;
}

void pre() {
  if (cw != width || ch != height) {
    game.stop();
    game.turtle.setInitPos(width/2,height/2);
    game.turtle.goBackToInit();
    
    cw = width;ch=height;
  }
}

void draw(){
  game.draw();
  if(showHelp){
    drawHelp();
  }
}

void drawHelp(){
  fill(255,255,255,255);
  int ts = 20;
  textSize(ts);
  text("press :\n- up arrow to advance\n- left/right to rotate\n- space to play\n- r to reset turtle position\n- c to clear instructions\n- h to show/hide this help\n- s / l / f to save/ load / load file",0,ts);
}
void keyPressed(){
  if(key==CODED){
    if(keyCode==UP){game.addInstruction(Instruction.FORWARD);}
   // else if(keyCode==DOWN){game.addInstruction(Instruction.BACKWARD);}
    else if(keyCode==LEFT){game.addInstruction(Instruction.ROTATE);}
    else if(keyCode==RIGHT){game.addInstruction(Instruction.NROTATE);}
  }
  else if(key == ' '){game.togglePlay();}
  else if(key == 'c'){game.clearInstructions();}
  else if(key == 'r'){game.turtle.goBackToInit();}
  else if(key == 's'){game.save();}
  else if(key == 'l'){game.load("");}
  else if (key== 'f'){
    selectInput("choisis un fichier :", "fileSelected");
  
}
  else if(key == 'h'){showHelp = !showHelp;}
  else if(key == BACKSPACE){game.removeLastInstruction();}
  else if(key-'0'>=0 && key-'0'<10){
    int speed = key-'0';
    game.timeStep = speed*200 + 1;
  }
}

void fileSelected(File p){
  String path = p.getPath();
  if(path.length()>0){
    println(path);
  game.load(path);
  }
}