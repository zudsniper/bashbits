# PIA Configuration for Non-Persistent Linux

 This document includes resources, links, and code snippets useful for utilizing an existing **PAID**                      [PrivateInternetAccess][PIA]  _(or PIA)_ account semi-automatically, and on an operating system which does not persist    data. This means that the idea here is to create something that is entirely standalone.

 > This is under construction specifically for `Tails Linux 5.17`, and use is not guaranteed even on this Operating        System, nor any other. See [disclaimer](#DISCLAIMER).

 ## DISCLAIMER
 USE AT YOUR OWN RISK,
 THIS CODE IS NOT GUARANTEED TO WORK OR BE SAFE
 **READ BEFORE YOU EXECUTE**

 ## OVERVIEW
 - We will need to first understand how to use OpenVPN, which is the opensource CLI tool most compatible, and most         standard, with linux distributions.
 - We also need to (optionally) understand the way that TOR/ONION routing functions in relation to OpenVPN, if you intend  to use TOR/ONION.
 - It will become apparent that a `SOCKS5` proxy is necessary for VPN use, especially for TOR/ONION routing. [PIA][PIA]    provides a Netherlands `SOCKS5` proxy within the default subscription, and due to the stringent legislatin regarding      data privacy in this country, we will use this proxy. Obviously, we will need to configure this as well with the same     stipulations of a standalone system for Linux.
 - We must then locate the `.ovpn` configuration files for [PIA][PIA] (see link #1)
   - These `.ovpn` files may contain **sensitive authentication information**, and if so, this must be handled with care.
   - We must not, for instance, store any **auth info** unencrypted.
   - It could also be useful to take this time to look into how [PIA][PIA] specifically can be used, and if any extra      steps or convenience features can be taken advantage of.
   - **it is paramount** that proxying be considered, and from this point on will be assumed to be a non-optional          requirement. Specifically, we will be using [PIA's Netherlands `SOCKS5` Proxy][PIA_PROXY][^1]
 - Next we must ensure that [OpenVPN][OVPN] is I. installed and II. configured with our previously obtained `.ovpn`      files. We also need to configure the `SOCKS5` proxy.
- Once this is accomplished, we need to configure both the the obtained [PIA][PIA] Netherlands `SOCKS5` proxy as well as, after choosing an appropriate `.ovpn` file for the desired connection location[^2], use this selected `.ovpn` file to connect to the [PIA][PIA] VPN server via [OpenVPN][OVPN]'s CLI tool. 
   - We must ensure that this connection is being used by the whole system, assuming a `systemd` based Linux environment. 
   - We must ensure that TOR/ONION routing **is also routed through the proxy & the VPN connection** we have established. 
- Once this connection is established correctly, ***we are done!*** ✅

###

 ### LINKS
 1. [PIA OpenVPN Files (Help article with more links)][PIA_OVPN]
 2. [How to use PIA's bundled `SOCKS5` proxy][PIA_PROXY]


 [^1]: More information on obtaining your PIA Proxy login/configuration information can be found here.  
 [^2]: Region decision should most likely be made by the user with a command line flag for the script, but if nothing is provided on `stdin`, such as in the event that we are `curl`ing this script and piping it to `/bin/bash`, the region should default to any PIA server in the Netherlands.

 [PIA]: https://privateinternetaccess.com
 [PIA_OVPN]: https://helpdesk.privateinternetaccess.com/kb/articles/where-can-i-find-your-ovpn-files
 [PIA_PROXY]: https://www.vpnuniversity.com/tutorial/pia-socks-proxy
 [OVPN]: https://openvpn.net/