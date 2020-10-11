#!/bin/sh
# Maintained by Igor Vitol: https://www.linkedin.com/in/igor-vitol-87572a95/
#
# This script will run privileged container with 1:1 map to virtual machine (based on alpine image)
# You can assume it as ssh to virtual machine (MobyLinux)
# You can access docker, top, unzip, git, mount, e.t.c. tools under VM file-system

docker run \
  --net=host \
  --ipc=host \
  --uts=host \
  --pid=host \
  -it \
  --security-opt=seccomp=unconfined \
  --privileged \
  --rm \
  -v /:/host \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker \
  alpine /bin/sh -c "chroot /host"