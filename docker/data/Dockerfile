# This image includes the data import related scripts in one image.
# Because of historic reasons some of these scripts run java
# artifacts under the hood. It therefore currently makes more sense to have a
# single image supporting both instead of moving the scripts out to a separate
# container.
#
# Use from root directory of repo like:
#
# docker build -f docker/web-and-data/Dockerfile -t cdataportal-importer:tag-name .
#
# WARNING: Be careful about publishing images generated like this publicly
# because your .git folder is exposed in the build step. We are not sure if
# this is a security risk: stackoverflow.com/questions/56278325

# Based on cdataportal image, so you need to build cdataportal image firstly.
FROM registry.cn-shanghai.aliyuncs.com/pgx-docker-registry/cdataportal:v3.0.4-tgmc as build

FROM openjdk:8-jre

RUN mkdir -p /cbioportal
# copy over core jar and scripts
COPY --from=build /cbioportal/core /cbioportal/core
COPY --from=build /cbioportal/scripts /cbioportal/scripts
COPY --from=build /cbioportal/db-scripts /cbioportal/db-scripts
COPY --from=build /cbioportal/requirements.txt /cbioportal/requirements.txt

# install build and runtime dependencies
# ignore update failures
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
RUN  apt-get clean && apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        libmysql-java \
        default-libmysqlclient-dev \
        python3 \
        python3-setuptools \
        python3-dev \
        python3-pip \
	&& rm -rf /var/lib/apt/lists/* \
    && pip3 install wheel -i https://mirrors.aliyun.com/pypi/simple/ \
    && pip3 install -r /cbioportal/requirements.txt -i https://mirrors.aliyun.com/pypi/simple/

# add importer scripts to PATH for easy running in containers
RUN find /cbioportal/core/src/main/scripts/ -type f -executable \! -name '*.pl'  -print0 | xargs -0 -- ln -st /usr/local/bin

# put config files in this folder if you want to override config
ENV PORTAL_HOME=/cbioportal
