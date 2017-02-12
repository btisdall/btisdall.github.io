---
title: Handy tools for debugging DHCP on Linux
date: 2012-01-06 09:58:42
categories: Linux, DHCP, DevOps, networking
---

Sometimes it's very useful to able to test that your DHCP server is going to do the right thing with a given client without actually going as far as trying to acquire an address. For example you might be remotely connected to a server and not want to risk being shut out if the dchp client fails to acquire the expected, or any address. On Linux (and I daresay many other \*nix) two tools are very useful here, `dhcping` and `dhcpdump`.

`dhcping` sends a *DHCPREQUEST* packet, waits for a reply and prints information indicating success or failure and exits with 0 or 1 as appropriate. Use the `-v` or `-V` flags for more verbose ouput. The options I most frequently use are `-h`, the client hardware address, `-s` the target dhcp server address and `-c` for the address you're expecting the reply to be returned to (I don't know why this is necessary but I find I get a *DHCPNACK* reply if not).

A typical invocation would therefore be:

```bash
sudo dhcping -h 00:12:3f:20:11:49 -s 10.1.200.200 -c 10.1.200.1
```

And a typical reply indicating success:

```bash
Got answer from: 10.1.200.200
```

Otherwise you'll see:

```bash
no answer
```

`dhcping` on it's own is handy, but even with `-V` you won't get to see a lot of useful information in the dhcp server's reply - this is where `dhcpdump` comes in. `dhcpdump` is a tcpdump-like tool built atop libpcap, optimised for dhcp debugging. Usage is very simple:

```bash
dhcpdump -i IFACE  [ -h REGEX ]
```

eg:

```bash
# Match any dhcp packet
dhcpdump -i eth0

# Only match packets to/from hw address 00:12:3f:20:11:49
dhcpdump -i eth0 -h 00:12:3f:20:11:49

# Only match packets to/from hw addresses beginning 00:14
dhcpdump -i eth0 -h ^00:14
```


So, *now* we can run our dhcping command again, this time in other window dumping the conversation. Here's the output from a dump, showing only the *DHCPACK* part:

```bash
---------------------------------------------------------------------------

  TIME: 2012-01-06 13:25:00.365
    IP: 10.1.200.200 (2e:fa:97:1:b6:69) > 10.1.200.1 (0:12:3f:20:11:49)
    OP: 2 (BOOTPREPLY)
 HTYPE: 1 (Ethernet)
  HLEN: 6
  HOPS: 0
   XID: 2cf6064f
  SECS: 0
 FLAGS: 0
CIADDR: 0.0.0.0
YIADDR: 10.1.200.1
SIADDR: 10.1.200.200
GIADDR: 0.0.0.0
CHADDR: 00:12:3f:20:11:49:00:00:00:00:00:00:00:00:00:00
 SNAME: .
 FNAME: pxelinux.0.
OPTION:  53 (  1) DHCP message type         5 (DHCPACK)
OPTION:  54 (  4) Server identifier         10.1.200.200
OPTION:  51 (  4) IP address leasetime      86400 (24h)
OPTION:  58 (  4) T1                        43200 (12h)
OPTION:  59 (  4) T2                        75600 (21h)
OPTION:   1 (  4) Subnet mask               255.255.255.0
OPTION:  28 (  4) Broadcast address         10.1.200.255
OPTION:   6 (  4) DNS server                10.1.200.200
OPTION:  15 ( 23) Domainname                test.tisdall.org.uk
OPTION:  12 ( 11) Host name                 bentis-test
OPTION:   3 (  4) Routers                   10.1.200.254
---------------------------------------------------------------------------
```

That's nice isn't it! We can see clearly here the dhcp options that the client will receive when we run dhclient for real, eg we'll be assigned address denoted by *YIADDR* and the file `pxelinux.0` will be requested when the server network boots. Notice that in this case *SNAME* (the server used to network boot) is ".", meaning the same as *SIADDR* (the dchp server address).
