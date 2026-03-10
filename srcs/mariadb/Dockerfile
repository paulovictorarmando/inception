FROM debian:bookworm
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /var/lib/mysql /var/run/mysqld && \
    chmod 755 /var/lib/mysql /run/mysqld
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh
EXPOSE 3306
ENTRYPOINT ["/setup.sh"]
