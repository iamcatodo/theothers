/**
 * TheOthers - random cuts
 *
 * Creative Commons License (by-nc-sa)
 *
 * (C) 2014 by Catodo
 * http://www.catodo.net
 */

import java.awt.Frame;
import controlP5.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.signals.*;
import themidibus.*;

float colR, colG, colB, sizeBar = 0, alphaImage = 0, alpha = 0, gainVolume = 0, threshold = 1.0;
boolean horizontal = true, vertical, startOn= false, firstScreen=true, clear = false;
int start_time, rateSpeed = 1, randImg;
ControlP5 cp5;
CheckBox checkbox, checkbox2;
Knob myKnobA, myKnobB;
Minim minim;
MidiBus myBus;
AudioOutput out;
Oscil[] wave = new Oscil[8];

void setup() {
  start_time = millis();
  
  size(displayWidth, displayHeight);
  background(0);
  frameRate(rateSpeed);
  strokeCap(SQUARE);
  strokeJoin(ROUND);
  registerMethod("pre", this);
  minim = new Minim(this);
  out = minim.getLineOut(Minim.STEREO);
  out.setGain(0.7);
  for(int i=0; i< 8; i++) {
    wave[i]= new Oscil(0, 0, Waves.SINE);
    wave[i].patch(out);
  }  
  MidiBus.list();
  myBus = new MidiBus(this, "LPD8", -1);
}

void pre() {
  // we only need to call pre() once, so lets remove it here 
  unregisterMethod("pre", this);
  // create a new ControlFrame, all works fine with
  // processing 2.0b3 and 2.0b5 on osx
  new ControlFrame(this, "extra", 800, 600);
}

void draw() {
   if (!startOn) { 
     if (firstScreen) {
       start_screen();
     } else {
       end_screen();
     }
     return;
   }

   if (clear) {
     background(0);
     clear = false;
   }
   if (alphaImage > 0) {
     PImage img = loadImage((int) random(20) + 1 + ".jpg");
     if (threshold > 0) {
       img.filter(THRESHOLD, threshold);
     }
     tint(255, alphaImage);
     image(img, 0, 0, width, height);
   }
   frameRate(rateSpeed);
   
   strokeWeight(frameCount % sizeBar);
   if (frameCount % 2 == 0) {
     stroke(colR, colG, colB, frameCount % alpha);
   } else {
     stroke(0, frameCount % alpha);
   }
   if (horizontal && sizeBar > 0) {
     Xcuts(random(height/2));
   }
   if (vertical && sizeBar > 0) {
     Ycuts(random(width/2));
   }
}

void Xcuts(float l) {
  float y1,y2;
      
  y1 = random(0, l);
  while (y1<height) {
    y2 = y1 + random(-l/2, l/2);
    line (-50, y1, width+50, y2);
    y1 = l + max(y1, y2);
    // audio
    wave[frameCount % 8].setFrequency(map(y2, 0, height, 0, map(rateSpeed, 1, 30, 30, 600)));
    wave[frameCount % 8].setAmplitude(map(y1, 0, height, 0, 1));
  }
}

void Ycuts(float l) {
  float x1,x2;
  x1 = random(0, l);
  while (x1 < width) {
    x2 = x1 + random(-l/2, l/2);
    line (x1, -50, x2, height+50);
    x1 = l + max(x1, x2);
    // audio
    wave[frameCount % 8].setFrequency(map(x2, 0, width, 0, map(rateSpeed, 1, 30, 30, 600)));
    wave[frameCount % 8].setAmplitude(map(x1, 0, width, 0, 1));
  }
}

void start_screen() {
  background(0);
  PImage first_screen = loadImage("first_page.jpg");
  tint(255);
  image(first_screen, 0, 0, width, height);
}

void end_screen() {
  out.mute();
  background(0);
  PImage last_screen = loadImage("last_page.jpg");
  tint(255);
  image(last_screen, 0, 0, width, height);
}

// Control Window

public class ControlFrame extends PApplet {
  Object parent;
  Accordion accordion, accordion2, accordion3;
  //Knob myKnobA, myKnobB;
  //CheckBox checkbox, checkbox2;
  
  int w, h;
  
  void keyPressed() {
    if (keyCode == 32) {
      startOn = !startOn;
      start_time = millis();
    }
    firstScreen = false;
  }

  public void setup() {
    size(w,h);
    cp5 = new ControlP5(this);
                   
    Group g1 = cp5.addGroup("Cuts")
                .setBackgroundColor(color(0,64))
                .setHeight(30)
                .setBackgroundHeight(350);
  
    int xsize = width/5;
    
    // g1
    cp5.addSlider("Red")
     .setPosition(0,5)
     .setRange(0,255)
     .setValue(colR)
     .setWidth(xsize)
     .setHeight(30)
     .setColorActive(color(255,0,0))
     .moveTo(g1)
     ;
     
    cp5.addSlider("Green")
     .setPosition(0,40)
     .setRange(0,255)
     .setValue(colG)
     .setWidth(xsize)
     .setHeight(30)
     .setColorActive(color(0,255,0))
     .moveTo(g1)
     ;   
 
    cp5.addSlider("Blue")
     .setPosition(0,75)
     .setRange(0,255)
     .setValue(colB)
     .setWidth(xsize)
     .setHeight(30)
     .setColorActive(color(0,0,255))
     .moveTo(g1)
     ;   
  
    cp5.addSlider("Alpha")
       .setPosition(0,110)
       .setRange(0,255)
       .setValue(alpha)
       .setWidth(xsize)
       .setHeight(30)
       .setColorActive(color(100,100,100))
       .moveTo(g1)
     ;   
 
    myKnobA = cp5.addKnob("Size")
               .setRange(0,height/2)
               .setValue(0)
               .setPosition(35,165)
               .setRadius(45)
               .setDragDirection(Knob.VERTICAL)
               .setColorBackground(color(colR, colG, colB))
               .moveTo(g1)
               ; 
    
    checkbox = cp5.addCheckBox("checkBox")
                .setPosition(5, 285)
                .setColorForeground(color(120))
                .setColorActive(color(255))
                .setColorLabel(color(255))
                .setSize(50, 30)
                .setItemsPerRow(2)
                .setSpacingColumn(40)
                .addItem("H", 1)
                .addItem("V", 0)
                .moveTo(g1)
                ;
     
    accordion = cp5.addAccordion("acc")
                 .setPosition(width-xsize-60,20)
                 .setWidth(xsize)
                 .setHeight(50)
                 .addItem(g1);
                 
 
    
    accordion.open(0,1,2);
    accordion.setCollapseMode(Accordion.MULTI);
 
    // g2
    Group g2 = cp5.addGroup("Images")
                  .setBackgroundColor(color(0,50))
                  .setHeight(30)
                  .setBackgroundHeight(180);
    
    cp5.addSlider("AlphaImage")
     .setPosition(0,5)
     .setRange(0,255)
     .setValue(0)
     .setWidth(xsize)
     .setHeight(30)
     .setColorActive(color(100,100,100))
     .moveTo(g2)
     ;
     
    cp5.addSlider("FrameRate")
     .setPosition(0,40)
     .setRange(1,30)
     .setValue(1)
     .setWidth(xsize)
     .setHeight(30)
     .setColorActive(color(100,100,100))
     .moveTo(g2)
     ;   
     
    cp5.addSlider("Threshold")
     .setPosition(0,80)
     .setRange(0,1)
     .setValue(1.0)
     .setWidth(xsize)
     .setHeight(30)
     .setColorActive(color(100,100,100))
     .moveTo(g2)
     ;
                
    cp5.addButton("ClearScreen")
     .setValue(1)
     .setPosition(25,140)
     .setSize(2*xsize/3,30)
     .moveTo(g2)
     ;
                
    accordion2 = cp5.addAccordion("acc2")
                    .setPosition(width-xsize-300,20)
                    .setWidth(xsize)
                    .setHeight(50)
                    .addItem(g2);

    accordion2.open(0,1,2);
    accordion2.setCollapseMode(Accordion.MULTI);
  }
 
  public void draw() {
    background(100);
    textSize(32);
    text("Random Cuts", 20, 50); 
    textSize(16);
    text("by Catodo", 22,70);
    int second = (millis()-start_time)/1000;
    int minute = second/60;
    text("Elapsed time: " + minute % 60 + ":" + second % 60, 22, 200);
  }

  
  private ControlFrame() {
  }
      
  public void Red(float col) {
    colR = col;
    //myKnobA.setColorBackground(color(colR, colG, colB));
  }
  
  public void Green(float col) {
    colG = col;
    //myKnobA.setColorBackground(color(colR, colG, colB));
  }

  public void Blue(float col) {
    colB = col;
    //myKnobA.setColorBackground(color(colR, colG, colB));
  }
  
  public void Alpha(float col) {
    alpha = col;
  }
  
  public void FrameRate(float r) {
    rateSpeed = (int) r;
  }
  
  public void AlphaImage(int a) {
    alphaImage = a;
  }
  
  public void Threshold(float t) {
    threshold = t;
  }
  
  public void Size(float s) {
    sizeBar = s;
  }
  
  public void checkBox(float[] a) {
    horizontal = (a[0] == 1);
    vertical = (a[1] == 1);
  }
  
  public void ClearScreen(int value) {
    clear = true;
  }
  
  public ControlFrame(Object theParent, String theName, int theWidth, int theHeight) {
        parent = theParent;
        w = theWidth;
        h = theHeight;
        Frame f = new Frame(theName);
        f.add(this);
        this.init();
        f.setTitle(theName);
        f.setSize(w, h);
        f.setLocation(100, 100);
        f.setResizable(false);
        f.setVisible(true);
  }
}

void stop()
{
  out.close();
  minim.stop();
  super.stop();
}

void noteOn(int channel, int pad, int velocity) {
  switch (pad) {
    case 36:
      horizontal = !horizontal;
      checkbox.getItem(0).setValue(horizontal);
      break;
    case 37:
      vertical = !vertical;
      checkbox.getItem(1).setValue(vertical);
      break;  
    case 39:
      clear = true;
      cp5.getController("ClearScreen").setValue(1);
      break;  
  }
}


void controllerChange(int channel, int number, int value) {
  switch (number) {
    case 1:
      cp5.getController("Red").setValue(map(value, 0, 127, 0, 255));
      break;
    case 2:
      cp5.getController("Green").setValue(map(value, 0, 127, 0, 255));
      break;
    case 3:
      cp5.getController("Blue").setValue(map(value, 0, 127, 0, 255));
      break;
    case 4:
      cp5.getController("Alpha").setValue(map(value, 0, 127, 0, 255));
      break;  
    case 5:
      cp5.getController("Size").setValue(map(value, 0, 127, 0, height/2));
      break;
    case 6:
      cp5.getController("AlphaImage").setValue(map(value, 0, 127, 0, 255));
      break;  
    case 7:
      cp5.getController("FrameRate").setValue(map(value, 0, 127, 1, 30));
      break;
    case 8:
      cp5.getController("Threshold").setValue(map(value, 0, 127, 0, 1));
      break;  
  }
}
