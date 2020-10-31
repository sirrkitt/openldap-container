FROM alpine:3.12 as builder
LABEL maintainer="Jacob Lemus Peschel <jacob@tlacuache.us>"
ENV VER="2.4.55"

WORKDIR /usr/src
ADD	https://www.openldap.org/software/download/OpenLDAP/openldap-release/openldap-2.4.55.tgz .
ADD	https://git.alpinelinux.org/aports/plain/main/openldap/openldap-2.4-ppolicy.patch .
ADD	https://git.alpinelinux.org/aports/plain/main/openldap/openldap-2.4.11-libldap_r.patch .

RUN	tar -xvzf openldap-$VER.tgz
WORKDIR /usr/src/openldap-$VER

RUN	apk update --no-cache && apk add -U --no-cache \
		build-base cyrus-sasl-dev openssl-dev util-linux-dev autoconf automake db-dev groff libtool unixodbc-dev  libsodium-dev && \
		#alpine-sdk cyrus-sasl-dev util-linux-dev autoconf automake db-dev groff \
		#libtool unixodbc-dev libsodium-dev openssl-dev && \
		patch -s -p1 < ../openldap-2.4-ppolicy.patch && \
		patch -s -p1 < ../openldap-2.4.11-libldap_r.patch && \
		sed -i '/^STRIP/s,-s,,g' build/top.mk && \
		libtoolize --force && \
		aclocal && \
		autoconf && \
		./configure \
			--build=$CBUILD \
			--host=$CHOST \
			--prefix=/usr \
			--libexecdir=/usr/lib \
			--sysconfdir=/etc \
			--localstatedir=/data \
			--enable-slapd \
			--enable-crypt \
			--enable-spasswd \
			--enable-modules \
			--enable-dynamic \
			--enable-bdb=mod \
			--enable-dnssrv=mod \
			--enable-hdb=mod \
			--enable-ldap=mod \
			--enable-mdb=mod \
			--enable-meta=mod \
			--enable-monitor=mod \
			--enable-null=mod \
			--enable-passwd=mod \
			--enable-relay=mod \
			--enable-shell=mod \
			--enable-sock=mod \
			--enable-sql=mod \
			--enable-overlays=mod \
			--with-tls=openssl \
			--with-cyrus-sasl \
			--enable-rlookups \
			--with-mp \
			--enable-debug \
			--enable-dynacl \
			--enable-aci \
			--disable-ndb \
			--without-man \
			--without-syslog && \
		make -j8 && \

		make prefix=/usr libexecdir=/usr/lib \
			-C contrib/slapd-modules/passwd/pbkdf2 && \
		make prefix=/usr libexecdir=/usr/lib \
			-C contrib/slapd-modules/passwd/sha2 && \
		make prefix=/usr libexecdir=/usr/lib \
			-C contrib/slapd-modules/passwd/argon2 && \
		make prefix=/usr libexecdir=/usr/lib \
			-C contrib/slapd-modules/lastbind && \
		make prefix=/usr libexecdir=/usr/lib \
			-C contrib/slapd-modules/lastmod && \
		make prefix=/usr libexecdir=/usr/lib \
			-C contrib/slapd-modules/autogroup && \

		make DESTDIR=/opt install && \

		make DESTDIR=/opt prefix=/usr libexecdir=/usr/lib \
			-C contrib/slapd-modules/passwd/pbkdf2 install && \
		make DESTDIR=/opt prefix=/usr libexecdir=/usr/lib \
			-C contrib/slapd-modules/passwd/sha2 install && \
		make DESTDIR=/opt prefix=/usr libexecdir=/usr/lib \
			-C contrib/slapd-modules/passwd/argon2 install && \
		make DESTDIR=/opt prefix=/usr libexecdir=/usr/lib \
			-C contrib/slapd-modules/lastbind install && \
		make DESTDIR=/opt prefix=/usr libexecdir=/usr/lib \
			-C contrib/slapd-modules/lastmod install && \
		make DESTDIR=/opt prefix=/usr libexecdir=/usr/lib \
			-C contrib/slapd-modules/autogroup install

FROM alpine:3.12 as final

ENV NET="SURE"
ENV CONFIG="NEW"
ENV SSL="NOPE"
ENV DEBUG="1"
ENV UID="500"
ENV GID="500"

COPY --from=builder /opt /
COPY entrypoint.sh /entrypoint.sh
COPY slapd.conf slapd.conf


RUN	apk update --no-cache && \
	apk add -U --no-cache openssl libsasl libuuid libltdl libsodium libcrypto1.1 libssl1.1 ca-certificates shadow && \
	chmod a+x /entrypoint.sh

EXPOSE 389
EXPOSE 636

VOLUME ["/config", "/data", "/ssl", "/socket"]

ENTRYPOINT ["/entrypoint.sh"]
