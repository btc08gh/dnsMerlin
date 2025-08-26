# dnsMerlin

## v1.0.0
### Updated on 2025-08-26

## About
dnsMerlin provides a comprehensive web interface for managing dnsmasq configuration on AsusWRT Merlin firmware. It simplifies the management of DNS settings, additional host files, DHCP static assignments, and DNS logging options through an intuitive web interface and command-line tools.

Key features include:
- **Multiple Additional Host Files** - Manage multiple `addn-hosts` entries with comments
- **DHCP Static Host Management** - Configure `dhcp-hostsfile` for static IP assignments  
- **DNS Query Logging** - Enable/disable DNS query logging with custom log file paths
- **Configuration Backup** - Automatic backup creation before changes
- **Real-time Validation** - Validates configuration syntax before applying
- **Web Interface** - User-friendly web UI integrated with Merlin firmware

dnsMerlin is free to use under the [GNU General Public License version 3](https://opensource.org/licenses/GPL-3.0) (GPL 3.0).

## Supported firmware versions
You must be running firmware Merlin 384.15/384.13_4 or Fork 43E5 (or later) [Asuswrt-Merlin](https://asuswrt.lostrealm.ca/)

## Installation
Using your preferred SSH client/terminal, copy and paste the following command, then press Enter:

```sh
/usr/sbin/curl --retry 3 "https://raw.githubusercontent.com/btc08gh/dnsMerlin/master/dnsmerlin.sh" -o "/jffs/scripts/dnsmerlin" && chmod 0755 /jffs/scripts/dnsmerlin && /jffs/scripts/dnsmerlin install
```

## Configuration Management

dnsMerlin manages your `/jffs/configs/dnsmasq.conf.add` file, supporting these dnsmasq options:

### Additional Host Files (addn-hosts)
Configure multiple additional host files for custom DNS entries:
```
addn-hosts=/jffs/configs/hosts
addn-hosts=/jffs/addons/YazDHCP.d/.hostnames # YazDHCP_hostnames
```

### DHCP Static Host File (dhcp-hostsfile)  
Configure static DHCP assignments:
```
dhcp-hostsfile=/jffs/addons/YazDHCP.d/.staticlist # YazDHCP_staticlist
```

### DNS Query Logging
Enable DNS query logging with optional custom log file:
```
log-queries
log-facility=/tmp/dnsmasq.log
```

## Usage

### WebUI
After installation, dnsMerlin can be accessed via the WebUI in the **Addons** section. The web interface provides:

- **Dynamic Host File Management** - Add/remove additional host files with real-time validation
- **DHCP Configuration** - Set up static IP assignments  
- **Logging Controls** - Enable/disable DNS query logging
- **Configuration Preview** - View current settings before applying changes
- **Automatic Backup** - Creates timestamped backups before modifications

### Command Line
To launch the dnsMerlin menu after installation, use:
```sh
dnsmerlin
```

If this does not work, you will need to use the full path:
```sh
/jffs/scripts/dnsmerlin
```

### CLI Menu Options
- **View DNS Status** - Check dnsmasq status and current configuration summary
- **Edit DNS Configuration** - Edit configuration files directly with nano/vi
- **View Configuration File** - Display current dnsmasq.conf.add contents
- **Restart dnsmasq** - Restart dnsmasq service to apply changes
- **Backup Configuration** - Create manual backup of current configuration

## Features

### 🛡️ **Safety Features**
- **Automatic Backups** - Creates timestamped backups before any changes
- **Configuration Validation** - Validates syntax before applying changes
- **Lock File Management** - Prevents concurrent modifications
- **Rollback Capability** - Easily restore from backups if needed

### 🔧 **Web Interface Features**  
- **Real-time Validation** - Validates file paths and configuration syntax
- **Dynamic Entry Management** - Add/remove host file entries without page reload
- **Unsaved Changes Detection** - Warns before leaving with unsaved changes
- **Auto-draft Saving** - Saves work-in-progress to localStorage
- **Responsive Design** - Works on desktop and mobile devices

### ⚡ **Performance Features**
- **Immediate Application** - Configuration changes applied instantly
- **Service Integration** - Automatic dnsmasq restart after changes
- **Minimal Overhead** - Lightweight script with fast execution
- **Background Processing** - Web interface changes processed asynchronously

## File Structure

After installation, dnsMerlin creates the following directory structure:

```
/jffs/addons/dnsmerlin.d/        # Main script directory
├── dnsstats_www.asp             # Web interface HTML
├── dnsstats_www.css             # Web interface styling  
├── dnsstats_www.js              # Web interface JavaScript
└── backups/                     # Configuration backups
    ├── dnsmasq.conf.add.20250826_120000
    └── dnsmasq.conf.add.20250826_130000

/www/user/dnsmerlin/             # Web accessible files (symlinks)
├── dnsstats_www.asp -> /jffs/addons/dnsmerlin.d/dnsstats_www.asp
├── dnsstats_www.css -> /jffs/addons/dnsmerlin.d/dnsstats_www.css
├── dnsstats_www.js -> /jffs/addons/dnsmerlin.d/dnsstats_www.js
└── dnsmasq.conf.add -> /jffs/configs/dnsmasq.conf.add
```

## Integration

dnsMerlin integrates seamlessly with other Merlin addons:
- **YazDHCP** - Manages YazDHCP host files and static lists
- **Diversion** - Compatible with ad-blocking host files
- **Custom Host Files** - Supports any additional host file locations

## Troubleshooting

### Common Issues

**Configuration not applying:**
- Check that dnsmasq.conf.add syntax is correct
- Verify file paths exist and are readable
- Restart dnsmasq manually: `service restart_dnsmasq`

**Web interface not accessible:**
- Ensure installation completed successfully
- Check that symlinks exist in `/www/user/dnsmerlin/`
- Verify Merlin firmware supports addons

**Command not found:**
- Use full path: `/jffs/scripts/dnsmerlin`
- Check that script has execute permissions: `chmod +x /jffs/scripts/dnsmerlin`

## Updates

Check for updates using the CLI:
```sh
dnsmerlin update
```

Or force update:
```sh  
dnsmerlin forceupdate
```

Updates can also be checked through the web interface.

## Uninstallation

To completely remove dnsMerlin:
```sh
dnsmerlin uninstall
```

This removes all dnsMerlin files but preserves your dnsmasq.conf.add configuration file.

## Help

Please post about any issues and problems here: [Asuswrt-Merlin AddOns on SNBForums](https://www.snbforums.com/forums/asuswrt-merlin-addons.60/?prefix_id=22)

## License

dnsMerlin is licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.

## Changelog

### v1.0.0 (2025-08-26)
- Initial release of dnsMerlin
- Complete transformation from ntpMerlin to DNS management
- Added web interface for dnsmasq configuration
- Implemented multiple addn-hosts file management
- Added DHCP static host file configuration
- Implemented DNS query logging controls
- Added automatic configuration backup system
- Created comprehensive CLI menu system