# TPT Docker - Teradata Parallel Trasporter

### OBJECTIVE

>  Docker container for run TPT

#### TECHNOLOGIES

- GIT: ([Download](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git))
- Docker: ([Download](https://docs.docker.com/engine/install/ubuntu/))

### Download Project

**Clone Project - SSH**
```sh
$ git clone git@github.com:caykemanjanelli/tpt-docker.git
```
### BUILD - WITH DOCKER CONTAINER

**RUN CONTAINER WITHOUT BUILD** 

Execute command below to run container in bash mode from image:
```sh
$ cd tpt-docker/
$ docker run -it --rm -v ${PWD}:/root zhlh/teradata_unixodbc bash
```
>Parameters:
>* **-it** : Interactive,
>* **--rm** : Delete Container when finished
>* **-v** : Volume Mount in container
>* **bash** : Bash command

**BUILD CONTAINER**

Execute command below for build a container:
```sh
$ cd tpt-docker/
$ docker build -t tpt-docker .
```

**RUN CONTAINER tpt-docker LOCAL**

Execute command below for run container build previous step
```sh
$ docker run -it --rm tpt-docker:latest
```