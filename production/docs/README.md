# InaSAFE Realtime Headless Processor

This repo and folder are specifically used to explain the orchestration of 
InaSAFE Realtime Headless Processor.

# What is InaSAFE Realtime Headless Processor

InaSAFE Realtime Headless Processor, or we will short it as InaSAFE Processor 
is a server tool we created that are able to run specific/tailored InaSAFE Realtime 
analysis remotely without QGIS Desktop Client. This server tool handled:

- Shakemaps (from BMKG)
- Floodmaps (from petabencana)

Then perform predefined analysis parameters on hazard data provided by these
organization. The process will output analysis reports (calculated by InaSAFE)
and will happen in near-realtime when new hazard data is pushed and available. 
These output then will be sent to InaSAFE Django Web Application so users
can view the results over the internet using a web browser.

From a technical standpoint, InaSAFE Processor is a service that handled 
a given set of hazard data as input and produce an impact analysis with custom 
made report template specific with the hazard type. It will calculate InaSAFE
analysis with a given predetermined Exposure data and Aggregation layer provided 
beforehand.

For shakemaps, the analysis process is triggered by a change in the monitored 
directory. BMKG will push new hazard data (shakemaps) into this directory. 
When that happens, InaSAFE Processor will pick up the new data and perform analysis.
After it is done, it will sent the result to InaSAFE Django Web App. This whole 
process will be called Shakemap Monitoring tool.

For floodmaps, the analysis process is triggered by a celery request made by
InaSAFE Django Web App. InaSAFE Django Web App will control the frequency of 
how often a new snapshot of Flood data should be taken. When this happened, 
InaSAFE Processor will fetch current Flood data from PetaBencana.id via REST 
API request. The current flood data will be saved (for history purposes). Then, 
InaSAFE Processor will perform analysis (specific for Jakarta area only) with 
a given population exposure. The result will be sent to InaSAFE Django App.

# The Architecture

InaSAFE Processor orchestration relies on docker containers and will be managed 
by a Rancher server instance. This will allow sysadmin to easily manage container 
services, data, and scale if necessary. Listed below are some different terminologies 
that need to be understand by a sysadmin to maintain this service:

- Basic Understanding of NFS Shared Storage Service
- Docker containers and micro service architecture
- Rancher server and agents as docker containers managers
- General data management and backups

## NFS Shared Storage Service

InaSAFE Processor needs to store/persist hazard data given by each data source.
It also needs to store exposure data and analysis result. The easiest way to make 
these data available to each services and persist/replicate it easily is using 
a Shared Storage Service. With a shared storage service, sysadmin can have 
a central location as a main data bank. We propose a dedicated NFS Server to 
store all these data (with big storage) in central location. This NFS Server 
then can be accessed by docker containers, but should not be able to be accessed 
from outside network (internet). Sysadmin can then manage data like creating backup 
or snapshot from a central location.

In addition for having a Shared Storage Service, we also propose to use a 
replication service like BitTorrent Sync to easily setup new instance of 
InaSAFE Processor if needed (like migrations or moving to a new machine). 
BtSync will make it easier for sysadmin to migrate data. With BtSync, all you 
have to do is share the appropriate key (Read only or Read Write) to a replication 
container service. This key can also be used to replicate the data to your other
desired machine (local machine or server)

## Docker containers and Micro Service Architecture

We heavily use Docker to make it easy for sysadmin to deploy services. Docker 
is a tool to create/run a distributed application, see: [Docker](https://www.docker.com).
With docker, we can easily build and run service on any Linux platform (or even mac and windows).
This enabled the developer to easily create a service application and sysadmin 
can easily run the application on server machine.

Docker packaged its application as a small lightweight virtual machine called containers.
Sysadmin can run containers and Developers build them. When containers were made 
to perform one specific tasks, we called this services. An orchestration defined 
one or more different services to perform a series of tasks together and specify 
how they communicate with each other. This is called Micro Service Architecture. 
When we talk about a Docker orchestration, we specify how services work together, 
how they communicate with each other, how they can be started and stopped, etc.

The orchestration of docker containers were described using a file called 
`docker-compose.yml`. We can see services definition in `docker-compose.yml` file. 
A group of containers specified by a `docker-compose.yml` file is often called as 
a `stack`.
  
## Rancher Server and Agents

It is possible to deploy or manage docker containers or stacks using command 
line tools. But this process needs a learning curve and perhaps undesirable for 
new sysadmin not familiar with Docker. To ease the process, we use Rancher as 
container/stack management tools, see [Rancher](http://rancher.com). 
Rancher uses Graphical User Interface via Web Application so it is easy to use 
and understand. Rancher made it possible for 
sysadmin to just focus on deployment and management without having to know too 
much details about Docker.
  
Rancher have two specific part, Rancher Server and Agents. A Rancher Server 
is the manager that provides the Graphical User Interface. We can easily deploy 
Rancher Server because it is too, a docker container/service. You can view the 
Web UI just by deploying Rancher Server, however it needs one (or more) Rancher 
Agents to actually run service containers. You can install Rancher Agents on 
machine that will do the actual work (providing the services you want to deploy), 
and have those machines registered to a Rancher Server so it can be managed.

To easily familiarize yourself with Rancher, you need to understand several 
terminologies:

- Rancher Server: A machine installed with Rancher Server will manage deployment.
  This machine will need to be exposed for a group people to use.
- Rancher Agents: one or several machines installed with rancher agents will act
  as a resource for Rancher Server to use to deploy docker containers. This agents
  can be any machine (preferably Linux) with docker installed with sufficient 
  hardware requirements depending on what kind of service you want to deploy.
- Environment: Term used by Rancher to categorize container deployment setting. 
  You might want to create an Environment for a group of Stacks that will perform 
  as one big services.
- Stack: A group of containers (micro services) defined by docker-compose.yml 
  to perform a certain task or provides services.
- Infrastructure Stack: Special stack used internally by Rancher
- Catalog: Template provided by Rancher and/or Community that can be used as a
  stack by sysadmin. Usually contains a very specific functionality for Sysadmin. 
  Like a storage Catalog or monitoring service.

# Prerequisite

Specific prerequisite document can be seen here [Prerequisite](PREREQUISITE.md)

After you finished your prerequisite set up, continue to deploy the services

# Service deployment

Before you begin deployment, you need to understand that deploying the service 
the first time needs additional step to ensure that the data is synced/replicated correctly. 
It is better to divide the deployment step into 2 part, initial setup and maintenance.

## Initial Setup

If this is your first setup, you need to remember that your InaSAFE Processor Stack 
will have no initial data. Before running the service properly, you need to understand 
what kind of data that will be involved in the deployment.

### Data List

This rancher orchestration describes several named volumes. Each has their own 
usage to store particular data. This volumes will be mounted by rancher to containers
that needed those volumes. Some volumes are shared between service.

1. Analysis Data

This is a docker volume that will contain all the Exposure data needed to perform analysis.
There are also report templates and png images stored in this volume to generate report.

2. Shakemaps (from BMKG)

This is a collection of shakemaps pushed by BMKG using SSH/SFTP/Rsync protocol.
All the past and new shakemaps will be pushed into this directory.

3. Shakemaps (from BNPB)

This is another mirror collection of shakemaps from BNPB. Ideally this mirror is coming 
from BNPB server and maintained by them. BMKG also pushed into BNPB and we sync it using BtSync.
In the future, BNPB can just merge both shakemaps into one directory and have BMKG pushed
into just one. At the moment this volume is just a redundancy but didn't 
processed in this orchestration.

4. Shakemaps Corrected

This is a collection of corrected shakemaps pushed by BMKG. Doesn't get 
processed for now, because of a rather different convention in the Shake ID.

5. Shakemaps Extracted

This volume stores shakemaps impact result analysis and reports.

6. Shakemaps Corrected Extracted

Not used for now, but will be used to store impact result of Shakemaps Corrected.

7. Floodmaps

This is a collection of REST API, GeoJSON output, from PetaBencana.id 
(formerly PetaJakarta.org). This volume contains Flood Hazard for Jakarta 
recorded by BPBD team. This volume also stores Analysis Result of Jakarta Flood.
Because of the frequency (hourly each day), this volume is big.

8. Ashmaps

Not used officially for now. This volume will stores files related with Ash Fall
hazard and reports.

9. SSH Config data
 
This is a maintained data of SSH credentials. In theory, we can use a new 
credentials for SFTP access, but it will be easier for BMKG if we maintain the 
same private/public key and authorized_key list, so BMKG can push with the same 
credentials even if InaSAFE Processor gets migrated.

### Service List

This rancher orchestration contains several services as described in [production/docker/docker-compose.yml](production/docker/docker-compose.yml) 
template. These service each has their own tasks.

- analysis-data-sync

Service to sync Exposure Data, Report template, and other analysis input related file.

- bnpb-sync

Service to sync shakemaps hazard data which is managed by BNPB.

- bmkg-sync

Service to sync shakemaps hazard data pushed by BMKG whenever there is a new shakemaps happened.

- shakemaps-extracted-sync

Service to sync shakemaps

### Data Migration strategy

In Initial Setup, there are various alternative to migrate data from original 
location to a new environment. We will describe possible alternatives here.

1. Rsyncing to a new machine

In this strategy we migrate data from previous location using rsync. 
To do this, make sure you understand which directory goes into which volumes. 
This is the only possible solution to migrate from non Rancher orchestration 
to Rancher. 

Condition:

- Old orchestration is different or not using Rancher
- Migrate into a new NFS Shared Storage
- Migrate into a new or existing Environment/Stack
- Sysadmin more confident on doing manual migrations

The strategy is described as follows:

- Mark/List/Take note of all the data location from previous machine
- Decide the location in the new NFS Shared Storage machine, to where the data will be Rsynced
- Create snapshot if necessary
- Generate Stack using the provided `docker-compose.yml` file. Skip this if you 
  already use existing Stack
- Stop the stack after it was successfully generated, to prevent btsync from 
  running
- Manually Rsyncing from old to new location
- Run the stack after we finished migrating into a new NFS Shared Storage

2. Btsyncing to a new machine

In this strategy, we let the data migrate using InaSAFE Processors' BtSync 
containers. In this strategy, we just let the containers syncing until it's done.
The drawback is, it all happens automatically we can't know when it finish syncing. 
To make it easier to guess, you can see the network activity in each containers.

Condition:

- Moving from the same type of orchestration, but different NFS Shared Storage
- Sysadmin more confident on doing automated human independent migration.

The strategy is described as follows.

- This only works if BtSync is properly setup on previous orchestration.
- Generate Stack using the provided `docker-compose.yml` file. Or skip if existing.
- Do not stop the stack, but only stop data dependent service. 
  Which is `sftp`, `inasafe-worker`, `inasafe-shakemap-monitor`. To be more precise,
  let all service that ends with `-sync` ran.
- After you make sure all sync containers are synced (inspect the network activity),
  start the remaining services.
  
3. Rsync the whole NFS Shared Storage

In this strategy, we migrate the whole NFS Shared Storage into a new machine. 
So the difference from Rancher perspective is just the NFS Server hostname.
Or it doesn't make any difference at all if the address is the same. In this 
strategy, it will obviously assumed that it uses the same orchestration.

Condition:

- Migrating just the NFS Shared Storage into a new machine, with the same architecture.
- The process can be transparent from Rancher Server side

The strategy is described as follows.

- Create another NFS Shared Storage with a new address
- Rsync/migrate content from old NFS Storage into the new one
- Upgrade the NFS Storage Driver stack into the new address


## Manage and maintenance

After performing data migrations, you can use the web UI of Rancher to perform 
various tasks. We will provide example of some common tasks:


### Stack Creation

To create stack, go to Stacks > Add Stack. Add Stack UI will be shown. In here,
you can provide a stack name: `realtime`. It is easier to Copy Paste the provided 
`docker-compose.yml` to describe the whole stack. Alternatively, you can create 
and manually configure it later using the web UI, with a drawback that you can't 
import compose file later.

### Service Management

If you click a stack from the stack list, you will go to individual/detail stack page.
All the services associated with the stack will be listed here. In here, you can 
start/stop a service (or the whole stack). To make some changes in a particular service,
you can click `Upgrade`. You will be brought into an Upgrade Service page. You can 
think of this like editing a service, but the changes will be applied in stages,
that's why it is called `Upgrade`. After doing some changes, click Upgrade. 
You will have an option to `Rollback` or `Finish Upgrade` after successful `Upgrade` 
attempt. If you finish an upgrade, you can't rollback and the previous container 
configuration (not the data) will be deleted.

### Service Monitoring

A service can be composed of one or several identical containers. If you click 
a service, you will be brought into a Service page. In this page, you can see 
several detail information like performance graph, container info, etc.


