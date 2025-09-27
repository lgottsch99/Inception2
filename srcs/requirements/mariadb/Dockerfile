FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y

#install mariadb server
RUN apt install -y mariadb-server mariadb-client gosu

#copy init scrpts into cont
COPY tools/entrypoint.sh /entrypoint.sh
#COPY tools/init.sql /init.sql
RUN chmod +x /entrypoint.sh

WORKDIR /var/lib/mysql
EXPOSE 3306
VOLUME ["/var/lib/mysql"]

#run init script (which creates user if not existing)
CMD ["/entrypoint.sh"]