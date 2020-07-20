FROM zhlh/teradata_unixodbc

ADD ./TeradataToolsAndUtilitiesBase /tmp/

RUN /tmp/.setup.sh

RUN mkdir /opt/app
RUN chmod 777 -R /opt/app

ADD ./config /opt/app

WORKDIR /opt/app

ENTRYPOINT ["tbuild", "-f", "demo2.tpt"]
