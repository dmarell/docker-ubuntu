## Docker tutorial

Simple docker tutorial, showing basic handling.

by Daniel Marell, [C.A.G](http://www.cag.se)

## Life cycle

Starting an ubuntu machine in docker is simple:

```bash
$ docker run -it ubuntu bash
root@93e788c4f2ec:/#
```

In another command window you can inspect running docker instances:
```bash
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
93e788c4f2ec        ubuntu              "bash"              22 seconds ago      Up 19 seconds                           vigorous_colden
```

As we did not give it a name, it was given one: `vigorous_colden`

In order to get a feeling for instances vs types/images, touch the disk of the running instance `vigorous_colden`:

```bash
root@93e788c4f2ec:/# echo date > kilroy-was-here.txt
root@93e788c4f2ec:/# ls -l k*
-rw-r--r-- 1 root root 5 Sep  8 08:37 kilroy-was-here.txt
```

Stop the instance:

```bash
$ docker stop vigorous_colden
vigorous_colden
```
It's gone:

```
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

Start it again:
```
$ docker start vigorous_colden
vigorous_colden
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
93e788c4f2ec        ubuntu              "bash"              3 minutes ago       Up 4 seconds                           vigorous_colden
```
Check that it is 'our' instance:

```bash
root@93e788c4f2ec:/# ls -l k*
-rw-r--r-- 1 root root 5 Sep  8 08:37 kilroy-was-here.txt
```

Now stop and remove the instance:
```
$ docker stop vigorous_colden
vigorous_colden
$ docker rm vigorous_colden
vigorous_colden
```

Now when it has been removed it is of course not possible to start it again:

```bash
$ docker start vigorous_colden
Error response from daemon: No such container: vigorous_colden
Error: failed to start containers: vigorous_colden
```

But we can create a new instance again:
```bash
$ docker run -it ubuntu bash
root@331de7d0fa71:/# 
```

We got a new name:
```bash
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
331de7d0fa71        ubuntu              "bash"              32 seconds ago      Up 30 seconds                           determined_darwin
```

And we can verify that it is a new machine and not the one we had before:
```bash
root@331de7d0fa71:/# ls -l k*
ls: cannot access 'k*': No such file or directory
```

## Build a customized image

The Dockerfile specifies how the new image should be built. In this example we start with the same
ubuntu image as we used before but with `curl` and `git` installed:

Create the following `Dockerfile` in an empty directory somewhere:
```
FROM ubuntu
RUN apt-get update && apt-get install -y \
    curl \
    git
```
Build an image from this `Dockerfile`:
```bash
$ docker build -t myubuntu-image .
...
Successfully built 42243b430191
Successfully tagged myubuntu-image:latest
```

Start it, and give it a name this time:
```bash
$ docker run -it --name myubuntu-1 myubuntu-image bash
root@632e26f1fd8a:/# 
```
Verify that it has curl installed:
```bash
root@632e26f1fd8a:/# curl --version
curl 7.47.0 (x86_64-pc-linux-gnu) libcurl/7.47.0 GnuTLS/3.4.10 zlib/1.2.8 libidn/1.32 librtmp/2.3
```

## Adding a user, run as a daemon and login to container

For security reasons it is not recommended to run as root in container. Add a user by adding these lines to Dockerfile:
```bash
...
RUN useradd -ms /bin/bash user
USER user
WORKDIR /home/user
```

Docker instances runs a command or a specific service. In the above examples we did run `bash`.

Add an `ENTRYPOINT` in `Dockerfile` simulating that we are running some kind of daemon:
```
FROM ubuntu

RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash user
USER user
WORKDIR /home/user

ENTRYPOINT ["tail", "-f", "/dev/null"]
```

Note that we added `rm -rf /var/lib/apt/lists/*` according to [Dockerfile best practicies](https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/).

Build it and run it as a daemon (not specifying `bash`):
```bash
$ docker build -t myubuntu-image .
...
$ docker run -d --name myubuntu-1 myubuntu-image
76ea35fbf20fb32571f1abb6fbdbb8586665ac202de11819523bfcec2a71df0e
$ docker ps
CONTAINER ID        IMAGE               COMMAND               CREATED             STATUS              PORTS               NAMES
76ea35fbf20f        myubuntu-image      "tail -f /dev/null"   11 seconds ago      Up 11 seconds                           myubuntu-1
```

Login to the running instance:
```bash
$ docker exec -it myubuntu-1 bash
user@76ea35fbf20f:~$ 
```
Note that you get a prompt `$` instead of `#`. You are not root anymore.

If you need to login as root, login as root instead using the option `-u 0`:
```bash
$ docker exec -it -u 0 myubuntu-1 bash
root@76ea35fbf20f:/home/user#
```