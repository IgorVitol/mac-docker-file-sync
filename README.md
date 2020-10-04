# MacOS: Docker File Sync based on NFS Server

#### The issue

<b>Docker Desktop</b> on <b>MacOS</b> works on top of KVM <b>Virtual Machine</b>.

So, if you would try to map your local folders into a container - it will actually setup network share.
Where container will connect to host and do read/write via internal network.

That's the reason, why containers which do a lot of read/write operations is super <b>slow</b>.
Yes, here are some workarounds by adding caches, delegations, e.t.c. But it doesn't solve the issue.

Another option is to use <b>Docker-Sync</b> or <b>Mutagen</b> to sync your local folders into a container and back.
In this case here could be any create/change conflict issues, delays between sync sessions & extra CPU usage.
It's quite hard to debug. Usually devs spent a lot of time, before they will note that files on host & container
are different.

We are working much with Magento 2, which could include 5000+ files for single request, so file-sync performance is
very important.

#### Idea  

The idea is simple. Instead of using sync tools - why not just use vice-versa NFS file sharing?
E.g. Create docker volume on Virtual Machine and share it via NFS. Copy & manage files via NFS.

In this case containers always working with files located on Virtual Machine (no network shares).
Developers can change files using NFS by mounting docker volume locally.

#### Proof of Concept (POC)
 
Existing docker image used for NFS Server: https://hub.docker.com/r/itsthenetwork/nfs-server-alpine

I have prepared few shell scripts in this repository as POC:

* <b>initNfsServer.sh</b>
    * This script will start NFS Server (v4) in docker container.
      Just run it once and NFS server will always run after Docker startup.
    * Custom NFS port is used to avoid any possible conflicts with your host system
    * Tested on MacOS 10.15.7 + Docker Desktop 2.4.0
    * Could be used with Minikube as well. (Tested with VirtualBox driver). In such case host ip = "minikube ip"

*  <b>stopNfsServer.sh</b>
    * Kill & remove nfs container
    * Because of "restart:always" in init script, it is not required to stop/start server manually.
      Just init once.

*  <b>startShare.sh</b>
    * Dedicated to be run on your host.
    * Script will mount container NFS share to local folder <b>~/docker-volumes</b>
    * All Docker volumes will be accessible with original permissions - you can use chown/chmod, e.t.c. directly

*  <b>stopShare.sh</b>
    * Unmount active NFS session by path (<b>~/docker-volumes</b>)
    
#### Usage

Let's check on simplest example.
Assuming that I have an nginx container. As a developer, I want to be able to change it's default home page.

So, we need to do next things:

* Assuming that docker-desktop is installed & working.
* Run once:
    * sh server/initNfsServer.sh

* Run mount script:
    * sh client</b>/startShare.sh

* Create needed docker volume:
    * docker volume create nginx-data
    
* Run nginx container with our volume
   * docker run --name nginx -p 80:80 -d -v nginx-data:/usr/share/nginx/html nginx:latest

* Setup permissions to mount folder (only once for parent folder)
    * sudo chmod 777 ~/docker-volumes

* Setup permissions to docker volume (based on your container's default user/group):
    * Default User/Group ID for nginx container is 101.
        * sudo chown -R 101:101 ~/docker-volumes/nginx-data
        * sudo chgrp -R 101 ~/docker-volumes/nginx-data
        * sudo chmod -R g+s ~/docker-volumes/nginx-data

    * Allow our host OS to work with files as well
        * sudo chmod -R 777 ~/docker-volumes/nginx-data
        
* Open PhpStorm and change "index.html" in <b>~/docker-volumes/nginx-data</b>

* Visit http://127.0.0.1/ and verify results.

* In case if your app/container will change permissions during some operations, it might be needed to update
  permissions manually as shown above.

### Kubernetes

If you want to use Kubernetes hostPath persistent volumes, you could use this way as well.
Just save your <b>hostPath</b> volume folder as <b>~/docker-volumes/myVolumeDir</b>.

Then use:
* hostPath: "/var/lib/docker/volumes/myVolumeDir"    
 