#!/bin/sh

# Create salt data directories
if [ ! -d /srv/salt ]; then
	echo "NOTICE: Creating /srv/salt"
	mkdir /srv/salt
	chown root:salt /srv/salt
fi
if [ ! -d /srv/salt-master ]; then
	echo "NOTICE: Creating /srv/salt-master"
	mkdir /srv/salt-master
	chown root:salt /srv/salt-master
fi
if [ ! -d /srv/pillar ]; then
	echo "NOTICE: Creating /srv/pillar"
	mkdir /srv/pillar
fi
if [ ! -d /var/cache/salt ]; then
	echo "NOTICE: Creating /var/cache/salt"
	mkdir /var/cache/salt
	chown root:salt /var/cache/salt
	chmod 0770 /var/cache/salt
fi
if [ ! -d /var/cache/salt/master ]; then
	echo "NOTICE: Creating /var/cache/salt/master"
	mkdir /var/cache/salt/master
	chown root:salt /var/cache/salt
	chmod 0770 /var/cache/salt
fi

