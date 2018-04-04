#!/usr/bin/env bash

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout portal.key -out portal.crt
mv portal.key /etc/ssl/private/portal.key
mv portal.crt /etc/ssl/private/portal.crt

mkdir /var/www/
mkdir /var/www/portal

# update system
apt-get update
apt-get upgrade -y

# install development packages
apt-get install -y arduino-mk arduino build-essential autoconf libtool swig3.0 python-dev cmake pkg-config libpcre3-dev

# clone repository and place it in root's home folder
cd ~
sudo git clone https://github.com/96boards-projects/smart-portal/

# install motion
apt-get install motion

# edit /etc/default/motion to switch daemon to on
sed -i 's =no =yes ' /etc/default/motion

# backup and copy configuration file
mv /etc/motion/motion.conf /etc/motion/motion.conf.bak
chmod 744 ~/smart-portal/home_node/_install/motion.conf 
mv ~/smart-portal/home_node/_install/motion.conf /etc/motion/motion.conf

# install mysql
apt-get install -y mysql-server mysql-client 

# setup database and user
mysql -r root < ~/smart-portal/home_node/_install/tables.sql

# install apache2
apt-get install -y apache2

# setup hosts file
VHOST=$(cat <<EOF
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
EOF
)

echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

# enable mod_rewrite
a2enmod rewrite
a2enmod ssl

# install php7.0
apt-get install -y php7.0 php7.0-mysql

# restart apache
service apache2 restart

# flash ATMEGA
cd ~/smart-portal/home_node/_install
ln -s /usr/share/arduino/Arduino.mk Makefile
make upload reset_stty

# remove _install folder, copy to change permissions and owner
rm -rf ~/smart-portal/home_node/_install
chmod 750 -r ~/smart-portal/home_node/
chown -R www-data ~/smart-portal/home_node/
cp -a ~/smart-portal/home_node/. /var/www/portal/

# create gpio group and add users
groupadd gpio 
usermod -a -G gpio www-data
usermod -a -G gpio linaro

# remove exit 0 from rc.local
sed -i "/exit 0/d " /etc/rc.local

# Inserting command to take place after boot into rc.local

new_boot=$(cat <<EOF
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
chown -R root:gpio /dev/ttyUSB*
chmod -R 770 /dev/ttyUSB*

# Release ATMEGA from reset
stty -F /dev/tty96B0 -hupcl

# start motion
motion &
exit 0
EOF
)

echo "${new_boot}" >> /etc/rc.local

# clean up
apt-get clean
rm -rf ~/smart-portal

echo "Installation complete."
read -n 1 -s -r -p "Press any key to continue..."
echo
