FROM sirrkitt/openldap-builder AS builder
FROM alpine:3.12
LABEL maintainer="Jacob Lemus Peschel <jacob@tlacuache.us>"
ENV SSL="NOPE"
ENV DEBUG="NOPE"
ENV INIT="NOPE"

COPY entrypoint.sh /entrypoint.sh
COPY slapd.conf slapd.conf

COPY --from=builder /home/builder/packages/usr/x86_64/openldap*.apk /root/

RUN	apk update --no-cache && \
	apk add -U --no-cache libsasl libuuid libltdl libsodium libcrypto1.1 libssl1.1 && \
	apk add --allow-untrusted /root/openldap*.apk && \
	mkdir -p /config /data /ssl /run/openldap /socket && \
	slaptest -f /slapd.conf -F /config -n 0 &&\
	chown -R ldap:ldap /config /data /run/openldap /socket && \
	chown -R root:root /ssl && \
	chmod -R 0700 /config /data /ssl /socket &&\
	chmod a+x /entrypoint.sh

EXPOSE 389
EXPOSE 636

VOLUME ["/config", "/data", "/ssl", "/socket"]

ENTRYPOINT ["/entrypoint.sh"]
