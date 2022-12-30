#!/bin/bash

if ! salt-master --versions-report |  grep -E 'pygit2: [0-9\.]+$'; then
	echo "CHECK FAILED (salt-master): Support for pygit2 missing?"
	echo "= = = OUTPUT = = ="
	salt-master --versions-report
	echo "= = = OUTPUT = = ="
	false
fi

for i in `seq 1 30`; do
	if [ -e /etc/salt/pki/master/minions_pre/test.local ]; then
		echo "TESTS: Minion is READY!"
		break
	fi
	echo "TESTS: Waiting for master to get minion connection... $i"
	sleep 1
done

echo "TEST: Accepting salt-minion key"
echo y | salt-key -a test.local

echo "TESTS: Testing salt-minion ping"
if ! salt-call test.ping; then
	echo "CHECK FAILED (salt-master): Failed to ping master from minion"
	false
fi

echo "TESTS: Testing salt-minion grains"
if ! salt-call grains.items > salt.grains 2>&1; then
	echo "CHECK FAILED (salt-master): Failed to get grains on minion"
	echo "= = = OUTPUT salt.grains = = ="
	cat salt.grains
	echo "= = = OUTPUT salt.grains = = ="
	false
fi

echo "TESTS: Testing salt-minion show_top"
if ! salt-call state.show_top > salt.show_top 2>&1; then
	echo "CHECK FAILED (salt-master): Failed to run show_top on minion"
	echo "= = = OUTPUT salt.show_top = = ="
	cat salt.show_top
	echo "= = = OUTPUT salt.show_top = = ="
	false
fi

echo "TESTS: Testing salt-minion apply"
salt-call state.apply -l info

echo "TESTS: Testing the file created has the right contents"
if ! grep 'hello world' /root/test.file 2>&1; then
	echo "CHECK FAILED (salt-master): Failed to test file exists which should of been created"
	false
fi

