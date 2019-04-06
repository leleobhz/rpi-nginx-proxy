FROM nginx:mainline-alpine
LABEL authors="Ludovic Roguet <code@fourteenislands.io>"
LABEL maintainer="Leonardo Amaral <docker@leonardoamaral.com.br>"

# Install wget and install/updates certificates
RUN apk add --no-cache --virtual .run-deps \
    ca-certificates bash wget openssl \
    && update-ca-certificates

# Configure Nginx and apply fix for very long server names
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
&& sed -i 's/worker_processes 1/worker_processes auto/' /etc/nginx/nginx.conf

# Install Forego
RUN wget https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-arm.tgz \
    && tar -C /usr/local/bin -xvzf forego-stable-linux-arm.tgz \
    && rm /forego-stable-linux-arm.tgz

ENV DOCKER_GEN_VERSION 0.7.4

RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz \
 && tar -C /usr/local/bin -xvzf docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz \
 && rm /docker-gen-linux-armhf-$DOCKER_GEN_VERSION.tar.gz

COPY data /app/
WORKDIR /app/

ENV DOCKER_HOST unix:///tmp/docker.sock

VOLUME ["/etc/nginx/certs"]

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
