#!/bin/sh
# Switch to accesspoint mode
cp /etc/network/interfaces.host /etc/network/interfaces
/etc/init.d/networking restart
ifconfig wlan0 10.0.0.1
/usr/local/bin/hostapd -B /etc/hostapd/hostapd.conf
/etc/init.d/hostapd start
/etc/init.d/isc-dhcp-server start
