FROM grafana/tempo:1.5.0

# Add the config file to the container
COPY ./tempo-config.yaml /etc/tempo.yaml

CMD ["/tempo", "-config.file=/etc/tempo.yaml"]
