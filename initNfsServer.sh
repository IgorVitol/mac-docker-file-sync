#!/bin/sh
# Maintained by Igor Vitol: https://www.linkedin.com/in/igor-vitol-87572a95/
#
# This script will start NFS Server (v4) in docker container.
# You will be able to mount NFS share with all docker volumes on your MacOS and work with files directly
# With this you can avoid using Docker-Sync/Mutagen, e.t.c. for files sync and keep great Docker performance on Mac
# Created in order to use with Magento 2 projects, but could be used for any docker container/volume.
# Custom NFS port is used to avoid any possible conflicts with your host system
#
# Tested on MacOS 10.15.7 + Docker Desktop 2.4.0
# Could be used with Minikube as well. (Tested with VirtualBox driver). In such case host ip = "minikube ip"
# No reason in using it on Windows, since WSL2 provide direct access to VM by \\wsl$\docker-desktop-data
#
# See more on possible options here: https://hub.docker.com/r/itsthenetwork/nfs-server-alpine

docker run \
 --name nfs \
 -d \
 --restart always \
 --privileged \
 -p 10555:2049 \
 -v /var/lib/docker/volumes:/allDockerVolumes \
 -v /lib/modules:/lib/modules \
 -e SHARED_DIRECTORY=/allDockerVolumes \
 itsthenetwork/nfs-server-alpine:latest