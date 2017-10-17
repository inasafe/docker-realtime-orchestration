Docker Realtime Orchestration
=============================

Orchestration scripts for running InaSAFE realtime services.

To use you need to have docker installed. You need a minimum of docker 1.3.

In addition you need to have docker-compose installed.

During the build process, four docker images will be built:

  * **realtime-sftp**: This runs an ssh server that will act as a
    drop off point for new shake event datasets. The container run from this
    image is a long running daemon.
  * **realtime-apache**: This runs an apache server that will host
    the reports after they have been generated. The container run from this
    image is a long running daemon. Not really used right now except for serving
    static pages for debugging purposes.
  * **realtime-btsync**: This runs a btsync (resilio) server that will
    contain the analysis datasets used during shakemap generation. The btsync
    peer hosted here is read-only. To push data to the server, you need to
    have the write token (ask Tim or Rizky for it if needed). The
    container run from this image is a long running daemon.
  * **realtime-inasafe**: This contains the actual service running inasafe to
  	process shakemaps, floods and ash (which hazards are processed is subject to change).

The orchestration script provided here will build against docker recipes
hosted in GitHub. So to use InaSAFE realtime all you need to do is (on your
host):

1. Decide if you want to sync input data. The default state of these btsync config files is empty so that orchestration does not fail and so that the default behaviour is to not sync as it would trigger a very large file transfer. See the comments in:
    - `docker-btsync/btsync.env`
    - `docker-shakemaps-corrected-sync/btsync.env`
    - `docker-floodmaps-sync/btsync.env`
    - `docker-ashmaps-sync/btsync.env`
    - `docker-bmkg-sync/bmkg_credential.env`
    - `docker-bnpb-sync/bnpb_credential.env`
    - `docker-shakemaps-corrected-extracted-sync/btsync.env`
    - `docker-shakemaps-extracted-sync/btsync.env`

1. Copy `docker-inasafe/realtime-rest.env.template` to `docker-inasafe/realtime-rest.env` and edit if you want to change the Realtime REST server url.

1.  For the four Docker images that will be built (listed above), if you want to use apt-cacher-ng then follow the instructions in each `71-apt-cacher-ng.template` file and in each `Dockerfile` file uncomment the `#ADD 71-apt-cacher-ng /etc/apt/apt.conf.d/71-apt-cacher-ng` line.
```

then

```
git clone git://github.com/inasafe/docker-realtime-orchestration.git
cd docker-realtime-orchestration
make
make checkout __production environment__ OR
make checkout development __development environment__

```

You can see the status of all the containers by running:

```
make status
```

To get the credential for the running sftp container, run:

```
make sftp_credential
```

Now you can run an assessment for the latest shakemap:

```
make inasafe-shakemap
```

You can deploy all the services by running:

```
make deploy
```

To kill and delete stale container, run:

```
make rm
```

After deploying realtime services, shakemap monitor will also running.
**Shakemap monitoring services** is used to monitor shakemap sftp folder.
It will processs new shakemaps automatically, if new shakemap folder is pushed
to realtime-sftp.
To view the last 10 lines of the service logs (also follow the logs), run:

```
make monitor-log
```

To get into the inasafe shell (useful to execute script directly), just run:

```
make inasafe-shell
```

Below is the complete make command list:

  * **make**: Build, deploy, and show all the containers' status
  * **make build**: Build all the images from fig configuration
  * **make deploy**: Deploy all the containers
  * **make checkout**: Checkout the latest inasafe develop source
  * **make inasafe-shakemap**: Run assessment for the latest shakemap
  * **make status**: Show the status of all the containers
  * **make sftp_credential**: Show the sftp container's credential
  * **make monitor-log**: Show last 10 logs, and follow shakemap monitor
  * **make rm**: Kill and remove all the running container

--------

Tim Sutton and Akbar Gumbira, July 2014
Rizky Maulana Nugraha, January 2016
