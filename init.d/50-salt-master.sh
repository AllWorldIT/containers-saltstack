#!/bin/sh

# Create salt data directories
if [ ! -d /srv/salt ]; then
	echo "NOTICE: Creating /srv/salt"
	mkdir /srv/salt
fi
if [ ! -d /srv/salt-master ]; then
	echo "NOTICE: Creating /srv/salt-master"
	mkdir /srv/salt-master
fi
if [ ! -d /srv/pillar ]; then
	echo "NOTICE: Creating /srv/pillar"
	mkdir /srv/pillar
fi
if [ ! -d /var/cache/salt ]; then
	echo "NOTICE: Creating /var/cache/salt"
	mkdir /var/cache/salt
fi
if [ ! -d /var/cache/salt/master ]; then
	echo "NOTICE: Creating /var/cache/salt/master"
	mkdir /var/cache/salt/master
fi

# Make sure perms are set correctly
chown root:salt -R /etc/salt/pki
chmod 0770 /etc/salt/pki
if [ -d /etc/salt/pki/master ]; then
	chown -R salt:salt /etc/salt/pki/master
fi

# If we have a gitfs dir, we need to set perms there too
if [ -d /etc/salt/gitfs ]; then
	chown -R root:salt /etc/salt/gitfs
	chmod 0750 /etc/salt/gitfs
	find /etc/salt/gitfs -type f -print0 | xargs -0 -r chmod 0640
fi

chown -R root:salt /etc/salt/master.d
chmod 0750 /etc/salt/master.d
find /etc/salt/master.d -type f -print0 | xargs -0 -r chmod 0640

chown root:salt /var/cache/salt/master
chmod 0770 /var/cache/salt/master

find /var/cache/salt/master -mindepth 1 ! -name .root_key ! -name .salt_key -print0 | xargs -0 -r chown salt:salt
if [ -e /var/cache/salt/master/.root_key ]; then
	chown root:root /var/cache/salt/master/.root_key
	chmod 0600 /var/cache/salt/master/.root_key
fi
if [ -e /var/cache/salt/master/.salt_key ]; then
	chown salt:root /var/cache/salt/master/.salt_key
	chmod 0600 /var/cache/salt/master/.salt_key
fi

chown root:salt -R /srv/{pillar,salt,salt-master}
find /srv/{pillar,salt,salt-master} -type d -print0 | xargs -0 -r chmod 0750
find /srv/{pillar,salt,salt-master} -type f -print0 | xargs -0 -r chmod 0640

