# Method for building asterisk & creating a asterisk running container.

## Building the Docker image with Asterisk

```
./build.sh
```

This script creates a "build" container that compiles Asterisk.  It then
extracts the built copy of Asterisk & makes a new Docker image that only
contains the CentOS 7 OS and the Asterisk binaries.

This keeps the image size smaller than if we used the build container as
the reference image.

## Running the Asterisk image

```
docker run -d -m 512mb \
           -v /path/to/config:/etc/asterisk \
           -p 5060:5060/udp \
           --restart=always --name asterisk \
           local/asterisk
```
