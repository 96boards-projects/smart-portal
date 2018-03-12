#!/usr/bin/env python

import serial, sys
from time import gmtime, strftime

# open serial
ser = serial.Serial('/dev/ttyUSB0', 115200)

# get data
data = ser.readline()

# convert to decimal
data = int(data, 16)

# convert celsius to fahrenheit
data = 9.0/5.0 * data + 32

# get time
time = strftime("%H:%M", gmtime())

# store
data = str(data)
f = open('data.txt', 'w')
f.write("Temperature is " + str(data) + " degF at " +str(time))

f.close()
ser.close()