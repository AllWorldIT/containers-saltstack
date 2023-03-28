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


fdc_notice "Installing packages to support Saltstack testing..."
apk add pciutils


fdc_notice "Setting up Saltstack test environment..."

# Setup master
mkdir /srv/salt
cat <<EOF > /srv/salt/top.sls
base:
    '*':
      - tests
EOF

cat <<EOF > /srv/salt/tests.sls
/root/test.file:
    file.managed:
        - contents: |
            hello world
EOF


# Setup slave
mkdir /etc/salt/minion.d
if [ "$FDC_CI" == "IPv6" ]; then
    echo "master: \"::1\"" > /etc/salt/minion.d/50-tests.conf
else
    echo "master: 127.0.0.1" > /etc/salt/minion.d/50-tests.conf
fi
echo "test.local" > /etc/salt/minion_id

cat <<EOF > /etc/supervisor/conf.d/salt-minion.conf
[program:salt-minion]
command=/usr/bin/salt-minion -l debug

stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
EOF

