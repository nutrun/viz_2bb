// Downsample to 800x600 resolution
// ffmpeg -i ~/Desktop/videos/2bb.mp4 -vf scale=800:600 ~/Desktop/videos/2bb_800.mp4

// remove sound from movie
// ffmpeg -i example.mp4 -c copy -an example-nosound.mp4

import themidibus.*;
import javax.sound.midi.MidiMessage;
import processing.video.*;

String BASE_VIDEO_PATH;
String MIDI_IN = "2bb bus";
HashMap<Character, Visual> visuals = new HashMap<Character, Visual>();
HashMap<Integer, Character> controlMap = new HashMap<Integer, Character>();
Visual currentVisual;

void setup() {
  noCursor();
  // ASSUMES VIDEOS ARE IN THE SKETCH DIR
  BASE_VIDEO_PATH = sketchPath("mp4");

  // MidiBus.list();
  new MidiBus(this, MIDI_IN, 1);

  visuals.put('1', new FiendForSleep(this));
  visuals.put('2', new FollowYouHome(this));
  visuals.put('3', new BeastsBreath(this));
  visuals.put('4', new MysteriesOfLove(this));
  visuals.put('5', new SolutionSarrus(this));
  visuals.put('6', new DeadMansLullaby(this));
  visuals.put('7', new HotSummer(this));

  controlMap.put(48, '1');
  controlMap.put(49, '2');
  controlMap.put(50, '3');
  controlMap.put(51, '4');
  controlMap.put(52, '5');
  controlMap.put(53, '6');
  controlMap.put(54, '7');
  controlMap.put(55, '0');

  size(800, 600, JAVA2D);
  frameRate(18);
}

void draw() {
  if (currentVisual != null) {
    try {
      currentVisual.draw();
    } 
    catch (Exception _) {
    }
  } else {
    // No visual, paint screen purple
    clear();
    background(128, 0, 128);
  }
}

void midiMessage(MidiMessage message, long timestamp, String busName) {
  if ((int)(message.getMessage()[0] & 0xFF) == 176) {
    // catch control messages and use them to pick a song yo.
    controlCommand(controlMap.get(message.getMessage()[1] & 0xFF));
  } else {
    if (currentVisual != null) {
      try {
        currentVisual.midiMessage(message);
      } 
      catch (Exception _) {
      }
    }
  }
}

void controlCommand(Character k) {
  Visual visual = visuals.get(k);

  if (visual != null) {
    if (currentVisual != null) {
      currentVisual.stop();
    }
    currentVisual = visual;
    currentVisual.loopMovie();
  } else {
    if (currentVisual != null) {
      currentVisual.stop();
      // Clear current visual to blank the screen when playback is stopped
      currentVisual = null;
    }
  }
}

void movieEvent(Movie m) {
  if (currentVisual != null) {
    currentVisual.movieEvent(m);
  }
}

void keyReleased() {
  controlCommand(key);
}

abstract class Visual {
  PApplet parent;
  Movie movie;
  MidiBus midiBus;
  int sequencerNote = 0;
  String moviePath;

  abstract void draw();

  Visual(PApplet parent, String moviePath) {
    this.parent = parent;
    this.movie = new Movie(this.parent, BASE_VIDEO_PATH + moviePath);
  }

  void loopMovie() {
    this.movie.loop();
  }

  void stop() {
    this.movie.stop();
  }

  void movieEvent(Movie m) {
    m.read();
  }

  void midiMessage(MidiMessage message) {
    //println("Note: " + (int)(message.getMessage()[1] & 0xFF) +
    //        " Velocity: " + (int)(message.getMessage()[2] & 0xFF));
    this.sequencerNote = (int)(message.getMessage()[1] & 0xFF);
  }
}



class FiendForSleep extends Visual {

  FiendForSleep(PApplet parent) {
    super(parent, "/fiend_for_sleep_800.mp4");
  }

  void draw() {
    if (movie != null) {
      image(this.movie, 0, 0, this.movie.width, this.movie.height);
      if (sequencerNote == 61) {
        filter(GRAY);
      } else if (sequencerNote == 62) {
        filter(DILATE);
      } else if (sequencerNote == 59) {
        filter(INVERT);
        filter(DILATE);
      }
    }
  }
}

class FollowYouHome extends Visual {
  FollowYouHome(PApplet parent) {
    super(parent, "/follow_you_home_800.mp4");
  }

  void draw() {
    if (movie != null) {
      image(movie, 0, 0, movie.width, movie.height);

      if (sequencerNote == 61) {
        filter(INVERT);
        filter(POSTERIZE, 4);
      } else if (sequencerNote == 62) {
        filter(THRESHOLD);
      } else if (sequencerNote == 63) {
      }
    }
  }
}

class BeastsBreath extends Visual {
  PImage img;
  int brightnessAdjust = 0;

  BeastsBreath(PApplet parent) {
    super(parent, "/beasts_breath_800.mp4");
    this.img = createImage(parent.width, parent.height, RGB);
  }

  private void adjustBrightness() {
    if (img != null && brightnessAdjust != 0) {
      for (int x = 0; x < img.width; x++) {
        for (int y = 0; y < img.height; y++ ) {
          int loc = x + y*img.width;
          float r = red(img.pixels[loc]);
          r += brightnessAdjust;
          r = constrain(r, 0, 255);
          color c = color(r);
          pixels[y*width + x] = c;
        }
      }
      updatePixels();
    } else {
      image(movie, 0, 0);
    }
  }

  private void distort() {
    loadPixels();

    int randPos = 0;
    if (frameCount  % 100 == 0) {
      randPos = (int)random(0, this.movie.height -4);
    }

    int randPosY = 0;

    randPosY = (int)random(20, 50);

    for (int y = 0; y < this.movie.height -57; y++) {
      if (this.img != null) {
        this.img.loadPixels();

        // Put 4 rows of pixels on the screen
        if (frameCount % 50 == 0) {
          randPosY = (int)random(20, 50);
        }

        for (int x = 0; x < this.movie.width; x++) {
          if (frameCount % 100 == 0) {
            randPosY = (int)random(20, 50);
          }

          if (y < movie.height -4) {
            pixels[x + (y + 0 + randPosY)* width] = this.img.pixels[(y + 0 ) * this.movie.width + randPos + x];
            pixels[x + (y + 1 + randPosY) * width] = this.img.pixels[(y + 1) * this.movie.width + randPos + 1 + x];
            pixels[x + (y + 2 + randPosY) * width] = this.img.pixels[(y + 2) * this.movie.width + randPos + 2 + x];
            pixels[x + (y + 3 + randPosY) * width] = this.img.pixels[(y + 3) * this.movie.width + randPos + 3 + x];

            pixels[x + (y + 4 + randPosY)* width] = this.img.pixels[(y + 4 )* this.movie.width + randPos + 4 + x];
            pixels[x + (y + 5 + randPosY) * width] = this.img.pixels[(y + 5) * this.movie.width + randPos + 5 + x];
            pixels[x + (y + 6 + randPosY) * width] = this.img.pixels[(y + 6) * this.movie.width + randPos + 6 + x];
            pixels[x + (y + 7 + randPosY) * width] = this.img.pixels[(y + 7) * this.movie.width + randPos + 7 + x];
          }
        }
      } else {
        break;
      }
    }
    updatePixels();
  }

  void draw() {
    if (this.sequencerNote == 61) {
      distort();
    } else if (sequencerNote == 62) {
      this.brightnessAdjust += 10;
      adjustBrightness();
    } else if (sequencerNote == 63) {
      this.brightnessAdjust = 0;
      adjustBrightness();
    } else {
      adjustBrightness();
    }
  }

  void movieEvent(Movie m) {
    m.read();
    this.img = createImage(width, height, RGB);
    this.movie.loadPixels();
    arrayCopy(this.movie.pixels, this.img.pixels);
  }
}

class HotSummer extends Visual {
  private Movie targetMovie;
  private int iterations = 5;
  private boolean recursiveIterations = false;
  private boolean shiftVertically = false;
  private boolean shiftHorizontally = true;

  HotSummer(PApplet parent) {
    super(parent, "/hot_summer_800.mp4");
    this.targetMovie = new Movie(this.parent, BASE_VIDEO_PATH + "/hot_summer_800.mp4");
  }

  void loopMovie() {
    this.movie.loop();
    this.targetMovie.loop();
  }

  void stop() {
    this.movie.stop();
    this.targetMovie.stop();
  }

  void draw() {
    if (sequencerNote == 61) {
      this.movie.loadPixels();
      targetMovie.loadPixels();

      for (int i = 0; i < iterations; i++) {
        int sourceChannel = int(random(3));
        int targetChannel = int(random(3));

        int horizontalShift = 0;

        if (shiftHorizontally)
          horizontalShift = int(random(targetMovie.width));

        int verticalShift = 0;

        if (shiftVertically) {
          verticalShift = int(random(targetMovie.height));
        }

        copyChannel(this.movie.pixels, targetMovie.pixels, verticalShift, horizontalShift, sourceChannel, targetChannel);

        if (recursiveIterations) {
          this.movie.pixels = targetMovie.pixels;
        }
      }

      targetMovie.updatePixels();

      image(targetMovie, 0, 0);
    } else {
      image(this.movie, 0, 0);
    }
  }

  private void copyChannel(color[] sourcePixels, color[] targetPixels, int sourceY, int sourceX, int sourceChannel, int targetChannel) {
    for (int y = 0; y < targetMovie.height; y++) {
      int sourceYOffset = sourceY + y;

      if (sourceYOffset >= targetMovie.height) {
        sourceYOffset -= targetMovie.height;
      }

      for (int x = 0; x < targetMovie.width; x++) {
        int sourceXOffset = sourceX + x;

        if (sourceXOffset >= targetMovie.width) {
          sourceXOffset -= targetMovie.width;
        }

        color sourcePixel = sourcePixels[sourceYOffset * targetMovie.width + sourceXOffset];
        float sourceRed = red(sourcePixel);
        float sourceGreen = green(sourcePixel);
        float sourceBlue = blue(sourcePixel);
        color targetPixel = targetPixels[y * targetMovie.width + x];
        float targetRed = red(targetPixel);
        float targetGreen = green(targetPixel);
        float targetBlue = blue(targetPixel);
        float sourceChannelValue = 0;

        switch(sourceChannel) {
        case 0:
          sourceChannelValue = sourceRed;
          break;
        case 1:
          sourceChannelValue = sourceGreen;
          break;
        case 2:
          sourceChannelValue = sourceBlue;
          break;
        }

        switch(targetChannel) {
        case 0:
          targetPixels[y * targetMovie.width + x] =  color(sourceChannelValue, targetGreen, targetBlue);
          break;
        case 1:
          targetPixels[y * targetMovie.width + x] =  color(targetRed, sourceChannelValue, targetBlue);
          break;
        case 2:
          targetPixels[y * targetMovie.width + x] =  color(targetRed, targetGreen, sourceChannelValue);
          break;
        }
      }
    }
  }
}

class SolutionSarrus extends Visual {
  final int REPEATS = 5;
  final color GLITCH_COLOR = color(77, 0, 0, 255);
  int jumpCount = 0;
  int currTime = 0;

  SolutionSarrus(PApplet parent) {
    super(parent, "/solution_sarrus_800.mp4");
  }

  void draw() {
    if (movie != null) {
      if (sequencerNote == 61) {
        boolean previousPixelGlitched = false;

        for (int x = 0; x < movie.width; x++) {
          for (int y = 0; y < movie.height; y++) {
            if (random(100) < 25 || (previousPixelGlitched == true && random(100) < 80)) {
              previousPixelGlitched = true;
              color pixelColor = movie.pixels[y + x * movie.height];
              float mixPercentage = .5 + random(50)/100;
              movie.pixels[y + x * movie.height] =  lerpColor(pixelColor, GLITCH_COLOR, mixPercentage);
            } else {
              previousPixelGlitched = false;
            }
          }
        }
        updatePixels();
      }

      image(this.movie, 0, 0, this.movie.width, this.movie.height);

      // Loop current 3 seconds REPEATS times
      int t = (int) round(movie.time());

      if ((t != 0) && (t != this.currTime)) {
        if ((t % 3) == 0) {
          if (jumpCount == REPEATS) {
            jumpCount = 0;
          } else {
            movie.jump(t - 2);
            jumpCount++;
          }
        }
      }
      this.currTime = t;
    }
  }
}

class DeadMansLullaby extends Visual {
  final int blockSize = 5;
  final int numPixelsWide = width / blockSize;
  final int numPixelsHigh = height / blockSize;
  final color movColors[] = new color[numPixelsWide * numPixelsHigh];
    
  DeadMansLullaby(PApplet parent) {
    super(parent, "/dead_mans_lullaby_800.mp4");
  }
  
  void gridify() {
    int count = 0;
    for (int j = 0; j < numPixelsHigh; j++) {
      for (int i = 0; i < numPixelsWide; i++) {
        movColors[count] = this.movie.get(i*blockSize, j*blockSize);
        count++;
      }
    }
    
    background(255);
    
    for (int j = 0; j < numPixelsHigh; j++) {
      for (int i = 0; i < numPixelsWide; i++) {
        fill(movColors[j*numPixelsWide + i]);
        rect(i*blockSize, j*blockSize, blockSize, blockSize);
      }
    }
  }

  void draw() {
    if (this.sequencerNote == 61) {
      gridify();
    } else if (sequencerNote == 62) {
      gridify();
      filter(INVERT);
    } else if (sequencerNote == 63) {
      gridify();
      filter(POSTERIZE, 4);
    } else {
      image(this.movie, 0, 0, this.movie.width, this.movie.height);  
    }
  }
}

class MysteriesOfLove extends Visual {
  int tintAdjust = 0;
  boolean videoSpeedSet = false;

  MysteriesOfLove(PApplet parent) {
    super(parent, "/mysteries_of_love_800.mp4");
  }

  void draw() {
    if (movie.available()) {
      if (!videoSpeedSet) {
        movie.speed(0.25);
        videoSpeedSet = true;
      }
      
      movie.read();
    }
    
    if (this.sequencerNote == 61) {
      this.tintAdjust -= 10;
    } else {
      if (this.tintAdjust != 255) {
        this.tintAdjust = 255;
      }
    }

    tint(constrain(this.tintAdjust, 0, 255), 
      constrain(this.tintAdjust, 0, 255), 
      constrain(this.tintAdjust, 0, 255), 
      128);
    image(this.movie, 0, 0);
  }
  
  // override this to set movie speed in draw()
  void movieEvent(Movie m) {
  }
}