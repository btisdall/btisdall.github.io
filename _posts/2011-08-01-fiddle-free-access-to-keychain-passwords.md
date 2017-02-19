---
title: Fiddle-free access to OSX keychain passwords
date: 2011-08-01
tags: [ OSX, Alfred, Perl, productivity ]
---

As someone that prefers keyboard over mouse using Mac OSX's keychain to store ad-hoc usernames/passwords was always too much bother for me, but having started to use the nifty [Alfred](http://www.alfredapp.com/) recently I've been looking at ways of automating my everyday workflows.

It turns out that since OSX 10.5 Apple ship the 'security' tool which lets one programmatically access the keychain without having to muck around with Applescript:

```bash
# Access the keychain item named "holly"
security find-generic-password -l holly

# Same thing but print the password (to stderr) also
security find-generic-password -l holly -g

# Use a custom keychain
security find-generic-password -l holly -g ~/Library/Keychains/bentis-passwords.keychain
```

Armed with this information it's easy to construct a shell script for Alfred to pass a parameter (represented by {query}) to. We need to parse the output from security so of course we'll use Perl:

```bash
# slurp in the whole of the output from "security" and parse out what we need (note: the password is printed to stderr)
security find-generic-password -l {query} -g ~/Library/Keychains/bentis-passwords.keychain 2>&1 \
| perl -0777 -nE '($user) = /"svce"<\w+>="([^"]+)/; ($pass) = /password:\s+"([^"]+)/ }{ say "$user:$pass"'

# Lock the keychain behind us
security lock-keychain ~/Library/Keychains/bentis-passwords.keychain
```

In Alfred's options we tick the advanced option 'Display script output in Growl' and we're done!
