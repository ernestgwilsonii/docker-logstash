FROM openjdk:8-jre-alpine
# REF: https://hub.docker.com/_/openjdk/

# Production grade Logstash
MAINTAINER "Ernest G. Wilson II" <ErnestGWilsonII@gmail.com>

# Create logstash group and user
RUN addgroup -S logstash && adduser -S -G logstash logstash

# Install requirements
RUN apk add --no-cache \
  bash \
  ca-certificates \
  curl \
  gnupg \
  libc6-compat \
  libzmq \
  openssl \
  su-exec \
  tar

# https://www.elastic.co/guide/en/logstash/5.0/installing-logstash.html#_apt
# https://artifacts.elastic.co/GPG-KEY-elasticsearch

ENV LOGSTASH_PATH /usr/share/logstash/bin
ENV PATH $LOGSTASH_PATH:$PATH

ENV GPG_KEY 46095ACC8548582C1A2699A9D27D666CD88E42B4

# Build using this specific version of Logstash
ENV LOGSTASH_VERSION 5.4.1
ENV LOGSTASH_TARBALL="https://artifacts.elastic.co/downloads/logstash/logstash-5.4.1.tar.gz" \
      LOGSTASH_TARBALL_ASC="https://artifacts.elastic.co/downloads/logstash/logstash-5.4.1.tar.gz.asc" \
      LOGSTASH_TARBALL_SHA1="83ae815ebb9cf787f694c19b65d417142e49217a"

RUN set -ex; \
        \
        if [ -z "$LOGSTASH_TARBALL_SHA1" ] && [ -z "$LOGSTASH_TARBALL_ASC" ]; then \
                echo >&2 'error: have neither a SHA1 _or_ a signature file -- cannot verify download!'; \
                exit 1; \
        fi; \
        \
        wget -O logstash.tar.gz "$LOGSTASH_TARBALL"; \
        \
        if [ "$LOGSTASH_TARBALL_SHA1" ]; then \
                echo "$LOGSTASH_TARBALL_SHA1 *logstash.tar.gz" | sha1sum -c -; \
        fi; \
        \
        if [ "$LOGSTASH_TARBALL_ASC" ]; then \
                wget -O logstash.tar.gz.asc "$LOGSTASH_TARBALL_ASC"; \
                export GNUPGHOME="$(mktemp -d)"; \
                gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY"; \
                gpg --batch --verify logstash.tar.gz.asc logstash.tar.gz; \
                rm -r "$GNUPGHOME" logstash.tar.gz.asc; \
        fi; \
        \
        dir="$(dirname "$LOGSTASH_PATH")"; \
        \
        mkdir -p "$dir"; \
        tar -xf logstash.tar.gz --strip-components=1 -C "$dir"; \
        rm logstash.tar.gz; \
        \
        apk del .fetch-deps; \
        \
        export LS_SETTINGS_DIR="$dir/config"; \
# Empty log4j2.properties file so the default only logs errors to the console
        if [ -f "$LS_SETTINGS_DIR/log4j2.properties" ]; then \
                cp "$LS_SETTINGS_DIR/log4j2.properties" "$LS_SETTINGS_DIR/log4j2.properties.dist"; \
                truncate -s 0 "$LS_SETTINGS_DIR/log4j2.properties"; \
        fi; \
        \
        logstash --version

# Copy any defult Logstash config files that you want to override (if any - normally we just use the default that comes with Logstash.tar.gz)
# COPY blah /usr/share/logstash/config/

# Install specific Logstash plug-ins
RUN logstash-plugin install logstash-input-beats

# Copy in our specific Logstash configuration file
COPY logstash.conf /etc/logstash.conf

# Set directory / file permissions
RUN for userDir in \
      "$dir/config" \
      "$dir/data" \
    ; do \
        if [ -d "$userDir" ]; then \
          chown -R logstash:logstash "$userDir"; \
        fi; \
        done;

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["-e", ""]
