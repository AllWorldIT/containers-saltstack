#!/bin/bash

apk add pciutils

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
echo "master: localhost" > /etc/salt/minion.d/50-tests.conf
echo "test.local" > /etc/salt/minion_id

cat <<EOF > /etc/supervisor/conf.d/salt-minion.conf
[program:salt-minion]
command=/usr/bin/salt-minion

stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
EOF

