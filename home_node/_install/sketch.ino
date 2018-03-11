#include <Servo.h>
Servo xservo; // servo that moves x-axis
Servo yservo; // servo that moves y-axis

//Servo Variables
int XServoPin = 7;  // Servo pin that will control X motion
int YServoPin = 6;  // Servo pin that will control Y motion
int xpos = 0;
int xneg = 0;
int ypos = 0;
int yneg = 0;
int reset = 0;
int x = 90;
int y = 90;

//Lazer Variables
int laserPin = 4;
int lase = 0;
int laserON = 0;

void setup() {
    pinMode(laserPin,OUTPUT);	// The laser will be an output

    xservo.attach(XServoPin);	// attaches the servo on pin 7 to servo obj
    xservo.write(x);
    yservo.attach(YServoPin);	// attaches the servo on pin 6 to servo obj'
    yservo.write(y);
	//Serial.begin(9600);
}

void loop() {
	//Serial.println(digitalRead(13));

	xpos = analogRead(A0);  // move left
	xneg = analogRead(A1);  // move right
	ypos = analogRead(A2);  // move up
	yneg = analogRead(A3);  // move down
	reset = analogRead(A5); // reset
	lase = analogRead(A4);  // laser

	if(lase>300){
		if(laserON){
			digitalWrite(laserPin, LOW); // Turn laser off
			laserON = 0;
		} else {
			digitalWrite(laserPin, HIGH); // Turn laser off
			laserON = 1;
		}
	}

	if(xpos>300){
		if(x<180){
			x+=5;
		}
	}

	if(xneg>300){
		if(x>0){
			x-=5;
		}
	}

	if(ypos>300){
		if(y<180){
			y+=5;
		}
	}

	if(yneg>300){
		if(y>0){
			y-=5;
		}
	}

	if(reset>300){
		x = 90;
		y = 90;
	}

	xservo.write(x);
	yservo.write(y);

	delay(1000);
}                                  