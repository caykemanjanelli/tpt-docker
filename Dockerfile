FROM zhlh/teradata_unixodbc

ADD ./TeradataToolsAndUtilitiesBase /tmp/

RUN ./setup

ENTRYPOINT ["bash"]
