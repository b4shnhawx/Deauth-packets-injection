# Deauth-packets-injection
__NOTE: This script is only for educational and learning purposes and I am not responsible for misuse. Never use it to annoy or harm other people or systems. Use it only against your own networks and devices!!!__

This script injects many deauth packets against a client connected to an Access Point. So, what is a deauth packet?
> Deauthentication packets are legitimate from the IEEE 802.11 standard and are used for disconnect a client from the wireless network for
> various reasons. For example, when the password  its wrong, the AP send this packet to avoid that the client connects. Other example, 
> when the network reach the maximum number of possible connected clients, the AP sends deauth packets to the next clients that try to 
> connect.

Here is an example of how this packets are injected (left). Also we can view an deauthentication packet sniffing (right).
<p align="center">
  <img width="200" height="300" src="https://github.com/davidahid/Deauth-packets-injection/blob/master/images/deauth_desc.png">
</p>

Knowing all this, we can use it to inject packets at our will to disconnect a specific device from almost any network.
The program that we going to use is the aircrack-ng suit in Kali Linux.
