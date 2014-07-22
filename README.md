Docker Realtime Orchestration
=============================

Orchestration scripts for running InaSAFE realtime services.

To use you need to have docker installed on any linux host. You
need a minimum of docker 0.9.

There are three main scripts here:

* **build.sh**: This will build all the docker images. 
  You can optionally pass a parameter which echo 
  is an alternate organisation or user name
  which will let you build against your forks
  of the official AIFDR repos. e.g.

  ``./build.sh [github organisation or user name]``
  
  During the build process, four docker images will be built:
  
  * **AIFDR/docker-realtime-sftp**: This runs an ssh server that will act as a
    drop off point for new shake event datasets. The container run from this
    image will be long running daemon.
  * **AIFDR/docker-realtime-apache**: This runs an apache server that will host
    the reports after they have been generated. The container run from this
    image will be a long running daemon.
  * **AIFDR/docker-realtime-btsync**: This runs a btsync server that will
    contain the analysis datasets used during shakemap generation. The btsync 
    peer hosted here is read only. To push data to the server, you need to 
    have the write token (ask Tim or Akbar for it if needed). The 
    container run from this image will be a long running daemon. 
  * **AIFDR/docker-realtime-inasafe**: This runs the actual shake impact
    analysis and generates a pdf with the impact report. This is a short
    running container - it simply runs the task and then exits.
  
* **deploy.sh**: This script will launch containers for all the long running
  daemons mentioned in the list above. Each container will be named with
  the base name of the image.
 
* **run.sh**: This script will actually run the shake impact function using
  the short lived `docker-realtime-inasafe` image.
  

There is an additional script called `functions.sh` which contains common
functions shared by all scripts.

The orchestration scripts provided here will build against docker recipes
hosted in GitHub - there is no need to check them all out individually. So 
to use InaSAFE realtime all you need to do is (on your host):


```
git clone git://github.com/AIFDR/docker-realtime-orchestration.git
cd docker-realtime-orchestration
./build.sh
./deploy.sh
```

Now you can run the impact map generation tool:

```
./run.sh
```

Probably you will want to put `run.sh` into a cron job.


--------

Tim Sutton and Akbar Gumbira, July 2014

