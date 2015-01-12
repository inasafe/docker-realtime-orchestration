docker-realtime-sftp
==========

A simple docker container that runs sftp for realtime using default ssh port (22)

To build the image with the name 'AIFDR/sftp-realtime' do:

```
sh build.sh
```

To run a container do (will make a container with name 'sftp-realtime' and will mount volume for realtime needs):

```
sh run.sh
```

To log into your container do:

```
ssh root@localhost
```

Default password will appear in docker logs:

```
docker logs sftp-realtime | grep 'root login password'
```

-----------

Tim Sutton (tim@kartoza.com)
May 2014
