debian-kitchen
==============

This is a Debian Jessie docker image with a functionnal systemd and
test-kitchen.
Puppet, Chef and Ansible are also installed in order to work with kitchen
for test purpose.

Prerequisites
-------------

- Docker

Usage
-----

```text
docker pull yueyehua/debian-kitchen
docker run \
  -d \                                           # daemonize
  --privileged \                                 # for systemd
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \          # for systemd
  -v /var/run/docker.sock:/var/run/docker.sock \ # for docker
  --name kitchen \                               # container name
  -h kitchen \                                   # hostname
  yueyehua/debian-kitchen
docker exec -ti kitchen bash
[Do something here]
docker stop kitchen
docker rm kitchen
```
