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

if [ ! "INIT" == "NOPE" ]
then
	if [ ! "$(ls -A $DIR)" ]
		echo "Existing config, cannot init new config"
		return 1
	else
		/usr/sbin/slaptest -f /slapd.conf -F /config -n0
		chown -R ldap:ldap /config
fi

fi
if [ ! "$DEBUG" == "NOPE" ]
then
	if [ ! "$SSL" == "NOPE" ]
	then
		exec /usr/sbin/slapd -u ldap -g ldap -F /config -h "ldap:/// ldapi://%2Fsocket%2Fldapi" -d 255
	else
		exec /usr/sbin/slapd -u ldap -g ldap -F /config -h "ldap:/// ldaps:/// ldapi://%2Fsocket%2Fldapi" -d 255
	fi
else
	if [ ! "$SSL" == "NOPE" ]
	then
		exec /usr/sbin/slapd -u ldap -g ldap -F /config -h "ldap:/// ldapi://%2Fsocket%2Fldapi" -d 0
	else
		exec /usr/sbin/slapd -u ldap -g ldap -F /config -h "ldap:/// ldaps:/// ldapi://%2Fsocket%2Fldapi" -d 0
	fi
fi
