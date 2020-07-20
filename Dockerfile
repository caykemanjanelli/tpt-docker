FROM zhlh/teradata_unixodbc

ADD ./TeradataToolsAndUtilitiesBase /tmp/

RUN /tmp/.setup.sh

ENTRYPOINT ["bash"]
