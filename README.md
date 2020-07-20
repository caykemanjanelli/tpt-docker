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

**Setup para Build** 

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

**Instalando TPT**

Execute os comando abaixo, apos executado o `.setup.sh` escolha a opção `a`, na proxima opção aperte `enter` para utilização do path padrão.

```sh
$ cd /root/TeradataToolsAndUtilitiesBase/
$ ./.setup.sh
Welcome to the Teradata Tools and Utilities 17.00 installation    v.17.00.15.00
Copyright 2001-2020 Teradata. All rights reserved.
IF YOU OR THE ENTITY FOR WHOM YOU ARE INSTALLING THIS SOFTWARE DOES NOT HAVE 
A WRITTEN LICENSE AGREEMENT WITH TERADATA FOR THIS SOFTWARE, DO NOT INSTALL,
USE, OR ALLOW USE OF THIS SOFTWARE.

Platform: Linux 64bit
Media: TTU Foundation 64-bit Bundle
.....................................................................
 1. bteq        - 17.00.00.04 - Teradata BTEQ Application                           884 KB
 2. fastexp     - 17.00.00.05 - Teradata FastExport Utility                         792 KB
 3. fastld      - 17.00.00.06 - Teradata FastLoad Utility                           530 KB
 4. jmsaxsmod   - 17.00.00.04 - Teradata JMS Access Module                           95 KB
 5. mload       - 17.00.00.05 - Teradata MultiLoad Utility                          856 KB
 6. mqaxsmod    - 17.00.00.03 - WebSphere(r) Access Module for Teradata             303 KB
 7. npaxsmod    - 17.00.00.04 - Teradata Named Pipes Access Module                  102 KB
 8. s3axsmod    - 17.00.00.06 - Teradata Access Module for Amazon S3               9582 KB
 9. gcsaxsmod   - 17.00.00.01 - Teradata Access Module for Google Cloud Storage    6706 KB
1.  azureaxsmod - 17.00.00.03 - Teradata Access Module for Azure                   9534 KB
2.  kafkaaxsmod - 17.00.00.02 - Teradata Kafka Access Module                       3851 KB
3.  sqlpp       - 17.00.00.01 - Teradata C Preprocessor                             661 KB
4.  tdodbc      - 17.00.00.17 - Teradata ODBC Driver                              76759 KB
5.  tdwallet    - 17.00.00.41 - Teradata Wallet Utility                            8349 KB
6.  tptbase     - 17.00.00.08 - Teradata Parallel Transporter Base                68934 KB
7.  tpump       - 17.00.00.05 - Teradata TPump Utility                             1022 KB
8.  teragssAdmin- 17.00.00.02 - Teradata GSS Administration Package                9934 KB

              Total Dependency Packages Size(ttupublickey, tdicu, cliv2, piom) :  17910 KB
                                                   Packages Size (Grand Total) : 216804 KB

a. Install all of the above software (except Teradata Wallet)
w. Install all of the above software (including Teradata Wallet)
q. Quit the installation

Enter one or more selections (separated by space): a
Which directory should be used as a base dir (prefix) for installing files?
<base_dir>/teradata/client/17.00
(default base dir: /opt ) : 
```