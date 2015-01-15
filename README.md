Docker Realtime Orchestration
=============================

Orchestration scripts for running InaSAFE realtime services.

To use you need to have docker installed on any linux host. You
need a minimum of docker 1.3.

In addition you need to have fig installed.

During the build process, four docker images will be built:

  * **realtime-sftp**: This runs an ssh server that will act as a
    drop off point for new shake event datasets. The container run from this
    image will be long running daemon.
  * **realtime-apache**: This runs an apache server that will host
    the reports after they have been generated. The container run from this
    image will be a long running daemon.
  * **realtime-btsync**: This runs a btsync server that will
    contain the analysis datasets used during shakemap generation. The btsync
    peer hosted here is read only. To push data to the server, you need to
    have the write token (ask Tim or Akbar for it if needed). The
    container run from this image will be a long running daemon.
  * **realtime-inasafe**: This runs the actual shake impact
    analysis and generates a pdf with the impact report. This is a short
    running container - it simply runs the task and then exits.


The orchestration script provided here will build against docker recipes
hosted in GitHub. So to use InaSAFE realtime all you need to do is (on your
host):


```
git clone git://github.com/AIFDR/docker-realtime-orchestration.git
cd docker-realtime-orchestration
make
make checkout
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
make inasafe
```

Probably you will want to put the above command into a cron job.


--------

Tim Sutton and Akbar Gumbira, July 2014

