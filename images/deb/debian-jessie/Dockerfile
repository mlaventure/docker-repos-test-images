#
# THIS FILE IS AUTOGENERATED; SEE "generate-dockerfiles.sh"!
#

FROM debian:jessie

RUN apt-get update && apt-get install -y --no-install-recommends netcat curl ca-certificates cron gnupg dirmngr

COPY docker-install.sh /usr/local/bin
COPY bootstrap.sh /usr/local/bin
COPY savelog /usr/local/bin

CMD  bootstrap.sh && cron && sleep infinity
