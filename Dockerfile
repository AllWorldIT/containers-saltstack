# Copyright (c) 2022-2023, AllWorldIT.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.


FROM registry.conarx.tech/containers/alpine/3.19


ARG VERSION_INFO=
LABEL org.opencontainers.image.authors   "Nigel Kukard <nkukard@conarx.tech>"
LABEL org.opencontainers.image.version   "3.19"
LABEL org.opencontainers.image.base.name "registry.conarx.tech/containers/alpine/3.19"


ENV SALTSTACK_VER=3006.5


RUN set -eux; \
	true "Salt dependencies"; \
	# Install salt
	apk add --no-cache \
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
		py3-cherrypy \
		py3-idna \
		py3-requests \
		py3-pyzmq \
		py3-crypto \
		py3-wheel \
		gmp \
		; \
	apk add --no-cache --virtual .build-deps \
		build-base \
		python3-dev \
		linux-headers \
		py3-setuptools \
		py3-six \
# Remove when ZeroMQ >22 is supported by salt
		zeromq-dev \
		; \
	true "Salt build"; \
	wget "https://pypi.io/packages/source/s/salt/salt-${SALTSTACK_VER}.tar.gz"; \
	# NK: Touch files as the tar.gz has 1980 dates, which breaks setup.py build
	tar -zxmf "salt-${SALTSTACK_VER}.tar.gz"; \
	cd "salt-${SALTSTACK_VER}"; \
	# remove version requirements for pyzmq, there's no point in it
	# we only have one version and the "python_version <=> *" checks are discarded
	# so pyzmq<=20.0.0 ends up in the final requirements.txt
	echo -e '-r crypto.txt\n\npyzmq' > requirements/zeromq.txt; \
	# Patch for python 3.10
	# wget -O- https://patch-diff.githubusercontent.com/raw/saltstack/salt/pull/61064.patch | patch -p1;
	# Build and install
	python3 setup.py build; \
	python3 setup.py --salt-pidfile-dir="/run/salt" install --optimize=1 --skip-build; \
	cd ..; \
	rm -rf "salt-${SALTSTACK_VER}"; \
	rm -f "salt-${SALTSTACK_VER}.tar.gz"; \
	true "Groups"; \
	addgroup -g 141 -S salt; \
	true "Users"; \
	adduser -u 141 -D -S -H -h /srv -G salt salt; \
	true "Cleanup"; \
	rm -rf /root/.cache; \
	apk del --no-network .build-deps; \
	rm -f /var/cache/apk/*


# Salt
COPY etc/salt/master /etc/salt/master
COPY etc/salt/master.d/50-blank /etc/salt/master.d/50-blank
COPY etc/supervisor/conf.d/salt-master.conf /etc/supervisor/conf.d/salt-master.conf
COPY usr/local/share/flexible-docker-containers/init.d/42-salt-master.sh /usr/local/share/flexible-docker-containers/init.d
COPY usr/local/share/flexible-docker-containers/pre-init-tests.d/42-salt-master.sh /usr/local/share/flexible-docker-containers/pre-init-tests.d
COPY usr/local/share/flexible-docker-containers/healthcheck.d/42-salt-master.sh /usr/local/share/flexible-docker-containers/healthcheck.d
COPY usr/local/share/flexible-docker-containers/tests.d/42-salt-master.sh /usr/local/share/flexible-docker-containers/tests.d
RUN set -eux; \
	true "Flexible Docker Containers"; \
	if [ -n "$VERSION_INFO" ]; then echo "$VERSION_INFO" >> /.VERSION_INFO; fi; \
	mkdir -p /var/log/salt; \
	chown root:salt \
		/etc/salt/master \
		/etc/salt/master.d \
		/etc/salt/master.d/50-blank; \
	chmod 0640 \
		/etc/salt/master \
		/etc/salt/master.d/50-blank; \
	fdc set-perms


VOLUME ["/etc/salt/pki"]
VOLUME ["/var/cache/salt"]
VOLUME ["/srv"]


EXPOSE 4505 4506
