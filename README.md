# Fake Wifi APs
A selection of scripts to help create fake WIfi APs in Kali2. We will be using dnsmasq and 
hostapd. This process is designed to bridge 2 Wifi nics, so one is the access point and the 
other is the output, i.e USB wifi card as the AP, forwarding to the built in Wifi nic. A very 
portable setup.
## USB Wifi Cards
I have used this with both a TP-LINK TL-WN722N & an ALFA AWUS051NH v.2
## Required packages

   apt-get install -y hostapd dnsmasq wireless-tools iw wvdial

## The Setup 
There are a few steps you need to follow in sequence. You can either run the 'basic-ap.sh' script or do these manually. The basic script will automate 90% of it.
### Into monitor mode
First thing to do is set up our USB nic in monitor mode. There is a 99% chance your USB card will be assigned wlan1, wlan0 being added to the built in nic. So we will run:
   
    airmon-ng start wlan1

This will create a new interface called (most likley) wlan1mon. Veryify all this by frequent 
   
    ifconfig

This will give you the info you need.
### Assign an IP
Your new interface will need and IP, lets give it one:
   
    ifconfig wlan1mon 10.0.0.1 netmask 255.255.255.0

We use a 10. address to avoid and clashes with existing networks.
### Set up some IP rules
We need to forward our USB nic traffic to our built in nic, add these rules to do so:

    iptables -t nat -F
    iptables -F
    iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
    iptables -A FORWARD -i $INTERFACE -o wlan0 -j ACCEPT
    echo '1' > /proc/sys/net/ipv4/ip_forward

### Fire up our DHCP service
Using dnsmasq lets bind to our new interface, it uses a global conf, but for simplicity we create our own local one in 'dnsmasq.conf':

    interface=wlan1mon
    dhcp-range=10.0.0.10,10.0.0.250,12h
    dhcp-option=3,10.0.0.1
    dhcp-option=6,10.0.0.1
    server=8.8.8.8
    log-queries
    log-dhcp

Create a 'fakehosts.conf' then add whatever DNS override you want, e.g

    10.0.0.17 youtube.com

Then run dnsmasq

    dnsmasq -C dnsmasq.conf -H fakehosts.conf -d

### Fire up hostapd again with a local conf
Creat this file as 'hostapd.conf'
    
    interface=wlan1mon
    dhcp-range=10.0.0.10,10.0.0.250,12h
    dhcp-option=3,10.0.0.1
    dhcp-option=6,10.0.0.1
    server=8.8.8.8
    log-queries
    log-dhcp

Run the service in a new terminal window:
    
    hostapd ./hostapd.conf

## That's it! Almost...
There are a few common pit falls
* Double check all interface names, depending on device hardware your interface may NOT be called wlan1
* Running both services in seperate terminal windows let you see the sreamed output, much easier for initial debuggin should it go wrong. Both these are designed to be run as deamons so can be set up to use global init.d conf files
* The driver specified in the hostapd.conf is DEFINATLY correct for the 2 wifi cards listed 
# Disclaimer
Don't do bad stuff with this, just have fun and some coffee.
