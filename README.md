# Introduction

This is a Saltstack salt-master container.

Check the [Base Image](https://gitlab.iitsp.com/allworldit/docker/base/README.md) for more settings.

This image has a health check which checks the salt master replies to presence checks.

# Configuration

## Salt Master

You will need to bind mount the following:

  - data/pki => `/etc/salt/pki`
  - data/cache => `/var/cache/salt`
  - data/srv => `/srv`

Optional bind mounts for specifying configuration:

  - data/master.conf => `/etc/salt/master.d/config`
  - data/gitfs => `/etc/salt/gitfs`

The container folder `/etc/salt/gitfs` is treated as private. As per below the ssh keys for gitfs can be put here.

An example of a basic gitfs configuration can be found below... for this example one would also bind mount `/etc/salt/gitfs`.
```
fileserver_backend:
  - git

gitfs_provider: pygit2

gitfs_remotes:
  - 'ssh://git@gitlab.example.com:1022/saltstack/states.git':
    - privkey: /etc/salt/gitfs/id_rsa
    - pubkey: /etc/salt/gitfs/id_rsa.pub

ext_pillar:
  - git:
    - master 'ssh://git@gitlab.example.com:1022/saltstack/pillars.git':
      - privkey: /etc/salt/gitfs/id_rsa
      - pubkey: /etc/salt/gitfs/id_rsa.pub
```

