FROM sirrkitt/openldap-build-argon2 AS argon2
FROM alpine:3.11
LABEL maintainer="Jacob Lemus Peschel <jacob@tlacuache.us>"
ENV BASEDN="dc=example,dc=org"
ENV ROOTDN="root"
ENV ROOTPW="secret"
ENV PWHASH="{ARGON2}"
ENV ENCROOTPW="NULL"
ENV SSL="NOPE"
ENV INIT="NO"
ENV MAXDBSIZE="1073741824"

COPY entrypoint.sh /entrypoint.sh

RUN	echo "@edge http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories &&\
	apk update --no-cache && \
	apk add -U --no-cache openldap@edge openldap-back-mdb@edge openldap-overlay-all@edge openldap-passwd-pbkdf2@edge openldap-passwd-sha2@edge argon2 libsodium-dev gettext && \
	mkdir -p /config /data /ssl /run/openldap /socket && \
	chown -R ldap:ldap /config /data /run/openldap /socket && \
	chown -R root:root /ssl && \
	chmod -R 0700 /config /data /ssl /socket &&\
	chmod a+x /entrypoint.sh

COPY slapd.gen	/etc/openldap/slapd.gen
COPY db.gen	/etc/openldap/db.gen

COPY --from=argon2 /usr/libexec/openldap/pw-argon2.a /usr/lib/openldap/pw-argon2.a
COPY --from=argon2 /usr/libexec/openldap/pw-argon2.la /usr/lib/openldap/pw-argon2.la
COPY --from=argon2 /usr/libexec/openldap/pw-argon2.so.0.0.0 /usr/lib/openldap/pw-argon2.so.0.0.0

RUN ln -s /usr/lib/openldap/pw-argon2.so.0.0.0 /usr/lib/openldap/pw-argon2.so.0 &&\
		ln -s /usr/lib/openldap/pw-argon2.so.0 /usr/lib/openldap/pw-argon2.so

EXPOSE 389
EXPOSE 636

VOLUME ["/config", "/data", "/ssl", "/socket"]

ENTRYPOINT ["/entrypoint.sh"]
