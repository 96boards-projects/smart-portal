# Home Node

## Table of Contents
- [1) Prerequisites](#prerequistes)
- [2) Installation](#installation)
- [3) Carbon IoT client board](#carbon)
- [4) Credits](#credits)

## 1) Prerequisites <a name="prerequistes"></a>
1. The Dragonboard must be flashed with a Linux operating system.
Note: This project is only tested with the default Debian image provided by 96boards.
2. With the Dragonboard unpowered, attached the Sensors Mezzanine board 
3. Attach other accessories.
- Display through HDMI
- USB webcam
- IoT board
- wires and kits according to the table below

| Type        | Grove / Output | Arduino Input | GPIOs |
| ----------- |:--------------:|:-------------:|:-----:|
| X Servo     | D7             | A0, A1        | L, J |
| Y Servo     | D6             | A2, A3        | D, B |
| Laser       | D4             | A4            | C    |
| Servo Reset | NA             | A5            | K    |
| Buzzer      | EF             | 1             | E    |

- Attached one end of a resistor to each arduino input and connect the other end to the ground
![alt text]( https://https://github.com/96boards-projects/smart-portal/tree/master/pictures/control_circuit.PNG)


## 2) Installation <a name="installation"></a>

### 2.1 Auto-Installation
Additional packages and basic configuration can be accomplished through the auto-install script.

Download the install script
```
wget https://https://github.com/96boards-projects/smart-portal/tree/master/home_node/_install/install.sh
```

Make it executable
```
chmod +x install.sh
```

Run it with root privileges.
```
sudo bash ./install.sh
```

Skip to 2.3 Additonal Configuration.

### 2.2 Self Installation
1. Most commands need to executed with root privileges. Update the package list and newer versions of packages.
```
sudo su
apt-get update
apt-get upgrade
```

2. Install additional packages
```
apt get install -y motion mysql-server mysql-client apache2 php7.0 php7.0-mysql
apt get install -y arduino-mk arduino build-essential autoconf libtool swig3.0 python-dev cmake pkg-config libpcre3-dev
```

3. Edit motion's configuration file `/etc/default/motion` and `/etc/motion/motion.conf` to your needs. Note: The portal assumes motion stream port is 8081. Attach the webcam and check that motion works.

4. Clone the home_node repository into `/var/www/portal`

5. Execute SQL statements from `/var/www/portal/_install` folder to setup database tables and user.

6. Generate ssl key and cert for encrypted http connection.
```
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout portal.key -out portal.crt
mv portal.key /etc/ssl/private/portal.key
mv portal.crt /etc/ssl/private/portal.crt
```

7. Configure Apache. `/etc/apache2/sites-available/000-default.conf'
```
<VirtualHost *:80>
	RewriteEngine on
	RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,QSA,R=permanent]
</VirtualHost>

<VirtualHost *:443>
    DocumentRoot /var/www/portal
    <Directory "/var/www/portal">
        AllowOverride All
        Require all granted
    </Directory>

    SSLEngine on
    SSLOptions +StrictRequire
    SSLCertificateFile /etc/ssl/private/portal.crt
    SSLCertificateKeyFile /etc/ssl/private/portal.key
</VirtualHost>
```

8. Enable apache modules and restart apache
```
a2enmod rewrite
a2enmod ssl
service apache2 restart
```

9. Flash the ATMEGA chip
Copy the arduino code (sketch.ino) from the _install folder. Flash the code onto the ATMEGA chip.
```
ln -s /usr/share/arduino/Arduino.mk Makefile
make upload reset_stty
```

10. Create gpio group and add users
```
groupadd gpio 
usermod -a -G gpio www-data
```

11. Add these lines to '/etc/rc.local' (above the line exit 0) to give www-data access to GPIOs and start motion on boot
```
# Export GPIO to userspace
echo "33" > /sys/class/gpio/export
echo "34" > /sys/class/gpio/export
echo "69" > /sys/class/gpio/export
echo "12" > /sys/class/gpio/export
echo "28" > /sys/class/gpio/export
echo "115" > /sys/class/gpio/export
echo "13" > /sys/class/gpio/export

# Set GPIO direction
echo "out" > /sys/class/gpio/gpio33/direction
echo "out" > /sys/class/gpio/gpio34/direction
echo "out" > /sys/class/gpio/gpio69/direction
echo "out" > /sys/class/gpio/gpio12/direction
echo "out" > /sys/class/gpio/gpio28/direction
echo "out" > /sys/class/gpio/gpio115/direction
echo "out" > /sys/class/gpio/gpio13/direction

# Give permissions to group gpio
chown -R root:gpio /sys/class/gpio
chmod -R 770 /sys/class/gpio
chown -R root:gpio /sys/devices/platform/soc/1000000.pinctrl/gpio*
chmod -R 770 /sys/devices/platform/soc/1000000.pinctrl/gpio*

# Release ATMEGA from reset
stty -F /dev/tty96B0 -hupcl

# start motion
motion &
```

### 2.3 Additional Configuration
- Motion configuration file might need to be updated depending on the type of USB webcam used.
- pyserial.py script assumes that the client IoT board address is /dev/ttyUSB0.

Some additional configuration is necessary to access that Dragonboard from the Internet. There are numerous variation and the details are out of scope of this project. Please refer to specific codes / devices for these items:
- ddclient for DDNS
- static IP on dragonboard
- router port forwarding / firewall configuration

## 3) Carbon IoT client board <a name="carbon"></a>
The Carbon IoT boards should be setup, configured and provisioned. 
Note: To keep the Carbon IoT board provisioned settings, ensure that the Dragonboard is powered before physically attaching a USB cable to the Carbon IoT board.

## 4) Credits <a name="credits"></a>
- 96boards for providing the hardware and guidance for this project
- @Repox for SimpleUsers php code  https://github.com/Repox/SimpleUsers
- [Tutorialrepublic](https://www.tutorialrepublic.com/) for php and sql examples 
- Dragonboard 410c Case: https://www.thingiverse.com/thing:1090288

