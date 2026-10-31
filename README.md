# JottaCloud Docker

A Docker image that runs the jottad daemon. Allows to login into JottaCloud on first run.
Works with any data you mount into the container — plain directories, volumes, NFS mounts, or encrypted FUSE views.

## Overview

The container runs jottad as the entrypoint (via a small, extendable shell script) and exposes jotta-cli for management via docker exec.

## Building

```
docker build -t jotta_syncer .
```

## Usage

### First Run

```
# data.sync is the directory to backup
# .jottad stores the configuration directory on the host that holds the login session
docker run \
  --name jotta \
  -v data.sync/:/data \
  -v .jottad:/root/.jottad \
  -e JOTTA_DEVICE_NAME=<DEVICE_NAME> \
  -e JOTTA_TOKEN=<JOTTA_TOKEN> \
  jotta_syncer:latest
```

* Get the Jotta Token from https://jottacloud.com/web/secure
* To re-login, mount an empty .jottad directory

### Mount an encrypted data directory

> See also [gocryptfs](./gocryptfs.md)

* gocryptfs allows to mount via fuse an encrypted view of a data directory
  ```
  gocryptfs -init -reverse data/
  # write down the master key
  sudo mkdir -p data.sync/docs.enc
  sudo chmod -R 0777 data.sync/docs.enc
  # fuse requires a config change to use "allow_other"
  sudo sh -c 'echo "user_allow_other" > /etc/fuse.conf'
  # allow_other is required to allow docker to access the fuse-mount
  gocryptfs -allow_other -reverse data/ data.sync/docs.enc
  ```
* start the jotta docker container
  ```
  docker run \
    --name jotta \
    -v data.sync/:/data \
    -v .jottad:/root/.jottad \
    jotta_syncer:latest
  ```

