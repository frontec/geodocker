Based on winsent/geoserver.

## Table of contents

* [What is Geoserver](#markdown-header-What is GeoServer)
* [Prerequisites](#markdown-header-prerequisites)
* [Setup](#markdown-header-setup)

# What is GeoServer? #
GeoServer is a Java-based software server that allows users to view and edit geospatial data. Using open standards set forth by the [Open Geospatial Consortium (OGC)](http://www.opengeospatial.org/), GeoServer allows for great flexibility in map creation and data sharing.

![GeoServer_200.png](http://static.geoserver.org/images/GeoServer_200.png)

wiki: [wikipedia.org](https://wikipedia.org/wiki/GeoServer) | site: [geoserver.org](http://geoserver.org/) | documentation: [docs.geoserver.org](http://docs.geoserver.org/) | repository: [github.com](https://github.com/geoserver/geoserver)
# Image description #

Is not official GeoServer image based on `Oracle Java` with `JAI 1.1.3`, `ImageIO 1.1`, `GDAL 1.10.1` and extensions:

* ogr
* gdal
* printing
* importer

## Prerequisites

* Install [Docker](https://www.docker.com/) on your system.

    * [Install instructions](https://docs.docker.com/installation/mac/) for Mac OS X
    * [Install instructions](https://docs.docker.com/installation/ubuntulinux/) for Ubuntu Linux, Docker Version > 1.10
    * [Install instructions](https://docs.docker.com/installation/) for other platforms

* Install [Docker Compose](http://docs.docker.com/compose/) on your system. docker-compose Version > 1.6

    * Python/pip: `sudo pip install -U docker-compose`
    * Other: ``curl -L https://github.com/docker/compose/releases/download/1.6.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose; chmod +x /usr/local/bin/docker-compose``

* [Login or register at dockerhub](https://docs.docker.com/engine/reference/commandline/login/)

* These instructions assume you have your SSH Keys configured both in Bitbucket and Github (you won't be
able to clone the entire repository if you don't). To setup your SSH Keys go to:

    * [https://github.com/settings/keys](https://github.com/settings/keys)
    * [https://bitbucket.org/account/user/[your username]/ssh-keys/](https://bitbucket.org/account/)

## Setup
  1. Do a docker login
  1. Clone this repository and all sub-repositories please do: `git clone --branch development --recursive git@github.com:jailbirt/geodocker.git`

    **MacOSX IMPORTANT: All repositories MUST be cloned in Users home directory. For example: /Users/yourmacuser/theeye**

## Start

  * Run `docker-compose up` for starting: geoserverwriter / geoserverreader1 / geoserverreader2 / nginx for load balancing.
  The app should then be running on your docker daemon on port 8080 (On OS X you can use `boot2docker ip` to find out the IP address).

# Geoserver clustering with multiple masters

  Using the JMS cluster module: (http://docs.geoserver.org/stable/en/user/community/jms-cluster/index.html) 
  you can create a scalable cluster with multiple GeoServers.
  Illustration: (http://geoserver.geo-solutions.it/edu/en/_images/MultiMaster-MultiSlaveSharedDataDir.png)
  
  With this schema all servers act as master/slave and share the same data directory. 
  The JMS cluster module implements a Message Oriented Middleware (MOM) to keep all the nodes in the cluster in synch with respect to their configurations.
  The MOM is actually embedded and running inside each GeoServer, using multicast to find its peers and thus allowing for a clustering installation without the need to have a separate MOM deploy.

  
### Test cluster:

   Clone this repository and run: 
   `docker-compose -f docker-local-geoserver-cluster.yml up -d`
   Then you can scale the available geoservers:
   `docker-compose -f docker-local-geoserver-cluster.yml scale geoserver=n`

### Running the cluster on the cloud:

  Cloud providers like AWS don't support multicast or broadcast between instances. 
  It's a problem because the Message Broker needs multicast for data propagation.
  This issue can be solved with Weave Net (https://www.weave.works/docs/net/latest/introducing-weave/)
  Weave Net allows to create a container network across multiple hosts and supports multicast.
  To share the data directory you can use Amazon EFS or an NFS.

  * Setup:
   Install Weave Net on each Docker Host:
   `sudo curl -L git.io/weave -o /usr/local/bin/weave ; sudo chmod +x /usr/local/bin/weave`
   
   Start Weave on Docker Host1: 
   -Set the consensus parameter at the number of instances running Weave Net.
   `weave launch --ipalloc-init consensus=2 ; eval $(weave env)`
   
   Start Weave on Docker Host2:
   `weave launch --ipalloc-init consensus=2 ; eval $(weave env) ; weave connect $DockerHost1_IPADDRESS`

  * Launch and scale the GeoServers on each Docker Host:
  `docker-compose -f docker-production-geoserver-cluster.yml up -d`
  To scale GeoServers:
  `docker-compose -f docker-production-geoserver-cluster.yml scale geoserver=5`

## Workarounds (F.A.Q)

### Common ERRORS:
ERROR: Conflict. The name "/geodocker" is already in use by container 2cfd591ecc0ab541c46ef196488b8264a7c3931313ef5e5b079b60e4ff650c1c. You have to remove (or rename) that container to be able to reuse that name.
j

Fix: 
   docker rm geodocker

A useful script for clean up your docker crap:
https://gist.github.com/jailbirt/cd3b734a13f4475205953b24f913ea85


###Logs
For easier logs read you can run, please refeer tod docker logs help for more options:
`docker logs -f geodocker

## Using a custom GeoServer data directory ##
Make geoserver data directory and run container, change its path at docker-compose.yml for mounting it.

## License ##
GeoServer licensed under the [GPL](http://www.gnu.org/licenses/old-licenses/gpl-2.0.html).


# User Feedback
