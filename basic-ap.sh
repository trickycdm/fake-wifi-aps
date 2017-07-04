#!/bin/bash
INTERFACE=wlan1mon
# Start our interface in monitor mode
airmon-ng start wlan1
# Give our new interface an IP 
ifconfig wlan1mon 10.0.0.1/24 netmask 255.255.255.0
# Port forward out new interface to the built in wifi nic
iptables -t nat -F
iptables -F
iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
iptables -A FORWARD -i $INTERFACE -o wlan0 -j ACCEPT
# Set up IP forwarding in the kernal MUST BE DONE LAST!
echo '1' > /proc/sys/net/ipv4/ip_forward

# Set up main dnsmasq config 
echo "interface=wlan1mon
dhcp-range=10.0.0.10,10.0.0.250,12h
dhcp-option=3,10.0.0.1
dhcp-option=6,10.0.0.1
server=8.8.8.8
log-queries
log-dhcp" > dnsmasq.conf

# Create a fakehosts file, used only for example to see the format
echo "139.162.245.139 youtube.com" > fakehosts.conf

# Create hostapd.conf
echo "interface=wlan1mon
driver=nl80211
hw_mode=g
ssid=LOCALTEST
channel=1" > hostapd.conf

# Start dnsmasq in this terminal to stream logs
dnsmasq -C dnsmasq.conf -H fakehosts.conf -d

# You should run hostapd ./hostapd.conf in a new window
