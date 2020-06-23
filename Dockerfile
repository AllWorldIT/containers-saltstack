FROM registry.gitlab.iitsp.com/allworldit/docker/alpine/v3.12:latest

ARG VERSION_INFO
LABEL maintainer="Nigel Kukard <nkukard@LBSD.net>"

ENV SALT_VERSION=3001

RUN set -ex; \
	true "Salt dependencies"; \
	# Install salt
	apk add --no-cache \
			py3-pip \
			py3-setuptools \
			py3-distro \
			py3-pygit2 \
			py3-dateutil \
			py3-urllib3 \
			py3-jinja2 \
			py3-msgpack \
			py3-yaml \
			py3-certifi \
			py3-chardet \
			py3-idna \
			py3-requests \
			py3-pyzmq \
			py3-crypto \
			gmp \
# Cherrypy
			py3-tz \
			py3-more-itertools \
			py3-pycryptodome \
			; \
	apk add --no-cache --virtual .build-deps \
			build-base \
			python3-dev \
			linux-headers \
			py3-setuptools \
			py3-six \
			; \
	true "Salt pip dependencies"; \
	pip3 install --upgrade pip; \
	pip3 install wheel; \
	pip3 install cherrypy wheel; \
	true "Salt build"; \
	wget "https://pypi.io/packages/source/s/salt/salt-${SALT_VERSION}.tar.gz"; \
	tar -zxf "salt-${SALT_VERSION}.tar.gz"; \
	cd "salt-${SALT_VERSION}"; \
	python3 setup.py build; \
	python3 setup.py --salt-pidfile-dir="/run/salt" install --optimize=1 --skip-build; \
	cd ..; \
	rm -rf "salt-${SALT_VERSION}"; \
	rm -f "salt-${SALT_VERSION}.tar.gz"; \
	true "Groups"; \
	addgroup -g 141 -S salt; \
	true "Users"; \
	adduser -u 141 -D -S -H -h / -G salt salt; \
	true "Versioning"; \
	if [ -n "$VERSION_INFO" ]; then echo "$VERSION_INFO" >> /.VERSION_INFO; fi; \
	true "Cleanup"; \
	rm -rf /root/.cache; \
	apk del --no-network .build-deps; \
	rm -f /var/cache/apk/*


# Salt
COPY etc/salt/master /etc/salt/master
COPY etc/salt/master.d/50-blank /etc/salt/master.d/50-blank
COPY etc/supervisor/conf.d/salt-master.conf /etc/supervisor/conf.d/salt-master.conf
COPY init.d/50-salt-master.sh /docker-entrypoint-init.d/50-salt-master.sh
COPY pre-init-tests.d/50-salt-master.sh /docker-entrypoint-pre-init-tests.d/50-salt-master.sh
COPY tests.d/50-salt-master.sh /docker-entrypoint-tests.d/50-salt-master.sh
RUN set -eux; \
		chown root:root \
			/etc/supervisor/conf.d/salt-master.conf \
			/docker-entrypoint-init.d/50-salt-master.sh \
			/docker-entrypoint-tests.d/50-salt-master.sh \
			/docker-entrypoint-pre-init-tests.d/50-salt-master.sh; \
		chmod 0644 \
			/etc/supervisor/conf.d/salt-master.conf; \
		chmod 0755 \
			/docker-entrypoint-init.d/50-salt-master.sh \
			/docker-entrypoint-tests.d/50-salt-master.sh \
			/docker-entrypoint-pre-init-tests.d/50-salt-master.sh; \
		chown root:salt \
			/etc/salt/master; \
		chmod 0640 \
			/etc/salt/master

EXPOSE 4505 4506

VOLUME ["/etc/salt/pki"]
VOLUME ["/var/cache/salt"]
VOLUME ["/srv"]

# Health check
#HEALTHCHECK CMD salt-run manage.alived

