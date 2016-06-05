Installation
============

You can build and install webanno with one simple command:

```shell
docker build -t webanno https://github.com/nlpdocker/webanno-docker.git
```

You can use the same command to rebuild / reinstall webanno. This will take
much less time, as docker reuses the files it has downloaded previously.
In case of errors, you can avoid this behaviour by adding ``--no-cache=true``:

```shell
docker build --no-cache=true -t webanno https://github.com/nlpdocker/webanno-docker.git
```

Usage
=====

The service starts with, for example:

```shell
docker run -i -t -p 18080:18080 webanno
```

You can then access the webanno frontend via **localhost:18080/webanno**
