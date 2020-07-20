FROM zhlh/teradata_unixodbc

ADD ./TeradataToolsAndUtilitiesBase /tmp/

RUN /tmp/.setup.sh

RUN mkdir /opt/app
RUN chmod 777 -R /opt/app

ADD ./config /opt/app

WORKDIR /opt/app

USER 0

ENTRYPOINT ["tbuild", "-f", "demo2.tpt"]

# TODO alter fixed file to Variable $FILE
#ENV FILE="demo2.tpt"
#ENTRYPOINT ["tbuild", "-f", "FILE"]