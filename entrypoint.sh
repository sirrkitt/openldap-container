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
fi

addgroup -S -g $GID ldap
adduser -S -H -h /data -G ldap -g ldap -u $UID -s /sbin/nologin ldap

chown -R ldap:ldap /data /config /ssl /run/openldap /socket
chmod -R 0700 /config /data /ssl /socket

if [ "$CONFIG" == "OLD" ]
then
	if [ "$NET" == "NOPE" ]
	then
		exec /usr/lib/slapd -u ldap -g ldap -f /config/slapd.conf -h "ldapi://%2Fsocket%2Fldapi" -d $debug
	else
		if [ "$SSL" == "NOPE" ]
		then
			exec /usr/lib/slapd -u ldap -g ldap -f /config/slapd.conf -h "ldap:/// ldapi://%2Fsocket%2Fldapi" -d $debug
		else
			exec /usr/lib/slapd -u ldap -g ldap -f /config/slapd.conf -h "ldap:/// ldaps:/// ldapi://%2Fsocket%2Fldapi" -d $debug
		fi
	fi
fi

if [ "$NET" == "NOPE" ]
then
	exec /usr/lib/slapd -u ldap -g ldap -F /config/slapd.d -h "ldapi://%2Fsocket%2Fldapi" -d $debug
else
		if [ "$SSL" == "NOPE" ]
		then
			exec /usr/lib/slapd -u ldap -g ldap -F /config/slapd.d -h "ldap:/// ldapi://%2Fsocket%2Fldapi" -d $debug
		else
			exec /usr/lib/slapd -u ldap -g ldap -F /config/slapd.d -h "ldap:/// ldaps:/// ldapi://%2Fsocket%2Fldapi" -d $debug
		fi
	fi
fi
