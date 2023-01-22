[![pipeline status](https://gitlab.conarx.tech/containers/saltstack/badges/main/pipeline.svg)](https://gitlab.conarx.tech/containers/saltstack/-/commits/main)

# Container Information

[Container Source](https://gitlab.conarx.tech/containers/saltstack) - [GitHub Mirror](https://github.com/AllWorldIT/containers-saltstack)

This is the Conarx Containers SaltStack image, it provides the SaltStack master service for deploying configurations to SaltStack
minions.

Features:

- Support for Git storage of pillars and states using pygit2



# Mirrors

|  Provider  |  Repository                                           |
|------------|-------------------------------------------------------|
| DockerHub  | allworldit/saltstack                                   |
| Conarx     | registry.conarx.tech/containers/saltstack              |



# Conarx Containers

All our Docker images are part of our Conarx Containers product line. Images are generally based on Alpine Linux and track the
Alpine Linux major and minor version in the format of `vXX.YY`.

Images built from source track both the Alpine Linux major and minor versions in addition to the main software component being
built in the format of `vXX.YY-AA.BB`, where `AA.BB` is the main software component version.

Our images are built using our Flexible Docker Containers framework which includes the below features...

- Flexible container initialization and startup
- Integrated unit testing
- Advanced multi-service health checks
- Native IPv6 support for all containers
- Debugging options



# Community Support

Please use the project [Issue Tracker](https://gitlab.conarx.tech/containers/saltstack/-/issues).



# Commercial Support

Commercial support for all our Docker images is available from [Conarx](https://conarx.tech).

We also provide consulting services to create and maintain Docker images to meet your exact needs.



# Volumes


## /etc/salt/pki

PKI certificate directory, this must be bind mounted.


## /var/cache/salt

SaltStack master cache, this must be bind mounted. This directory is generally used for caching gitfs repositories.


## /srv

SaltStack master configuration for state, pillars and formulas. This directory is pointless if all data is pulled from gitfs.



# Configuration


## /etc/salt/master.d

Additional SaltMaster configuration files can be bind-mounted into this directory.



# Exposed Ports

SaltStack ports 4505 and 4506 are exposed.



# Example


You will need to bind mount the following:

  - data/pki => `/etc/salt/pki`
  - data/cache => `/var/cache/salt`
  - data/srv => `/srv`

Optional bind mounts for specifying configuration:

  - data/master.conf => `/etc/salt/master.d/config`
  - data/gitfs => `/etc/salt/gitfs`

The container folder `/etc/salt/gitfs` is treated as private. As per below the ssh keys for gitfs can be put here.

An example of a basic gitfs configuration can be found below, this assumes that SSH keys are bind mounted into `/etc/salt/gitfs`,
this configuration would be bind mounted into `/etc/saltmaster.d/config`...
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


Exmaple `docker-compose.yml` snippet for a SaltStack master...

```yaml
version: '3'

services:
  saltstack:
    image: registry.conarx.tech/containers/saltstack
    ports:
      - '4505:4505'
      - '4506:4506'
    volumes:
      - ./data/pki:/etc/salt/pki
      - ./data/cache:/var/cache/salt
      - ./data/srv:/srv
      - ./config/gitfs:/etc/salt/gitfs
      - ./config/master.conf:/etc/salt/master.d/config
```
