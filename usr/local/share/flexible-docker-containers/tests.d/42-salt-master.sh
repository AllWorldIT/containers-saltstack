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


fdc_test_start saltstack "Checking pygit2 is supported"
if ! salt-master --versions-report |  grep -E 'pygit2: [0-9\.]+$'; then
	fdc_test_fail saltstack "Saltstack support for pygit2 missing?"
	false
fi
fdc_test_pass saltstack "Saltstack supports pygit2"


fdc_test_start saltstack "Waiting for salt-minion..."
for i in $(seq 1 30); do
	if [ -e /etc/salt/pki/master/minions_pre/test.local ]; then
		break
	fi
	fdc_test_progress saltstack "Waiting for salt-master to get salt-minion connection... $i"
	sleep 1
done
fdc_test_pass saltstack "Minion is READY!"


fdc_test_start saltstack "Accepting salt-minion key"
echo y | salt-key -a test.local
fdc_test_pass saltstack "Key accepted for salt-minion"


fdc_test_start saltstack "Testing salt-minion ping"
if ! salt-call test.ping; then
	fdc_test_fail saltstack "Failed to ping master from minion"
	false
fi
fdc_test_pass saltstack "Ping success from salt-minion"


fdc_test_start saltstack "Testing salt-minion grains"
if ! salt-call grains.items > salt.grains 2>&1; then
	fdc_test_fail saltstack "Failed to get grains from salt-minion"
	false
fi
fdc_test_pass saltstack "Test of salt-minion salt.grains passed"


fdc_test_start saltstack "Testing salt-minion show_top"
if ! salt-call state.show_top > salt.show_top 2>&1; then
	fdc_test_fail saltstack "Failed to run show_top on minion"
	false
fi
fdc_test_pass saltstack "Test of salt-minion salt.show_top passed"


fdc_test_start saltstack "Testing salt-minion apply"
if ! salt-call state.apply -l info 2>&1; then
	fdc_test_fail saltstack "Failed to run salt-minion apply"
	false
fi
fdc_test_pass saltstack "Test of salt-minion state.apply passed"


fdc_test_start saltstack "Testing the file created has the right contents"
if ! grep 'hello world' /root/test.file 2>&1; then
	fdc_test_fail saltstack "Failed to test file exists which should of been created"
	false
fi
fdc_test_pass saltstack "Test of file create passed"
