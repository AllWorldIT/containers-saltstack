#!/bin/bash
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


# Create salt data directories
if [ ! -d /srv/salt ]; then
	fdc_notice "Creating Saltstack /srv/salt"
	mkdir /srv/salt
	chown root:salt /srv/salt
fi

if [ ! -d /srv/salt-master ]; then
	fdc_notice "Creating Saltstack /srv/salt-master"
	mkdir /srv/salt-master
	chown root:salt /srv/salt-master
fi

if [ ! -d /srv/pillar ]; then
	fdc_notice "Creating Saltstack /srv/pillar"
	mkdir /srv/pillar
fi

if [ ! -d /var/cache/salt ]; then
	fdc_notice "Creating Saltstack /var/cache/salt"
	mkdir /var/cache/salt
	chown root:salt /var/cache/salt
	chmod 0770 /var/cache/salt
fi

if [ ! -d /var/cache/salt/master ]; then
	fdc_notice "Creating Saltstack /var/cache/salt/master"
	mkdir /var/cache/salt/master
	chown root:salt /var/cache/salt
	chmod 0770 /var/cache/salt
fi
