#!/bin/sh
# make sure we can write to config
if [ ! -w "/config/" ]
then
	echo "Unable to read or write config directory!"
	return 1

# make sure we can write to data
elif [ ! -w "/data" ]
then
	echo "Unable to read or write data directory!"
	return 1

#if config database doesn't exist then create
elif [ "$INIT" == "YES" ]
then
	if [ ! -e /config/cn\=config ] && [ ! -e /config/cn\=config.ldif ] && [ ! -e /data/data.mdb ] && [ ! -e /data/data.lock ] && [ ! -e /config/slapd.conf ]
	then
		echo "Generating config database!"
		#database dn
		echo "Setting basedn to $BASEDN"
		echo "Setting rootdn to cn=$ROOTDN,$BASEDN"
		echo "Selected password hash is $PWHASH"
		#check if pass hash set for root password
		if [ "$PWHASH" == "{MD5}" ] || [ "$PWHASH" == "{SMD5}" ] || [ "$PWHASH" == "{SSHA}" ] || [ "$PWHASH" == "{SHA}" ] || [ "$PWHASH" == "{CLEARTEXT}" ] || [ "$PWHASH" == "{PBKDF2}" ] || [ "$PWHASH" == "{PBKDF2-SHA1}" ] || [ "$PWHASH" == "{PBKDF2-SHA256}" ] || [ "$PWHASH" == "{PBKDF-SHA512}" ] || [ "$PWHASH" == "{SHA256}" ] || [ "$PWHASH" == "{SSHA256}" ] || [ "$PWHASH" == "{SHA384}" ] || [ "$PWHASH" == "{SSHA384}" ] || [ "$PWHASH" == "{SHA512}" ] || [ "$PWHASH" == "{SSHA512}" ] || [ "$PWHASH" == "{ARGON2}" ]
		then
			echo "Valid password hash selected"
			ENCROOTPW="$(/usr/sbin/slappasswd -o module-load=pw-sha2 -o module-load=pw-argon2 -s "$ROOTPW" -h "$PWHASH" -n)"
		else
			echo "Invalid password hash selected, try again!"
			return 1
		fi
		#Create config
		echo "Generating config LDIF"
		/bin/cat /etc/openldap/slapd.gen|/usr/bin/envsubst>/config/slapd.conf
		#copy config and fix permissions
		echo "Generating ldif for initial DB"
		/bin/cat /etc/openldap/db.gen|/usr/bin/envsubst>/etc/openldap/db.ldif
		echo "Applying ldif"
		/usr/sbin/slapadd -f /config/slapd.conf -l /etc/openldap/db.ldif -n1
		echo "Applying proper permissions to everything"
		/bin/chown -R ldap:ldap /config /ssl /data
		echo "Init complete!"
		return 0
	fi

	if [ -e /config/cn\=config.ldif ] || [ -e /config/cn\=config ] || [ -e /config/slapd.conf ]
	then
		echo "Config already exists! Unable to perform init"
	fi
	if [ -e /data/data.mdb ] || [ -e /data/data.lock ]
	then
		echo "Database already exists unable to perform init!"
	fi
	#fail because we can't init
	return 1
fi
#if SSL option is set then listen on LDAPS as well
if [ ! "$SSL" == "NOPE" ]
then
	echo "Starting slapd and listening on SSL"
	exec /usr/sbin/slapd -u ldap -g ldap -f /config/slapd.conf -h "ldap:/// ldaps:///" -d 0
else
	echo "Starting slapd"
	exec /usr/sbin/slapd -u ldap -g ldap -f /config/slapd.conf -h "ldap:///" -d 0
fi
