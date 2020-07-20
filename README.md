# TPT Docker - Teradata Parallel Trasporter

### PROPÓSITO

>  Docker container for run TPT

#### TECNOLOGIAS ENVOLVIDAS

- GIT: ([Download](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git))
- Docker: ([Download](https://docs.docker.com/engine/install/ubuntu/))

### Baixando o Projeto

**Clone do Projeto via SSH**
```sh
$ git clone git@github.com:caykemanjanelli/tpt-docker.git
```
### BUILD - UTILIZAÇÂO VIA DOCKER CONTAINER

**RUN CONTAINER WILDOUT BUILD** 

Em um ambiente que possua **docker**, executar os comandos abaixo para preparar um ambiente e subir o container.
```sh
$ cd tpt-docker/
$ docker run -it --rm -v ${PWD}:/root zhlh/teradata_unixodbc bash
```
>Parametros:
>* **-it** : Interactive,
>* **--rm** : Container ira ser deletado da memoria quando "desligado"
>* **-v** : Corresponde ao voluma criado entre o Host e o container
>* **sh** : Comando para acesso shell ao container

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