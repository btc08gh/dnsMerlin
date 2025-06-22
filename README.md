# dnsMerlin

THIS IS A Work In Progress

it does NOT currently work at all.

Do NOT use

## v0.1.0
### Updated on 2025-06-22
## About
dnsMerlin equips AsusWRT Merlin with a full-featured DNS layer and a streamlined WebUI for editing DNSMasq options.

dnsMerlin is free to use under the [GNU General Public License version 3](https://opensource.org/licenses/GPL-3.0) (GPL 3.0).

## Supported firmware versions
You must be running firmware Merlin 384.15/384.13_4 or Fork 43E5 (or later) [Asuswrt-Merlin](https://asuswrt.lostrealm.ca/)

## Installation
Using your preferred SSH client/terminal, copy and paste the following command, then press Enter:

```sh
/usr/sbin/curl --retry 3 \
  "https://raw.githubusercontent.com/btc08gh/dnsMerlin/master/dnsmerlin.sh" \
  -o "/jffs/scripts/dnsmerlin" && \
  chmod 0755 /jffs/scripts/dnsmerlin && \
  /jffs/scripts/dnsmerlin install
```

## Usage
### WebUI
dnsMerlin can be configured via the WebUI, in the Addons section.

### Command Line
To launch the ntpMerlin menu after installation, use:
```sh
dnsmerlin
```

If this does not work, you will need to use the full path:
```sh
/jffs/scripts/dnsmerlin
```

## Screenshots

coming soon

## Help

coming soon
