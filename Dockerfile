FROM sirrkitt/openldap-builder AS builder
FROM alpine:3.12
LABEL maintainer="Jacob Lemus Peschel <jacob@tlacuache.us>"
ENV SSL="NOPE"

COPY entrypoint.sh /entrypoint.sh
COPY --from=builder /home/builder/packages/usr/x86_64/openldap*.apk /root/openldap.apk

RUN	apk update --no-cache && \
	apk add -U --no-cache libsasl libuuid libltdl libldap libsodium libcrypto1.1 libssl1.1 && \
	apk add --allow-untrusted /root/openldap.apk && \
	mkdir -p /config /data /ssl /run/openldap /socket && \
	addgroup --system ldap && \
	adduser --system --ingroup ldap --disabled-password --no-create-home ldap && \
	chown -R ldap:ldap /config /data /run/openldap /socket && \
	chown -R root:root /ssl && \
	chmod -R 0700 /config /data /ssl /socket &&\
	chmod a+x /entrypoint.sh

EXPOSE 389
EXPOSE 636

VOLUME ["/config", "/data", "/ssl", "/socket"]

ENTRYPOINT ["/entrypoint.sh"]
