#!/bin/sh
# Maintained by Igor Vitol: https://www.linkedin.com/in/igor-vitol-87572a95/
#
# NFS Server should be initialized first
# Script will mount container NFS share to local folder ~/docker-volumes
# All Docker volumes will be accessible with original permissions - you can use chown/chmod, e.t.c. directly
# TODO: automate mount after docker-desktop startup

mkdir -p ~/docker-volumes
mount -t nfs -o port=10555 -o vers=4 -v 127.0.0.1:/ ~/docker-volumes