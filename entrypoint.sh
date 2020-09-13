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

chown -R ldap:ldap /data /config /ssl

if [ ! "$DEBUG" == "NOPE" ]
then
	if [ ! "$SSL" == "NOPE" ]
	then
		exec /usr/sbin/slapd -u ldap -g ldap -f /config/slapd.conf -h "ldap:/// ldapi://%2Fsocket%2Fldapi" -d 255
	else
		exec /usr/sbin/slapd -u ldap -g ldap -f /config/slapd.conf -h "ldap:/// ldaps:/// ldapi://%2Fsocket%2Fldapi" -d 255
	fi
else
	if [ ! "$SSL" == "NOPE" ]
	then
		exec /usr/sbin/slapd -u ldap -g ldap -f /config/slapd.conf -h "ldap:/// ldapi://%2Fsocket%2Fldapi"
	else
		exec /usr/sbin/slapd -u ldap -g ldap -f /config/slapd.conf -h "ldap:/// ldaps:/// ldapi://%2Fsocket%2Fldapi" 
	fi
fi
