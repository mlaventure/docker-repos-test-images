FROM golang:1.6.2

RUN apt-get update && apt-get install -y --no-install-recommends netcat

# Install the exporter
RUN  go get github.com/prometheus/graphite_exporter

COPY docker-install.sh /usr/local/bin

CMD ["docker-install.sh"]
