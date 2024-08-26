FROM debian/eol:wheezy

LABEL org.opencontainers.image.authors="Ilya Kogan <ikogan@flarecode.com>"
LABEL org.opencontainers.image.authors="MAINTAINER Alex Lennon <ajlennon@dynamicdevices.co.uk>"

ENV DEBIAN_FRONTEND=noninteractive

# Add the OpenMediaVault repository
COPY openmediavault.list /etc/apt/sources.list.d/

# Fix resolvconf issues with Docker
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

# Install OpenMediaVault packages and dependencies
RUN apt-get update -y; apt-get install nano openmediavault-keyring postfix locales -y --force-yes --allow-unauthenticated
RUN apt-get update -y; apt-get install openmediavault -y --allow-unauthenticated

# We need to make sure rrdcached uses /data for it's data
COPY defaults/rrdcached /etc/default

# Add our startup script last because we don't want changes
# to it to require a full container rebuild
COPY omv-startup /usr/sbin/omv-startup
RUN chmod +x /usr/sbin/omv-startup
COPY sleep.sh /usr/sbin/sleep.sh
RUN chmod +x /usr/sbin/sleep.sh
COPY fake-shared-folders.sh /usr/sbin/fake-shared-folders.sh
RUN chmod +x /usr/sbin/fake-shared-folders.sh

EXPOSE 8100:80 8443:443

VOLUME /data

SHELL [ "/bin/bash", "-c" ]
ENTRYPOINT /usr/sbin/omv-startup
#ENTRYPOINT /usr/sbin/sleep.sh
