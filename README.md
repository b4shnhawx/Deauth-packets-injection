# Deauth-packets-injection
__NOTE: This script is only for educational and learning purposes and I am not responsible for misuse. Never use it to annoy or harm other people or systems. Use it only against your own networks and devices!!!__

This script injects many deauth packets against a client connected to an Access Point. So, what is a deauth packet?
> Deauthentication packets are legitimate from the IEEE 802.11 standard and are used for disconnect a client from the wireless network for
> various reasons. For example, when the password  its wrong, the AP send this packet to avoid that the client connects. Other example, 
> when the network reach the maximum number of possible connected clients, the AP sends deauth packets to the next clients that try to 
> connect.

Here is an example of how this packets are injected.
<p align="center">
  <img src="https://github.com/davidahid/OS-Backup-for-Raspbery/blob/master/images/problem.png">
</p>

Knowing this, we can use it to inject packets at our will to disconnect a specific device from almost any network.
