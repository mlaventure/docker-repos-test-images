FROM golang:1.6.2

RUN go get github.com/prometheus/graphite_exporter

ENV SERVICE_NAME=docker-repo-install-test-metrics

EXPOSE 9108

COPY graphite_mapping.conf /root/

CMD ["graphite_exporter", "-graphite.mapping-config=/root/graphite_mapping.conf"]
