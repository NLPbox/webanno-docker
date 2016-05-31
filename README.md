Installation
============

```shell
docker build -t webanno3 https://github.com/fkuhn/webanno3-docker.git
```
or 
```shell
docker build --no-cache=true -t webanno3 https://github.com/fkuhn/webanno3-docker.git
```

Usage
=====
The service starts with, for example:

```shell
docker run -i -t -p 18080:18080 webanno3
```

You can then access the webanno frontend via **localhost:18080/webanno** 
