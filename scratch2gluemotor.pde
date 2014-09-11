import processing.net.*;
import ddf.minim.*;
import ddf.minim.signals.*;

Minim minim;
AudioOutput audioOutput;
PulseWave pulseL;
PulseWave pulseR;
float FREQ = 50;
float MIN_PULSE_WIDTH = 4;
float MAX_PULSE_WIDTH = 20;
String HOST_ADDRESS = "127.0.0.1";

Client ScratchClient;

void setup() {
  minim = new Minim(this);
  audioOutput = minim.getLineOut(Minim.STEREO, 2048);
  
  pulseL = new PulseWave(FREQ, 1.0, audioOutput.sampleRate());
  pulseL.setPan(-1);
  audioOutput.addSignal(pulseL);

  pulseR = new PulseWave(FREQ, 1.0, audioOutput.sampleRate());
  pulseR.setPan(1);
  audioOutput.addSignal(pulseR);
  
  ScratchClient = new Client(this, HOST_ADDRESS, 42001);
}

void draw() {
  if (ScratchClient.available() > 0) {
    String str = ScratchClient.readString();
    String[] m = match(str, "sensor-update \"(.+?)\" (\\d+)");
    if (m != null) {     
      String valueName = m[1];
      String value = m[2];
      float floatValue = Float.parseFloat(value);
      float mappedValue = map(floatValue, 0, 100, MIN_PULSE_WIDTH, MAX_PULSE_WIDTH);
      if (valueName.equals("l")) {
        println("pulseL:" + mappedValue);
        pulseL.setPulseWidth(mappedValue);
      } else if (valueName.equals("r")) {
        println("pulseR:" + mappedValue);
        pulseR.setPulseWidth(mappedValue);
      }
    }
  }
}

void stop() {
  audioOutput.close();  
  minim.stop();
  super.stop();
}
