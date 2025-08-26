#!/bin/sh

##############################################################
##         _           __  __              _  _             ##
##        | |         |  \/  |            | |(_)            ##
##  _ __  | |_  _ __  | \  / |  ___  _ __ | | _  _ __       ##
## | '_ \ | __|| '_ \ | |\/| | / _ \| '__|| || || '_ \      ##
## | | | || |_ | |_) || |  | ||  __/| |   | || || | | |     ##
## |_| |_| \__|| .__/ |_|  |_| \___||_|   |_||_||_| |_|     ##
##             | |                                          ##
##             |_|                                          ##
##                                                          ##
##          https://github.com/btc08gh/dnsMerlin            ##
##                                                          ##
##############################################################

###############       Shellcheck directives      #############
# shellcheck disable=SC2009
# shellcheck disable=SC2012
# shellcheck disable=SC2016
# shellcheck disable=SC2018
# shellcheck disable=SC2019
# shellcheck disable=SC2059
# shellcheck disable=SC2086
# shellcheck disable=SC2155
##############################################################

### Start of script variables ###
readonly SCRIPT_NAME="dnsMerlin"
readonly SCRIPT_NAME_LOWER="dnsmerlin"
readonly SCRIPT_VERSION="v1.0.0"
SCRIPT_BRANCH="master"
SCRIPT_REPO="https://raw.githubusercontent.com/btc08gh/$SCRIPT_NAME/$SCRIPT_BRANCH"
readonly SCRIPT_DIR="/jffs/addons/$SCRIPT_NAME_LOWER.d"
readonly SCRIPT_WEBPAGE_DIR="$(readlink /www/user)"
readonly SCRIPT_WEB_DIR="$SCRIPT_WEBPAGE_DIR/$SCRIPT_NAME_LOWER"
readonly SHARED_DIR="/jffs/addons/shared-jy"
readonly SHARED_REPO="https://raw.githubusercontent.com/jackyaz/shared-jy/master"
readonly SHARED_WEB_DIR="$SCRIPT_WEBPAGE_DIR/shared-jy"
readonly DNSMASQ_CONF="/jffs/configs/dnsmasq.conf.add"
readonly DNSMASQ_BACKUP_DIR="$SCRIPT_DIR/backups"
### End of script variables ###

### Start of output format variables ###
readonly CRIT="\\e[41m"
readonly ERR="\\e[31m"
readonly WARN="\\e[33m"
readonly PASS="\\e[32m"
readonly BOLD="\\e[1m"
readonly SETTING="${BOLD}\\e[36m"
readonly CLEARFORMAT="\\e[0m"
### End of output format variables ###

# $1 = print to syslog, $2 = message to print, $3 = log level
Print_Output(){
	if [ "$1" = "true" ]; then
		logger -t "$SCRIPT_NAME" "$2"
	fi
	printf "${BOLD}${3}%s${CLEARFORMAT}\\n\\n" "$2"
}

Firmware_Version_Check(){
	if nvram get rc_support | grep -qF "am_addons"; then
		return 0
	else
		return 1
	fi
}

### Code for these functions inspired by https://github.com/Adamm00 - credit to @Adamm ###
Check_Lock(){
	if [ -f "/tmp/$SCRIPT_NAME.lock" ]; then
		ageoflock=$(($(date +%s) - $(date +%s -r /tmp/$SCRIPT_NAME.lock)))
		if [ "$ageoflock" -gt 600 ]; then
			Print_Output true "Stale lock file found (>600 seconds old) - purging lock" "$ERR"
			kill "$(sed -n '1p' /tmp/$SCRIPT_NAME.lock)" >/dev/null 2>&1
			Clear_Lock
			echo "$$" > "/tmp/$SCRIPT_NAME.lock"
			return 0
		else
			Print_Output true "Lock file found (age: $ageoflock seconds) - stopping to prevent duplicate runs" "$ERR"
			if [ -z "$1" ]; then
				exit 1
			else
				return 1
			fi
		fi
	else
		echo "$$" > "/tmp/$SCRIPT_NAME.lock"
		return 0
	fi
}

Clear_Lock(){
	rm -f "/tmp/$SCRIPT_NAME.lock" 2>/dev/null
	return 0
}
############################################################################

Set_Version_Custom_Settings(){
	SETTINGSFILE="/jffs/addons/custom_settings.txt"
	case "$1" in
		local)
			if [ -f "$SETTINGSFILE" ]; then
				if [ "$(grep -c "dnsmerlin_version_local" $SETTINGSFILE)" -gt 0 ]; then
					if [ "$2" != "$(grep "dnsmerlin_version_local" /jffs/addons/custom_settings.txt | cut -f2 -d' ')" ]; then
						sed -i "s/dnsmerlin_version_local.*/dnsmerlin_version_local $2/" "$SETTINGSFILE"
					fi
				else
					echo "dnsmerlin_version_local $2" >> "$SETTINGSFILE"
				fi
			else
				echo "dnsmerlin_version_local $2" >> "$SETTINGSFILE"
			fi
		;;
		server)
			if [ -f "$SETTINGSFILE" ]; then
				if [ "$(grep -c "dnsmerlin_version_server" $SETTINGSFILE)" -gt 0 ]; then
					if [ "$2" != "$(grep "dnsmerlin_version_server" /jffs/addons/custom_settings.txt | cut -f2 -d' ')" ]; then
						sed -i "s/dnsmerlin_version_server.*/dnsmerlin_version_server $2/" "$SETTINGSFILE"
					fi
				else
					echo "dnsmerlin_version_server $2" >> "$SETTINGSFILE"
				fi
			else
				echo "dnsmerlin_version_server $2" >> "$SETTINGSFILE"
			fi
		;;
	esac
}

Update_Check(){
	echo 'var updatestatus = "InProgress";' > "$SCRIPT_WEB_DIR/detect_update.js"
	doupdate="false"
	localver=$(grep "SCRIPT_VERSION=" "/jffs/scripts/$SCRIPT_NAME_LOWER" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
	/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" | grep -qF "btc08gh" || { Print_Output true "404 error detected - stopping update" "$ERR"; return 1; }
	serverver=$(/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" | grep "SCRIPT_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
	if [ "$localver" != "$serverver" ]; then
		doupdate="version"
		Set_Version_Custom_Settings server "$serverver"
		echo 'var updatestatus = "'"$serverver"'";'  > "$SCRIPT_WEB_DIR/detect_update.js"
	else
		localmd5="$(md5sum "/jffs/scripts/$SCRIPT_NAME_LOWER" | awk '{print $1}')"
		remotemd5="$(curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" | md5sum | awk '{print $1}')"
		if [ "$localmd5" != "$remotemd5" ]; then
			doupdate="md5"
			Set_Version_Custom_Settings server "$serverver-hotfix"
			echo 'var updatestatus = "'"$serverver-hotfix"'";'  > "$SCRIPT_WEB_DIR/detect_update.js"
		fi
	fi
	if [ "$doupdate" = "false" ]; then
		echo 'var updatestatus = "None";'  > "$SCRIPT_WEB_DIR/detect_update.js"
	fi
	echo "$doupdate,$localver,$serverver"
}

Update_Version(){
	if [ -z "$1" ]; then
		updatecheckresult="$(Update_Check)"
		isupdate="$(echo "$updatecheckresult" | cut -f1 -d',')"
		localver="$(echo "$updatecheckresult" | cut -f2 -d',')"
		serverver="$(echo "$updatecheckresult" | cut -f3 -d',')"
		
		if [ "$isupdate" = "version" ]; then
			Print_Output true "New version of $SCRIPT_NAME available - $serverver" "$PASS"
		elif [ "$isupdate" = "md5" ]; then
			Print_Output true "MD5 hash of $SCRIPT_NAME does not match - hotfix available - $serverver" "$PASS"
		fi
		
		if [ "$isupdate" != "false" ]; then
			printf "\\n${BOLD}Do you want to continue with the update? (y/n)${CLEARFORMAT}  "
			read -r confirm
			case "$confirm" in
				y|Y)
					printf "\\n"
					Update_File shared-jy.tar.gz
					Update_File dnsstats_www.asp
					Update_File dnsstats_www.css
					Update_File dnsstats_www.js
					
					/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" -o "/jffs/scripts/$SCRIPT_NAME_LOWER" && Print_Output true "$SCRIPT_NAME successfully updated"
					chmod 0755 "/jffs/scripts/$SCRIPT_NAME_LOWER"
					Set_Version_Custom_Settings local "$serverver"
					Set_Version_Custom_Settings server "$serverver"
					Clear_Lock
					PressEnter
					exec "$0"
					exit 0
				;;
				*)
					printf "\\n"
					Clear_Lock
					return 1
				;;
			esac
		else
			Print_Output true "No updates available" "$WARN"
			Clear_Lock
		fi
	fi
	
	if [ "$1" = "force" ]; then
		serverver=$(/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" | grep "SCRIPT_VERSION=" | grep -m1 -oE 'v[0-9]{1,2}([.][0-9]{1,2})([.][0-9]{1,2})')
		Print_Output true "Downloading latest version ($serverver) of $SCRIPT_NAME" "$PASS"
		Update_File shared-jy.tar.gz
		Update_File dnsstats_www.asp
		Update_File dnsstats_www.css  
		Update_File dnsstats_www.js
		/usr/sbin/curl -fsL --retry 3 "$SCRIPT_REPO/$SCRIPT_NAME_LOWER.sh" -o "/jffs/scripts/$SCRIPT_NAME_LOWER" && Print_Output true "$SCRIPT_NAME successfully updated"
		chmod 0755 "/jffs/scripts/$SCRIPT_NAME_LOWER"
		Set_Version_Custom_Settings local "$serverver"
		Set_Version_Custom_Settings server "$serverver"
		if [ -z "$2" ]; then
			Clear_Lock
			PressEnter
			exec "$0"
		elif [ "$2" = "unattended" ]; then
			exec "$0" postupdate
		fi
		exit 0
	fi
}

Update_File(){
	if [ "$1" = "dnsstats_www.asp" ]; then
		tmpfile="/tmp/$1"
		Download_File "$SCRIPT_REPO/$1" "$tmpfile"
		if [ -f "$tmpfile" ]; then
			if [ "$(md5sum "$1" 2>/dev/null | awk '{print $1}')" != "$(md5sum "$tmpfile" | awk '{print $1}')" ]; then
				Print_Output true "New version of $1 downloaded" "$PASS"
				mv "$tmpfile" "$SCRIPT_DIR/$1"
			fi
		fi
	elif [ "$1" = "dnsstats_www.css" ]; then
		tmpfile="/tmp/$1"
		Download_File "$SCRIPT_REPO/$1" "$tmpfile"
		if [ -f "$tmpfile" ]; then
			if [ "$(md5sum "$1" 2>/dev/null | awk '{print $1}')" != "$(md5sum "$tmpfile" | awk '{print $1}')" ]; then
				Print_Output true "New version of $1 downloaded" "$PASS"
				mv "$tmpfile" "$SCRIPT_DIR/$1"
			fi
		fi
	elif [ "$1" = "dnsstats_www.js" ]; then
		tmpfile="/tmp/$1"
		Download_File "$SCRIPT_REPO/$1" "$tmpfile"
		if [ -f "$tmpfile" ]; then
			if [ "$(md5sum "$1" 2>/dev/null | awk '{print $1}')" != "$(md5sum "$tmpfile" | awk '{print $1}')" ]; then
				Print_Output true "New version of $1 downloaded" "$PASS"
				mv "$tmpfile" "$SCRIPT_DIR/$1"
			fi
		fi
	elif [ "$1" = "shared-jy.tar.gz" ]; then
		if [ ! -f "$SHARED_DIR/$1.md5" ]; then
			Download_File "$SHARED_REPO/$1" "$SHARED_DIR/$1"
			Download_File "$SHARED_REPO/$1.md5" "$SHARED_DIR/$1.md5"
			tar -xzf "$SHARED_DIR/$1" -C "$SHARED_DIR"
			rm -f "$SHARED_DIR/$1"
			Print_Output true "New version of $1 downloaded" "$PASS"
		else
			localmd5="$(cat "$SHARED_DIR/$1.md5")"
			remotemd5="$(curl -fsL --retry 3 "$SHARED_REPO/$1.md5")"
			if [ "$localmd5" != "$remotemd5" ]; then
				Download_File "$SHARED_REPO/$1" "$SHARED_DIR/$1"
				Download_File "$SHARED_REPO/$1.md5" "$SHARED_DIR/$1.md5"
				tar -xzf "$SHARED_DIR/$1" -C "$SHARED_DIR"
				rm -f "$SHARED_DIR/$1"
				Print_Output true "New version of $1 downloaded" "$PASS"
			fi
		fi
	fi
}

############################################################################

# DNS Configuration Management Functions

Create_Backup(){
	if [ -f "$DNSMASQ_CONF" ]; then
		backupfile="$DNSMASQ_BACKUP_DIR/dnsmasq.conf.add.$(date +%Y%m%d_%H%M%S)"
		mkdir -p "$DNSMASQ_BACKUP_DIR"
		cp "$DNSMASQ_CONF" "$backupfile"
		Print_Output true "Configuration backed up to $backupfile" "$PASS"
		
		# Keep only the last 10 backups
		find "$DNSMASQ_BACKUP_DIR" -name "dnsmasq.conf.add.*" -type f | sort -r | tail -n +11 | xargs rm -f 2>/dev/null
	fi
}

Validate_DNS_Config(){
	configfile="$1"
	if [ ! -f "$configfile" ]; then
		Print_Output true "Configuration file does not exist: $configfile" "$ERR"
		return 1
	fi
	
	# Basic validation - check for valid dnsmasq options
	while IFS= read -r line; do
		line=$(echo "$line" | sed 's/#.*//' | tr -d ' \t')
		[ -z "$line" ] && continue
		
		case "$line" in
			addn-hosts=*)
				path=$(echo "$line" | cut -d'=' -f2)
				if [ ! -f "$path" ] && [ "$path" != "/jffs/configs/hosts" ]; then
					Print_Output true "Warning: Host file does not exist: $path" "$WARN"
				fi
			;;
			dhcp-hostsfile=*)
				path=$(echo "$line" | cut -d'=' -f2)
				if [ ! -f "$path" ]; then
					Print_Output true "Warning: DHCP hosts file does not exist: $path" "$WARN"
				fi
			;;
			log-facility=*)
				path=$(echo "$line" | cut -d'=' -f2)
				dir=$(dirname "$path")
				if [ ! -d "$dir" ]; then
					Print_Output true "Warning: Log directory does not exist: $dir" "$WARN"
				fi
			;;
			log-queries)
				# Valid option
			;;
			*)
				Print_Output true "Warning: Unknown dnsmasq option: $line" "$WARN"
			;;
		esac
	done < "$configfile"
	
	return 0
}

Apply_DNS_Config(){
	configdata="$1"
	
	# Create backup before applying changes
	Create_Backup
	
	# Write new configuration
	echo "$configdata" > "$DNSMASQ_CONF"
	
	# Validate the new configuration
	if Validate_DNS_Config "$DNSMASQ_CONF"; then
		Print_Output true "DNS configuration applied successfully" "$PASS"
		
		# Restart dnsmasq to apply changes
		Print_Output true "Restarting dnsmasq to apply changes..." "$PASS"
		service restart_dnsmasq >/dev/null 2>&1 || {
			Print_Output true "Failed to restart dnsmasq" "$ERR"
			return 1
		}
		
		Print_Output true "dnsmasq restarted successfully" "$PASS"
		return 0
	else
		Print_Output true "Configuration validation failed" "$ERR"
		return 1
	fi
}

Get_DNS_Status(){
	if pidof dnsmasq >/dev/null 2>&1; then
		Print_Output false "dnsmasq is running" "$PASS"
		
		# Show current configuration summary
		if [ -f "$DNSMASQ_CONF" ]; then
			addn_hosts_count=$(grep -c "^addn-hosts=" "$DNSMASQ_CONF" 2>/dev/null || echo "0")
			dhcp_hosts_configured=$(grep -q "^dhcp-hostsfile=" "$DNSMASQ_CONF" && echo "Yes" || echo "No")
			log_queries_enabled=$(grep -q "^log-queries" "$DNSMASQ_CONF" && echo "Yes" || echo "No")
			
			Print_Output false "Additional host files: $addn_hosts_count" ""
			Print_Output false "DHCP hosts file: $dhcp_hosts_configured" ""
			Print_Output false "Query logging: $log_queries_enabled" ""
		fi
	else
		Print_Output false "dnsmasq is not running" "$ERR"
	fi
}

############################################################################

Validate_Number(){
	if [ "$1" -eq "$1" ] 2>/dev/null; then
		return 0
	else
		return 1
	fi
}

Conf_FromSettings(){
	SETTINGSFILE="/jffs/addons/custom_settings.txt"
	tmpfile="/tmp/dnsmerlin_webconfig.tmp"
	
	if [ -f "$SETTINGSFILE" ]; then
		if [ "$(grep -c "dns_config_data" "$SETTINGSFILE")" -gt 0 ]; then
			configdata=$(grep "dns_config_data" "$SETTINGSFILE" | cut -f2- -d' ')
			echo "$configdata" > "$tmpfile"
			
			if Apply_DNS_Config "$configdata"; then
				# Remove the temporary config data from settings file
				sed -i '/dns_config_data/d' "$SETTINGSFILE"
				rm -f "$tmpfile"
				return 0
			else
				rm -f "$tmpfile"
				return 1
			fi
		fi
	fi
	return 1
}

Create_Dirs(){
	if [ ! -d "$SCRIPT_DIR" ]; then
		mkdir -p "$SCRIPT_DIR"
	fi
	
	if [ ! -d "$SCRIPT_WEB_DIR" ]; then
		mkdir -p "$SCRIPT_WEB_DIR"
	fi
	
	if [ ! -d "$SHARED_DIR" ]; then
		mkdir -p "$SHARED_DIR"
	fi
	
	if [ ! -d "$SHARED_WEB_DIR" ]; then
		mkdir -p "$SHARED_WEB_DIR"
	fi
	
	if [ ! -d "$DNSMASQ_BACKUP_DIR" ]; then
		mkdir -p "$DNSMASQ_BACKUP_DIR"
	fi
}

Create_Symlinks(){
	rm -rf "${SCRIPT_WEB_DIR:?}/"* 2>/dev/null
	
	ln -s "$SCRIPT_DIR/dnsstats_www.asp" "$SCRIPT_WEB_DIR/dnsstats_www.asp" 2>/dev/null
	ln -s "$SCRIPT_DIR/dnsstats_www.css" "$SCRIPT_WEB_DIR/dnsstats_www.css" 2>/dev/null  
	ln -s "$SCRIPT_DIR/dnsstats_www.js" "$SCRIPT_WEB_DIR/dnsstats_www.js" 2>/dev/null
	ln -s "$DNSMASQ_CONF" "$SCRIPT_WEB_DIR/dnsmasq.conf.add" 2>/dev/null
	
	if [ ! -d "$SHARED_WEB_DIR" ]; then
		ln -s "$SHARED_DIR" "$SHARED_WEB_DIR" 2>/dev/null
	fi
}

Conf_Exists(){
	if [ ! -f "$DNSMASQ_CONF" ]; then
		Print_Output false "Creating default DNS configuration..." "$PASS"
		cat << 'EOF' > "$DNSMASQ_CONF"
addn-hosts=/jffs/configs/hosts
addn-hosts=/jffs/addons/YazDHCP.d/.hostnames # YazDHCP_hostnames
dhcp-hostsfile=/jffs/addons/YazDHCP.d/.staticlist # YazDHCP_staticlist
#log-queries
#log-facility=/tmp/dnsmasq.log
EOF
	fi
}

Auto_ServiceEvent(){
	case $1 in
		create)
			if [ -f /jffs/scripts/service-event ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/service-event)
				STARTUPLINECOUNTEX=$(grep -cx "/jffs/scripts/$SCRIPT_NAME_LOWER service_event"' "$1" "$2" "$3" & # '"$SCRIPT_NAME" /jffs/scripts/service-event)
				
				if [ "$STARTUPLINECOUNT" -gt 1 ] || { [ "$STARTUPLINECOUNTEX" -eq 0 ] && [ "$STARTUPLINECOUNT" -gt 0 ]; }; then
					sed -i '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/service-event
				fi
				
				if [ "$STARTUPLINECOUNTEX" -eq 0 ]; then
					echo "/jffs/scripts/$SCRIPT_NAME_LOWER service_event"' "$1" "$2" "$3" & # '"$SCRIPT_NAME" >> /jffs/scripts/service-event
				fi
			else
				echo '#!/bin/sh' > /jffs/scripts/service-event
				echo '' >> /jffs/scripts/service-event
				echo "/jffs/scripts/$SCRIPT_NAME_LOWER service_event"' "$1" "$2" "$3" & # '"$SCRIPT_NAME" >> /jffs/scripts/service-event
				chmod 0755 /jffs/scripts/service-event
			fi
		;;
		delete)
			if [ -f /jffs/scripts/service-event ]; then
				sed -i '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/service-event
			fi
		;;
	esac
}

Auto_Startup(){
	case $1 in
		create)
			if [ -f /jffs/scripts/services-start ]; then
				STARTUPLINECOUNT=$(grep -c '# '"$SCRIPT_NAME" /jffs/scripts/services-start)
				
				if [ "$STARTUPLINECOUNT" -gt 0 ]; then
					sed -i '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/services-start
				fi
				
				echo "/jffs/scripts/$SCRIPT_NAME_LOWER startup"' & # '"$SCRIPT_NAME" >> /jffs/scripts/services-start
			else
				echo '#!/bin/sh' > /jffs/scripts/services-start
				echo '' >> /jffs/scripts/services-start
				echo "/jffs/scripts/$SCRIPT_NAME_LOWER startup"' & # '"$SCRIPT_NAME" >> /jffs/scripts/services-start
				chmod 0755 /jffs/scripts/services-start
			fi
		;;
		delete)
			if [ -f /jffs/scripts/services-start ]; then
				sed -i '/# '"$SCRIPT_NAME"'/d' /jffs/scripts/services-start
			fi
		;;
	esac
}

Download_File(){
	/usr/sbin/curl -fsL --retry 3 "$1" -o "$2"
}

Shortcut_Script(){
	case $1 in
		create)
			if [ -d "/opt/bin" ] && [ ! -f "/opt/bin/$SCRIPT_NAME_LOWER" ] && [ -f "/jffs/scripts/$SCRIPT_NAME_LOWER" ]; then
				ln -s "/jffs/scripts/$SCRIPT_NAME_LOWER" /opt/bin
				chmod 0755 "/opt/bin/$SCRIPT_NAME_LOWER"
			fi
		;;
		delete)
			if [ -f "/opt/bin/$SCRIPT_NAME_LOWER" ]; then
				rm -f "/opt/bin/$SCRIPT_NAME_LOWER"
			fi
		;;
	esac
}

PressEnter(){
	while true; do
		printf "Press enter to continue..."
		read -r key
		case "$key" in
			*)
				break
			;;
		esac
	done
	return 0
}

ScriptHeader(){
	clear
	printf "\\n"
	printf "${BOLD}###########################################################${CLEARFORMAT}\\n"
	printf "${BOLD}##                                                       ##${CLEARFORMAT}\\n"  
	printf "${BOLD}##                    %s                      ##${CLEARFORMAT}\\n" "$SCRIPT_NAME"
	printf "${BOLD}##                DNS Configuration Manager             ##${CLEARFORMAT}\\n"
	printf "${BOLD}##                     %s                        ##${CLEARFORMAT}\\n" "$SCRIPT_VERSION"
	printf "${BOLD}##                                                       ##${CLEARFORMAT}\\n"
	printf "${BOLD}###########################################################${CLEARFORMAT}\\n"
	printf "\\n"
}

MainMenu(){
	printf "1.    View DNS Status\\n"
	printf "2.    Edit DNS Configuration\\n"
	printf "3.    View Configuration File\\n"
	printf "4.    Restart dnsmasq\\n"
	printf "5.    Backup Configuration\\n"
	printf "\\n"
	printf "u.    Check for updates\\n"
	printf "uf.   Update %s with --force\\n" "$SCRIPT_NAME"
	printf "\\n"
	printf "e.    Exit %s\\n" "$SCRIPT_NAME"
	printf "\\n"
	printf "${BOLD}################################################${CLEARFORMAT}\\n"
	printf "\\n"
	
	while true; do
		printf "Choose an option:    "
		read -r menu
		case "$menu" in
			1)
				printf "\\n"
				Get_DNS_Status
				PressEnter
				break
			;;
			2)
				printf "\\n"
				Menu_EditConfig
				break
			;;
			3)
				printf "\\n"
				Menu_ViewConfig
				PressEnter
				break
			;;
			4)
				printf "\\n"
				Menu_RestartDNSMasq
				PressEnter
				break
			;;
			5)
				printf "\\n"
				Create_Backup
				PressEnter
				break
			;;
			u)
				printf "\\n"
				Update_Version
				PressEnter
				break
			;;
			uf)
				printf "\\n"
				Update_Version force
				PressEnter
				break
			;;
			e)
				ScriptHeader
				printf "\\n${BOLD}Thanks for using %s!${CLEARFORMAT}\\n\\n\\n" "$SCRIPT_NAME"
				exit 0
			;;
			*)
				printf "\\nPlease choose a valid option\\n\\n"
			;;
		esac
	done
	
	ScriptHeader
	MainMenu
}

Menu_Install(){
	Print_Output true "Welcome to $SCRIPT_NAME $SCRIPT_VERSION, a script by btc08gh" "$PASS"
	sleep 1
	
	Print_Output true "Checking your router meets the requirements for $SCRIPT_NAME" "$PASS"
	
	if ! Firmware_Version_Check; then
		Print_Output true "Unsupported firmware version detected" "$ERR"
		Print_Output true "$SCRIPT_NAME requires Merlin 384.15/384.13_4 or Fork 43E5 (or later)" "$ERR"
		exit 1
	fi
	
	Create_Dirs
	Conf_Exists
	Create_Symlinks
	
	Update_File shared-jy.tar.gz
	Update_File dnsstats_www.asp
	Update_File dnsstats_www.css
	Update_File dnsstats_www.js
	
	Auto_Startup create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_Script create
	
	Set_Version_Custom_Settings local "$SCRIPT_VERSION"
	Set_Version_Custom_Settings server "$SCRIPT_VERSION"
	
	Print_Output true "Installation of $SCRIPT_NAME completed" "$PASS"
	Print_Output true "Access the WebUI via Addons -> $SCRIPT_NAME" "$PASS"
	Print_Output true "Run $SCRIPT_NAME_LOWER from command line for CLI options" "$PASS"
	Clear_Lock
}

Menu_EditConfig(){
	if [ ! -f "$DNSMASQ_CONF" ]; then
		Print_Output true "Configuration file does not exist, creating default..." "$WARN"
		Conf_Exists
	fi
	
	printf "Edit DNS Configuration:\\n\\n"
	printf "1.    Edit with nano\\n"
	printf "2.    Edit with vi\\n"
	printf "\\n"
	printf "e.    Exit to main menu\\n"
	printf "\\n"
	
	while true; do
		printf "Choose an option:    "
		read -r editor
		case "$editor" in
			1)
				Create_Backup
				nano "$DNSMASQ_CONF"
				if Validate_DNS_Config "$DNSMASQ_CONF"; then
					Print_Output true "Configuration file updated" "$PASS"
					Print_Output true "Restarting dnsmasq..." "$PASS"
					service restart_dnsmasq
				else
					Print_Output true "Configuration validation failed" "$ERR"
				fi
				break
			;;
			2)
				Create_Backup
				vi "$DNSMASQ_CONF"
				if Validate_DNS_Config "$DNSMASQ_CONF"; then
					Print_Output true "Configuration file updated" "$PASS"
					Print_Output true "Restarting dnsmasq..." "$PASS"
					service restart_dnsmasq
				else
					Print_Output true "Configuration validation failed" "$ERR"
				fi
				break
			;;
			e)
				break
			;;
			*)
				printf "\\nPlease choose a valid option\\n\\n"
			;;
		esac
	done
}

Menu_ViewConfig(){
	if [ -f "$DNSMASQ_CONF" ]; then
		Print_Output false "Current DNS Configuration:" "$SETTING"
		printf "\\n"
		cat "$DNSMASQ_CONF"
		printf "\\n"
	else
		Print_Output true "Configuration file does not exist" "$ERR"
	fi
}

Menu_RestartDNSMasq(){
	Print_Output true "Restarting dnsmasq..." "$PASS"
	service restart_dnsmasq && {
		Print_Output true "dnsmasq restarted successfully" "$PASS"
	} || {
		Print_Output true "Failed to restart dnsmasq" "$ERR"
	}
}

Menu_Startup(){
	# Allow time for DNS services to initialize
	sleep 5
	Get_DNS_Status
}

Menu_Uninstall(){
	printf "\\n${BOLD}This will uninstall %s from your router${CLEARFORMAT}\\n" "$SCRIPT_NAME"
	printf "\\n${BOLD}Do you want to continue? (y/n)${CLEARFORMAT}  "
	read -r confirm
	case "$confirm" in
		y|Y)
			Auto_Startup delete 2>/dev/null
			Auto_ServiceEvent delete 2>/dev/null
			Shortcut_Script delete
			rm -rf "$SCRIPT_DIR" 2>/dev/null
			rm -rf "$SCRIPT_WEB_DIR" 2>/dev/null
			rm -f "/jffs/scripts/$SCRIPT_NAME_LOWER" 2>/dev/null
			Print_Output true "Uninstall completed" "$PASS"
			Clear_Lock
			exit 0
		;;
		*)
			printf "\\n"
			Clear_Lock
		;;
	esac
}

Show_About(){
	cat << 'EOF'
About dnsMerlin
  dnsMerlin provides a web interface for managing dnsmasq configuration
  on AsusWRT Merlin firmware. It allows you to easily configure:
  
  - Additional host files (addn-hosts)
  - DHCP static host assignments (dhcp-hostsfile)  
  - DNS query logging options
  
  Configuration changes are applied immediately with automatic
  dnsmasq service restart.

EOF
}

Show_Help(){
	cat << 'EOF'
Available commands:
  install             Install dnsMerlin
  startup             Called by services-start
  uninstall          Uninstall dnsMerlin
  update             Check for updates  
  forceupdate        Update without prompting
  about              About dnsMerlin
  help               Show this help

EOF
}

if [ -z "$1" ]; then
	Create_Dirs
	Conf_Exists  
	Create_Symlinks
	Auto_Startup create 2>/dev/null
	Auto_ServiceEvent create 2>/dev/null
	Shortcut_Script create
	Set_Version_Custom_Settings local "$SCRIPT_VERSION"
	ScriptHeader
	MainMenu
	exit 0
fi

case "$1" in
	install)
		Check_Lock
		Menu_Install
		exit 0
	;;
	startup)
		Menu_Startup "$2"
		exit 0
	;;
	service_event)
		if [ "$2" = "start" ] && [ "$3" = "${SCRIPT_NAME_LOWER}config" ]; then
			Conf_FromSettings
			exit 0
		elif [ "$2" = "start" ] && [ "$3" = "${SCRIPT_NAME_LOWER}checkupdate" ]; then
			Update_Check
			exit 0
		elif [ "$2" = "start" ] && [ "$3" = "${SCRIPT_NAME_LOWER}doupdate" ]; then
			Update_Version force unattended
			exit 0
		fi
		exit 0
	;;
	update)
		Update_Version
		exit 0
	;;
	forceupdate)
		Update_Version force
		exit 0
	;;
	postupdate)
		Create_Dirs
		Conf_Exists
		Create_Symlinks  
		Auto_Startup create 2>/dev/null
		Auto_ServiceEvent create 2>/dev/null
		Shortcut_Script create
		Set_Version_Custom_Settings local "$SCRIPT_VERSION"
	;;
	checkupdate)
		Update_Check
		exit 0
	;;
	uninstall)
		Menu_Uninstall
		exit 0
	;;
	about)
		ScriptHeader
		Show_About
		exit 0
	;;
	help)
		ScriptHeader
		Show_Help
		exit 0
	;;
	*)
		ScriptHeader
		Print_Output false "Command not recognised." "$ERR"
		Print_Output false "For a list of available commands run: $SCRIPT_NAME_LOWER help" ""
		exit 1
	;;
esac